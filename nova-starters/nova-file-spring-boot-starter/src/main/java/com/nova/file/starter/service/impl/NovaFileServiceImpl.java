package com.nova.file.starter.service.impl;

import cn.hutool.core.codec.Base64;
import cn.hutool.core.collection.CollUtil;
import cn.hutool.core.date.DateUtil;
import cn.hutool.core.io.FileUtil;
import cn.hutool.core.io.IoUtil;
import cn.hutool.core.util.ArrayUtil;
import cn.hutool.core.util.IdUtil;
import cn.hutool.core.util.StrUtil;
import com.nova.file.starter.client.FileStorageClient;
import com.nova.file.starter.client.FileStorageClientProvider;
import com.nova.file.starter.model.FileObjectInfo;
import com.nova.file.starter.service.NovaFileService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.multipart.MultipartFile;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

/**
 * 基于后台启用的 {@link FileStorageClient} 实现文件读写。
 */
@Slf4j
@RequiredArgsConstructor
public class NovaFileServiceImpl implements NovaFileService {

    private final FileStorageClientProvider clientProvider;

    private FileStorageClient client() {
        return clientProvider.requireClient();
    }

    @Override
    public FileObjectInfo upload(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            return null;
        }
        try (InputStream in = file.getInputStream()) {
            return doSave(in, file.getOriginalFilename(), file.getSize(), file.getContentType());
        } catch (Exception e) {
            throw new IllegalStateException("文件上传失败: " + e.getMessage(), e);
        }
    }

    @Override
    public List<FileObjectInfo> upload(MultipartFile[] files) {
        if (ArrayUtil.isEmpty(files)) {
            return Collections.emptyList();
        }
        return Arrays.stream(files).map(this::upload).filter(Objects::nonNull).collect(Collectors.toList());
    }

    @Override
    public FileObjectInfo save(File file) {
        if (file == null || !file.exists() || file.isDirectory()) {
            return null;
        }
        try (InputStream in = FileUtil.getInputStream(file)) {
            return doSave(in, file.getName(), file.length(), FileUtil.getMimeType(file.getName()));
        } catch (Exception e) {
            throw new IllegalStateException("文件保存失败: " + e.getMessage(), e);
        }
    }

    @Override
    public List<FileObjectInfo> save(List<File> files) {
        if (CollUtil.isEmpty(files)) {
            return Collections.emptyList();
        }
        return files.stream().map(this::save).filter(Objects::nonNull).collect(Collectors.toList());
    }

    @Override
    public FileObjectInfo save(InputStream inputStream, String fileName) {
        if (inputStream == null || StrUtil.isBlank(fileName)) {
            return null;
        }
        byte[] bytes = IoUtil.readBytes(inputStream);
        if (bytes.length == 0) {
            return null;
        }
        return save(bytes, fileName);
    }

    @Override
    public FileObjectInfo save(byte[] bytes, String fileName) {
        if (bytes == null || bytes.length == 0 || StrUtil.isBlank(fileName)) {
            return null;
        }
        return doSave(new ByteArrayInputStream(bytes), fileName, bytes.length, FileUtil.getMimeType(fileName));
    }

    @Override
    public void delete(String... paths) {
        if (paths == null) {
            return;
        }
        delete(Arrays.asList(paths));
    }

    @Override
    public void delete(List<String> paths) {
        if (CollUtil.isEmpty(paths)) {
            return;
        }
        for (String path : paths) {
            if (StrUtil.isBlank(path)) {
                continue;
            }
            client().delete(normalize(path));
            log.info("文件已删除: {}", path);
        }
    }

    @Override
    public boolean exist(String path) {
        return StrUtil.isNotBlank(path) && client().exists(normalize(path));
    }

    @Override
    public ResponseEntity<byte[]> download(String path) {
        return buildResponse(path, true);
    }

    @Override
    public ResponseEntity<byte[]> preview(String path) {
        return buildResponse(path, false);
    }

    @Override
    public InputStream getInputStream(String path) {
        if (!exist(path)) {
            log.warn("文件不存在: {}", path);
            return null;
        }
        return client().download(normalize(path));
    }

    @Override
    public byte[] readBytes(String path) {
        try (InputStream in = getInputStream(path)) {
            return in == null ? null : IoUtil.readBytes(in);
        } catch (Exception e) {
            throw new IllegalStateException("读取文件失败: " + path, e);
        }
    }

    @Override
    public String readBase64(String path) {
        byte[] bytes = readBytes(path);
        return bytes == null ? null : Base64.encode(bytes);
    }

    @Override
    public String getAccessUrl(String path) {
        return StrUtil.isBlank(path) ? null : client().getAccessUrl(normalize(path));
    }

    private FileObjectInfo doSave(InputStream in, String fileName, long size, String contentType) {
        String cleanName = FileUtil.cleanInvalid(fileName);
        String objectKey = buildObjectKey(cleanName);
        FileStorageClient storage = client();
        storage.upload(objectKey, in, size, contentType);
        log.info("文件保存成功: {}", objectKey);
        return FileObjectInfo.builder()
                .fileName(cleanName)
                .filePath(objectKey)
                .fileSize(size)
                .contentType(contentType)
                .accessUrl(storage.getAccessUrl(objectKey))
                .build();
    }

    private ResponseEntity<byte[]> buildResponse(String path, boolean attachment) {
        byte[] body = readBytes(path);
        if (body == null) {
            return ResponseEntity.notFound().build();
        }
        String fileName = FileUtil.getName(path);
        String encoded = URLEncoder.encode(fileName, StandardCharsets.UTF_8).replace("+", "%20");
        String disposition = (attachment ? "attachment" : "inline")
                + "; filename=\"" + fileName.replace("\"", "") + "\"; filename*=UTF-8''" + encoded;
        String mime = FileUtil.getMimeType(fileName);
        MediaType mediaType = StrUtil.isNotBlank(mime)
                ? MediaType.parseMediaType(mime)
                : MediaType.APPLICATION_OCTET_STREAM;
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, disposition)
                .contentType(mediaType)
                .contentLength(body.length)
                .body(body);
    }

    private static String buildObjectKey(String fileName) {
        return DateUtil.date().toString("yyyy/MM/dd") + "/" + IdUtil.simpleUUID() + "_" + fileName;
    }

    private static String normalize(String path) {
        return StrUtil.removePrefix(path.replace('\\', '/'), "/");
    }
}
