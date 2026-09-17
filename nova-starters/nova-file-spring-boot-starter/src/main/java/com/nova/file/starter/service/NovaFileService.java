package com.nova.file.starter.service;

import com.nova.file.starter.model.FileObjectInfo;
import org.springframework.http.ResponseEntity;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.InputStream;
import java.util.List;

/**
 * 统一文件读写门面（参考 OSS Service 能力：Multipart / File / 流 / 字节）。
 * <p>
 * 存储来自文件服务管理后台启用的配置（{@code ActiveStorageHolder}），不在业务 yml 里再配一套。
 */
public interface NovaFileService {

    FileObjectInfo upload(MultipartFile file);

    List<FileObjectInfo> upload(MultipartFile[] files);

    FileObjectInfo save(File file);

    List<FileObjectInfo> save(List<File> files);

    FileObjectInfo save(InputStream inputStream, String fileName);

    FileObjectInfo save(byte[] bytes, String fileName);

    void delete(String... paths);

    void delete(List<String> paths);

    boolean exist(String path);

    ResponseEntity<byte[]> download(String path);

    ResponseEntity<byte[]> preview(String path);

    InputStream getInputStream(String path);

    byte[] readBytes(String path);

    String readBase64(String path);

    String getAccessUrl(String path);
}
