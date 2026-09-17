package com.nova.file.service;

import cn.hutool.core.io.FileUtil;
import cn.hutool.core.util.StrUtil;
import cn.hutool.crypto.digest.DigestUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.nova.core.utils.AssertUtil;
import com.nova.core.utils.IdGeneratorUtil;
import com.nova.file.domain.dto.UploadInitRequest;
import com.nova.file.domain.dto.UploadInitResponse;
import com.nova.file.domain.entity.FileChunk;
import com.nova.file.domain.entity.FileInfo;
import com.nova.file.domain.entity.FileStorage;
import com.nova.file.mapper.FileChunkMapper;
import com.nova.file.mapper.FileInfoMapper;
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
public class FileUploadService {

    public static final long DEFAULT_CHUNK_SIZE = 5L * 1024 * 1024;

    private final FileInfoMapper fileInfoMapper;
    private final FileChunkMapper fileChunkMapper;
    private final ActiveStorageHolder activeStorageHolder;

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

        FileInfo uploading = fileInfoMapper.selectOne(new LambdaQueryWrapper<FileInfo>()
                .eq(FileInfo::getFileMd5, request.getFileMd5())
                .eq(FileInfo::getUploadStatus, 0)
                .orderByDesc(FileInfo::getGmtCreate)
                .last("LIMIT 1"));
        if (uploading != null && StrUtil.isNotBlank(uploading.getUploadId())) {
            List<Integer> uploaded = listUploadedChunkIndexes(uploading.getUploadId());
            return UploadInitResponse.builder()
                    .skipUpload(false)
                    .fileId(uploading.getId())
                    .uploadId(uploading.getUploadId())
                    .objectKey(uploading.getObjectKey())
                    .chunkSize(chunkSize)
                    .chunkTotal(chunkTotal)
                    .uploadedChunks(uploaded)
                    .build();
        }

        String suffix = FileUtil.extName(request.getFileName());
        String objectKey = buildObjectKey(suffix, request.getFileMd5());
        String uploadId = client.initiateMultipart(objectKey, request.getContentType());

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
        info.setUploadStatus(0);
        info.setIsDeleted(0);
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

    @Transactional(rollbackFor = Exception.class)
    public void uploadChunk(String uploadId, int chunkIndex, String chunkMd5, MultipartFile file) {
        AssertUtil.isNotBlank(uploadId, "uploadId 不能为空");
        AssertUtil.isTrue(chunkIndex >= 0, "chunkIndex 非法");
        AssertUtil.notNull(file, "分片文件不能为空");

        FileInfo info = requireUploading(uploadId);
        FileChunk exists = fileChunkMapper.selectOne(new LambdaQueryWrapper<FileChunk>()
                .eq(FileChunk::getUploadId, uploadId)
                .eq(FileChunk::getChunkIndex, chunkIndex)
                .eq(FileChunk::getStatus, 1)
                .last("LIMIT 1"));
        if (exists != null) {
            return;
        }

        // S3 partNumber 从 1 开始；本地同样使用 1-based 与 DB chunkIndex(0-based) 映射
        int partNumber = chunkIndex + 1;
        String etag;
        try (InputStream in = file.getInputStream()) {
            etag = activeStorageHolder.requireClient()
                    .uploadPart(info.getObjectKey(), uploadId, partNumber, in, file.getSize());
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
            chunk.setChunkSize(file.getSize());
            chunk.setChunkMd5(chunkMd5);
            chunk.setEtag(etag);
            chunk.setStatus(1);
            fileChunkMapper.insert(chunk);
        } else {
            chunk.setChunkSize(file.getSize());
            chunk.setChunkMd5(chunkMd5);
            chunk.setEtag(etag);
            chunk.setStatus(1);
            fileChunkMapper.updateById(chunk);
        }
    }

    @Transactional(rollbackFor = Exception.class)
    public FileInfo merge(String uploadId) {
        FileInfo info = requireUploading(uploadId);
        List<FileChunk> chunks = fileChunkMapper.selectList(new LambdaQueryWrapper<FileChunk>()
                .eq(FileChunk::getUploadId, uploadId)
                .eq(FileChunk::getStatus, 1)
                .orderByAsc(FileChunk::getChunkIndex));
        AssertUtil.isTrue(!chunks.isEmpty(), "没有任何已上传分片");

        long sum = chunks.stream().mapToLong(c -> c.getChunkSize() == null ? 0L : c.getChunkSize()).sum();
        AssertUtil.isTrue(sum == info.getFileSize(), "分片总大小与文件大小不一致");

        List<PartETagInfo> parts = chunks.stream()
                .map(c -> new PartETagInfo(c.getChunkIndex() + 1, c.getEtag()))
                .collect(Collectors.toList());

        FileStorageClient client = activeStorageHolder.requireClient();
        client.completeMultipart(info.getObjectKey(), uploadId, parts);

        info.setUploadStatus(1);
        info.setAccessUrl(client.getAccessUrl(info.getObjectKey()));
        fileInfoMapper.updateById(info);
        return info;
    }

    public List<Integer> progress(String uploadId) {
        requireUploading(uploadId);
        return listUploadedChunkIndexes(uploadId);
    }

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

    public Page<FileInfo> page(long pageNo, long pageSize, String fileName) {
        LambdaQueryWrapper<FileInfo> qw = new LambdaQueryWrapper<FileInfo>()
                .eq(FileInfo::getUploadStatus, 1)
                .like(StrUtil.isNotBlank(fileName), FileInfo::getFileName, fileName)
                .orderByDesc(FileInfo::getGmtCreate);
        return fileInfoMapper.selectPage(new Page<>(pageNo, pageSize), qw);
    }

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

    private FileInfo requireUploading(String uploadId) {
        FileInfo info = fileInfoMapper.selectOne(new LambdaQueryWrapper<FileInfo>()
                .eq(FileInfo::getUploadId, uploadId)
                .last("LIMIT 1"));
        AssertUtil.notNull(info, "上传会话不存在");
        AssertUtil.isTrue(Integer.valueOf(0).equals(info.getUploadStatus()), "上传会话已结束");
        return info;
    }

    private List<Integer> listUploadedChunkIndexes(String uploadId) {
        return fileChunkMapper.selectList(new LambdaQueryWrapper<FileChunk>()
                        .eq(FileChunk::getUploadId, uploadId)
                        .eq(FileChunk::getStatus, 1)
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
