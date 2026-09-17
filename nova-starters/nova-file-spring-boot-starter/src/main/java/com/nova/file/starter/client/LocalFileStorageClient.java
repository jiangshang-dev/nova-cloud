package com.nova.file.starter.client;

import cn.hutool.core.io.FileUtil;
import cn.hutool.core.util.IdUtil;
import cn.hutool.core.util.StrUtil;
import cn.hutool.json.JSONObject;
import cn.hutool.json.JSONUtil;
import com.nova.file.starter.enums.StorageType;
import com.nova.file.starter.model.PartETagInfo;
import com.nova.file.starter.model.StorageConfig;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

/**
 * 本地磁盘存储；分片落在临时目录，合并后写入正式路径。
 */
public class LocalFileStorageClient implements FileStorageClient {

    private final StorageConfig config;
    private final Path root;
    private final Path chunkRoot;

    public LocalFileStorageClient(StorageConfig config) {
        this.config = config;
        if (StrUtil.isBlank(config.getBasePath())) {
            throw new IllegalArgumentException("本地存储 basePath 不能为空");
        }
        this.root = Paths.get(config.getBasePath()).toAbsolutePath().normalize();
        FileUtil.mkdir(root.toFile());
        JSONObject ext = parseExt(config.getExtConfig());
        String chunkTemp = ext.getStr("chunkTempDir");
        this.chunkRoot = StrUtil.isNotBlank(chunkTemp)
                ? Paths.get(chunkTemp).toAbsolutePath().normalize()
                : root.resolve(".chunks");
        FileUtil.mkdir(chunkRoot.toFile());
    }

    @Override
    public StorageType type() {
        return StorageType.LOCAL;
    }

    @Override
    public StorageConfig config() {
        return config;
    }

    @Override
    public void upload(String objectKey, InputStream in, long size, String contentType) {
        Path target = resolveObject(objectKey);
        FileUtil.mkdir(target.getParent().toFile());
        try {
            Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException e) {
            throw new IllegalStateException("本地上传失败: " + objectKey, e);
        }
    }

    @Override
    public InputStream download(String objectKey) {
        try {
            return new BufferedInputStream(Files.newInputStream(resolveObject(objectKey)));
        } catch (IOException e) {
            throw new IllegalStateException("本地读取失败: " + objectKey, e);
        }
    }

    @Override
    public void delete(String objectKey) {
        FileUtil.del(resolveObject(objectKey).toFile());
    }

    @Override
    public boolean exists(String objectKey) {
        return Files.exists(resolveObject(objectKey));
    }

    @Override
    public void ping() {
        if (!Files.isWritable(root)) {
            throw new IllegalStateException("本地目录不可写: " + root);
        }
    }

    @Override
    public String getAccessUrl(String objectKey) {
        if (StrUtil.isNotBlank(config.getDomain())) {
            return joinUrl(config.getDomain(), objectKey);
        }
        return "file://" + resolveObject(objectKey);
    }

    @Override
    public String initiateMultipart(String objectKey, String contentType) {
        String uploadId = IdUtil.simpleUUID();
        FileUtil.mkdir(chunkDir(uploadId).toFile());
        FileUtil.writeUtf8String(objectKey, metaFile(uploadId).toFile());
        return uploadId;
    }

    @Override
    public String uploadPart(String objectKey, String uploadId, int partNumber, InputStream in, long size) {
        Path part = chunkDir(uploadId).resolve(String.format("%06d.part", partNumber));
        try {
            Files.copy(in, part, StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException e) {
            throw new IllegalStateException("本地分片写入失败: " + partNumber, e);
        }
        return "local-" + partNumber + "-" + FileUtil.size(part.toFile());
    }

    @Override
    public void completeMultipart(String objectKey, String uploadId, List<PartETagInfo> parts) {
        Path target = resolveObject(objectKey);
        FileUtil.mkdir(target.getParent().toFile());
        List<PartETagInfo> ordered = parts.stream()
                .sorted(Comparator.comparingInt(PartETagInfo::getPartNumber))
                .collect(Collectors.toList());
        try (OutputStream out = new BufferedOutputStream(Files.newOutputStream(target))) {
            for (PartETagInfo part : ordered) {
                Path p = chunkDir(uploadId).resolve(String.format("%06d.part", part.getPartNumber()));
                if (!Files.exists(p)) {
                    throw new IllegalStateException("缺少分片: " + part.getPartNumber());
                }
                Files.copy(p, out);
            }
        } catch (IOException e) {
            throw new IllegalStateException("本地合并失败: " + objectKey, e);
        } finally {
            FileUtil.del(chunkDir(uploadId).toFile());
            FileUtil.del(metaFile(uploadId).toFile());
        }
    }

    @Override
    public void abortMultipart(String objectKey, String uploadId) {
        FileUtil.del(chunkDir(uploadId).toFile());
        FileUtil.del(metaFile(uploadId).toFile());
    }

    @Override
    public List<Integer> listUploadedParts(String objectKey, String uploadId) {
        Path dir = chunkDir(uploadId);
        if (!Files.isDirectory(dir)) {
            return List.of();
        }
        List<Integer> indexes = new ArrayList<>();
        try (Stream<Path> stream = Files.list(dir)) {
            stream.filter(p -> p.getFileName().toString().endsWith(".part"))
                    .forEach(p -> {
                        String name = p.getFileName().toString().replace(".part", "");
                        indexes.add(Integer.parseInt(name));
                    });
        } catch (IOException e) {
            throw new IllegalStateException("列举本地分片失败", e);
        }
        indexes.sort(Integer::compareTo);
        return indexes;
    }

    private Path resolveObject(String objectKey) {
        String key = StrUtil.removePrefix(objectKey.replace('\\', '/'), "/");
        Path target = root.resolve(key).normalize();
        if (!target.startsWith(root)) {
            throw new IllegalArgumentException("非法 objectKey: " + objectKey);
        }
        return target;
    }

    private Path chunkDir(String uploadId) {
        return chunkRoot.resolve(uploadId);
    }

    private Path metaFile(String uploadId) {
        return chunkRoot.resolve(uploadId + ".meta");
    }

    private static JSONObject parseExt(String extConfig) {
        if (StrUtil.isBlank(extConfig)) {
            return new JSONObject();
        }
        return JSONUtil.parseObj(extConfig);
    }

    private static String joinUrl(String domain, String objectKey) {
        String d = StrUtil.removeSuffix(domain, "/");
        String k = StrUtil.removePrefix(objectKey, "/");
        return d + "/" + k;
    }
}
