package com.nova.file.service.impl;

import cn.hutool.core.io.FileUtil;
import cn.hutool.core.util.IdUtil;
import cn.hutool.core.util.StrUtil;
import cn.hutool.crypto.digest.DigestUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.nova.core.utils.AssertUtil;
import com.nova.core.utils.IdGeneratorUtil;
import com.nova.file.api.dto.UploadInitRequest;
import com.nova.file.api.dto.UploadInitResponse;
import com.nova.file.config.ActiveStorageHolder;
import com.nova.file.domain.entity.FileChunk;
import com.nova.file.domain.entity.FileInfo;
import com.nova.file.domain.entity.FileStorage;
import com.nova.file.mapper.FileChunkMapper;
import com.nova.file.mapper.FileInfoMapper;
import com.nova.file.service.FileUploadService;
import com.nova.file.starter.client.FileStorageClient;
import com.nova.file.starter.model.PartETagInfo;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FileUploadServiceImpl implements FileUploadService {

    private final FileInfoMapper fileInfoMapper;
    private final FileChunkMapper fileChunkMapper;
    private final ActiveStorageHolder activeStorageHolder;

    @Override
    public UploadInitResponse init(UploadInitRequest request) {
        AssertUtil.isNotBlank(request.getFileMd5(), "fileMd5 不能为空");
        FileStorage storage = activeStorageHolder.requireStorage();
        FileStorageClient client = activeStorageHolder.requireClient();

        FileInfo finished = fileInfoMapper.selectOne(new LambdaQueryWrapper<FileInfo>()
                .eq(FileInfo::getFileMd5, request.getFileMd5())
                .eq(FileInfo::getUploadStatus, 1)
                .last("LIMIT 1"));
        if (finished != null) {
            return UploadInitResponse.builder()
                    .skipUpload(true)
                    .fileId(finished.getId())
                    .accessUrl(finished.getAccessUrl())
                    .uploadId(finished.getUploadId())
                    .objectKey(finished.getObjectKey())
                    .chunkSize(0)
                    .chunkTotal(0)
                    .uploadedChunks(List.of())
                    .build();
        }

        long chunkSize = request.getChunkSize() == null || request.getChunkSize() <= 0
                ? DEFAULT_CHUNK_SIZE
                : request.getChunkSize();
        int chunkTotal = (int) Math.ceil(request.getFileSize() * 1.0 / chunkSize);

        // 放弃同 MD5 下未完成会话，避免历史错误分片（size 异常）污染合并
        List<FileInfo> uploadingList = fileInfoMapper.selectList(new LambdaQueryWrapper<FileInfo>()
                .eq(FileInfo::getFileMd5, request.getFileMd5())
                .eq(FileInfo::getUploadStatus, 0));
        for (FileInfo old : uploadingList) {
            abandonUploading(old, client);
        }

        String suffix = FileUtil.extName(request.getFileName());
        String objectKey = buildObjectKey(suffix, request.getFileMd5());
        String providerUploadId = client.initiateMultipart(objectKey, request.getContentType());
        // 前端/库表用短会话 ID，避免 S3 uploadId 超长截断或特殊字符导致“上传会话不存在”
        String uploadId = IdUtil.simpleUUID();

        FileInfo info = new FileInfo();
        info.setId(IdGeneratorUtil.nextId());
        info.setTenantId(0L);
        info.setStorageId(storage.getId());
        info.setFileName(request.getFileName());
        info.setFileSuffix(suffix);
        info.setContentType(request.getContentType());
        info.setFileSize(request.getFileSize());
        info.setFileMd5(request.getFileMd5());
        info.setBucketName(storage.getBucketName());
        info.setObjectKey(objectKey);
        info.setBizType(request.getBizType());
        info.setBizId(request.getBizId());
        info.setUploadId(uploadId);
        info.setProviderUploadId(providerUploadId);
        info.setUploadStatus(0);
        info.setIsDeleted(0);
        info.setRemark("chunkSize=" + chunkSize);
        fileInfoMapper.insert(info);

        return UploadInitResponse.builder()
                .skipUpload(false)
                .fileId(info.getId())
                .uploadId(uploadId)
                .objectKey(objectKey)
                .chunkSize(chunkSize)
                .chunkTotal(chunkTotal)
                .uploadedChunks(List.of())
                .build();
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void uploadChunk(String uploadId, int chunkIndex, String chunkMd5, MultipartFile file) {
        AssertUtil.isNotBlank(uploadId, "uploadId 不能为空");
        AssertUtil.isTrue(chunkIndex >= 0, "chunkIndex 非法");
        AssertUtil.notNull(file, "分片文件不能为空");

        FileInfo info = requireUploading(uploadId);
        byte[] bytes;
        try {
            // 不要用 MultipartFile.getSize()：Blob 分片场景下可能为 0，导致合并校验失败
            bytes = file.getBytes();
        } catch (Exception e) {
            throw new IllegalStateException("读取分片失败: " + e.getMessage(), e);
        }
        long actualSize = bytes.length;
        AssertUtil.isTrue(actualSize > 0, "分片内容为空");
        long configuredChunkSize = parseChunkSize(info.getRemark());
        long expectedSize = expectedChunkBytes(info.getFileSize(), configuredChunkSize, chunkIndex);
        AssertUtil.isTrue(actualSize == expectedSize,
                "分片大小不正确: index=" + chunkIndex + ", actual=" + actualSize + ", expected=" + expectedSize);

        FileChunk exists = fileChunkMapper.selectOne(new LambdaQueryWrapper<FileChunk>()
                .eq(FileChunk::getUploadId, uploadId)
                .eq(FileChunk::getChunkIndex, chunkIndex)
                .eq(FileChunk::getStatus, 1)
                .last("LIMIT 1"));
        if (exists != null && expectedSize == (exists.getChunkSize() == null ? -1L : exists.getChunkSize())) {
            return;
        }

        int partNumber = chunkIndex + 1;
        String storageUploadId = resolveProviderUploadId(info);
        String etag;
        try (InputStream in = new java.io.ByteArrayInputStream(bytes)) {
            etag = activeStorageHolder.requireClient()
                    .uploadPart(info.getObjectKey(), storageUploadId, partNumber, in, actualSize);
        } catch (Exception e) {
            throw new IllegalStateException("分片上传失败: " + e.getMessage(), e);
        }

        FileChunk chunk = fileChunkMapper.selectOne(new LambdaQueryWrapper<FileChunk>()
                .eq(FileChunk::getUploadId, uploadId)
                .eq(FileChunk::getChunkIndex, chunkIndex)
                .last("LIMIT 1"));
        if (chunk == null) {
            chunk = new FileChunk();
            chunk.setId(IdGeneratorUtil.nextId());
            chunk.setTenantId(0L);
            chunk.setUploadId(uploadId);
            chunk.setFileMd5(info.getFileMd5());
            chunk.setChunkIndex(chunkIndex);
            chunk.setObjectKey(info.getObjectKey());
            chunk.setChunkSize(actualSize);
            chunk.setChunkMd5(chunkMd5);
            chunk.setEtag(etag);
            chunk.setStatus(1);
            fileChunkMapper.insert(chunk);
        } else {
            chunk.setChunkSize(actualSize);
            chunk.setChunkMd5(chunkMd5);
            chunk.setEtag(etag);
            chunk.setStatus(1);
            fileChunkMapper.updateById(chunk);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public FileInfo merge(String uploadId) {
        FileInfo info = requireUploading(uploadId);
        long configuredChunkSize = parseChunkSize(info.getRemark());
        int expectedTotal = (int) Math.ceil(info.getFileSize() * 1.0 / configuredChunkSize);

        List<FileChunk> rawChunks = fileChunkMapper.selectList(new LambdaQueryWrapper<FileChunk>()
                .eq(FileChunk::getUploadId, uploadId)
                .eq(FileChunk::getStatus, 1)
                .orderByAsc(FileChunk::getChunkIndex)
                .orderByDesc(FileChunk::getId));
        // 按 chunkIndex 去重，保留最新一条
        java.util.Map<Integer, FileChunk> unique = new java.util.LinkedHashMap<>();
        for (FileChunk chunk : rawChunks) {
            unique.putIfAbsent(chunk.getChunkIndex(), chunk);
        }
        List<FileChunk> chunks = new java.util.ArrayList<>(unique.values());
        chunks.sort(java.util.Comparator.comparingInt(FileChunk::getChunkIndex));
        AssertUtil.isTrue(!chunks.isEmpty(), "没有任何已上传分片");
        AssertUtil.isTrue(chunks.size() == expectedTotal,
                "分片数量不一致: actual=" + chunks.size() + ", expected=" + expectedTotal);

        for (int i = 0; i < chunks.size(); i++) {
            FileChunk chunk = chunks.get(i);
            AssertUtil.isTrue(Integer.valueOf(i).equals(chunk.getChunkIndex()),
                    "分片不连续，缺少序号: " + i);
            long expectedSize = expectedChunkBytes(info.getFileSize(), configuredChunkSize, i);
            AssertUtil.isTrue(chunk.getChunkSize() != null && chunk.getChunkSize() == expectedSize,
                    "分片大小不正确: index=" + i + ", actual=" + chunk.getChunkSize() + ", expected=" + expectedSize);
        }

        List<PartETagInfo> parts = chunks.stream()
                .map(c -> new PartETagInfo(c.getChunkIndex() + 1, c.getEtag()))
                .collect(Collectors.toList());

        FileStorageClient client = activeStorageHolder.requireClient();
        client.completeMultipart(info.getObjectKey(), resolveProviderUploadId(info), parts);

        info.setUploadStatus(1);
        info.setAccessUrl(client.getAccessUrl(info.getObjectKey()));
        fileInfoMapper.updateById(info);
        return info;
    }

    @Override
    public List<Integer> progress(String uploadId) {
        requireUploading(uploadId);
        return listUploadedChunkIndexes(uploadId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public FileInfo simpleUpload(MultipartFile file, String bizType, String bizId) {
        AssertUtil.notNull(file, "文件不能为空");
        FileStorage storage = activeStorageHolder.requireStorage();
        FileStorageClient client = activeStorageHolder.requireClient();

        String md5;
        try (InputStream in = file.getInputStream()) {
            md5 = DigestUtil.md5Hex(in);
        } catch (Exception e) {
            throw new IllegalStateException("计算 MD5 失败", e);
        }

        FileInfo finished = fileInfoMapper.selectOne(new LambdaQueryWrapper<FileInfo>()
                .eq(FileInfo::getFileMd5, md5)
                .eq(FileInfo::getUploadStatus, 1)
                .last("LIMIT 1"));
        if (finished != null) {
            return finished;
        }

        String suffix = FileUtil.extName(file.getOriginalFilename());
        String objectKey = buildObjectKey(suffix, md5);
        try (InputStream in = file.getInputStream()) {
            client.upload(objectKey, in, file.getSize(), file.getContentType());
        } catch (Exception e) {
            throw new IllegalStateException("上传失败: " + e.getMessage(), e);
        }

        FileInfo info = new FileInfo();
        info.setId(IdGeneratorUtil.nextId());
        info.setTenantId(0L);
        info.setStorageId(storage.getId());
        info.setFileName(file.getOriginalFilename());
        info.setFileSuffix(suffix);
        info.setContentType(file.getContentType());
        info.setFileSize(file.getSize());
        info.setFileMd5(md5);
        info.setBucketName(storage.getBucketName());
        info.setObjectKey(objectKey);
        info.setAccessUrl(client.getAccessUrl(objectKey));
        info.setBizType(bizType);
        info.setBizId(bizId);
        info.setUploadStatus(1);
        info.setIsDeleted(0);
        fileInfoMapper.insert(info);
        return info;
    }

    @Override
    public Page<FileInfo> page(long pageNo, long pageSize, String fileName) {
        LambdaQueryWrapper<FileInfo> qw = new LambdaQueryWrapper<FileInfo>()
                .eq(FileInfo::getUploadStatus, 1)
                .like(StrUtil.isNotBlank(fileName), FileInfo::getFileName, fileName)
                .orderByDesc(FileInfo::getGmtCreate);
        return fileInfoMapper.selectPage(new Page<>(pageNo, pageSize), qw);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteFile(Long id) {
        FileInfo info = fileInfoMapper.selectById(id);
        AssertUtil.notNull(info, "文件不存在");
        try {
            activeStorageHolder.requireClient().delete(info.getObjectKey());
        } catch (Exception ignored) {
            // 存储侧删除失败仍做逻辑删除
        }
        fileInfoMapper.deleteById(id);
    }

    @Override
    public FileInfo getById(Long id) {
        FileInfo info = fileInfoMapper.selectById(id);
        AssertUtil.notNull(info, "文件不存在");
        return info;
    }

    @Override
    public FileInfo getByMd5(String fileMd5) {
        return fileInfoMapper.selectOne(new LambdaQueryWrapper<FileInfo>()
                .eq(FileInfo::getFileMd5, fileMd5)
                .eq(FileInfo::getUploadStatus, 1)
                .last("LIMIT 1"));
    }

    @Override
    public boolean existsByMd5(String fileMd5) {
        Long count = fileInfoMapper.selectCount(new LambdaQueryWrapper<FileInfo>()
                .eq(FileInfo::getFileMd5, fileMd5)
                .eq(FileInfo::getUploadStatus, 1));
        return count != null && count > 0;
    }

    private void abandonUploading(FileInfo old, FileStorageClient client) {
        if (old == null) {
            return;
        }
        old.setUploadStatus(2);
        fileInfoMapper.updateById(old);
        if (StrUtil.isNotBlank(old.getUploadId())) {
            fileChunkMapper.delete(new LambdaQueryWrapper<FileChunk>()
                    .eq(FileChunk::getUploadId, old.getUploadId()));
        }
        try {
            if (StrUtil.isNotBlank(old.getObjectKey()) && StrUtil.isNotBlank(resolveProviderUploadId(old))) {
                client.abortMultipart(old.getObjectKey(), resolveProviderUploadId(old));
            }
        } catch (Exception ignored) {
            // 尽力中止对象存储 multipart
        }
    }

    private static long parseChunkSize(String remark) {
        if (StrUtil.isBlank(remark) || !remark.startsWith("chunkSize=")) {
            return DEFAULT_CHUNK_SIZE;
        }
        try {
            long size = Long.parseLong(remark.substring("chunkSize=".length()).trim());
            return size > 0 ? size : DEFAULT_CHUNK_SIZE;
        } catch (Exception e) {
            return DEFAULT_CHUNK_SIZE;
        }
    }

    private static long expectedChunkBytes(long fileSize, long chunkSize, int chunkIndex) {
        long start = (long) chunkIndex * chunkSize;
        AssertUtil.isTrue(start < fileSize, "chunkIndex 超出文件范围: " + chunkIndex);
        return Math.min(chunkSize, fileSize - start);
    }

    private FileInfo requireUploading(String uploadId) {
        FileInfo info = fileInfoMapper.selectOne(new LambdaQueryWrapper<FileInfo>()
                .eq(FileInfo::getUploadId, uploadId)
                .last("LIMIT 1"));
        AssertUtil.notNull(info, "上传会话不存在");
        AssertUtil.isTrue(Integer.valueOf(0).equals(info.getUploadStatus()), "上传会话已结束");
        return info;
    }

    /** 调用对象存储时使用 providerUploadId；兼容旧数据（仅有 uploadId） */
    private static String resolveProviderUploadId(FileInfo info) {
        return StrUtil.blankToDefault(info.getProviderUploadId(), info.getUploadId());
    }

    private List<Integer> listUploadedChunkIndexes(String uploadId) {
        return fileChunkMapper.selectList(new LambdaQueryWrapper<FileChunk>()
                        .eq(FileChunk::getUploadId, uploadId)
                        .eq(FileChunk::getStatus, 1)
                        .gt(FileChunk::getChunkSize, 0)
                        .orderByAsc(FileChunk::getChunkIndex))
                .stream()
                .map(FileChunk::getChunkIndex)
                .collect(Collectors.toList());
    }

    private static String buildObjectKey(String suffix, String md5) {
        String day = LocalDate.now().format(DateTimeFormatter.BASIC_ISO_DATE);
        String name = md5 + (StrUtil.isBlank(suffix) ? "" : "." + suffix);
        return day + "/" + name;
    }
}
