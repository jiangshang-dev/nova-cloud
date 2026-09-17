package com.nova.file.starter.client;

import com.nova.file.starter.enums.StorageType;
import com.nova.file.starter.model.PartETagInfo;
import com.nova.file.starter.model.StorageConfig;

import java.io.InputStream;
import java.util.List;

/**
 * 统一文件存储客户端。S3 兼容存储优先走 multipart。
 */
public interface FileStorageClient extends AutoCloseable {

    StorageType type();

    StorageConfig config();

    void upload(String objectKey, InputStream in, long size, String contentType);

    InputStream download(String objectKey);

    void delete(String objectKey);

    boolean exists(String objectKey);

    /** 探测连通性（建桶/列桶/写探测文件等） */
    void ping();

    String getAccessUrl(String objectKey);

    String initiateMultipart(String objectKey, String contentType);

    String uploadPart(String objectKey, String uploadId, int partNumber, InputStream in, long size);

    void completeMultipart(String objectKey, String uploadId, List<PartETagInfo> parts);

    void abortMultipart(String objectKey, String uploadId);

    List<Integer> listUploadedParts(String objectKey, String uploadId);

    @Override
    default void close() {
        // no-op
    }
}
