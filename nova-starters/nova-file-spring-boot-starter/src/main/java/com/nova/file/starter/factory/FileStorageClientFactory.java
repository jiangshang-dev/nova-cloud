package com.nova.file.starter.factory;

import com.nova.file.starter.client.FileStorageClient;
import com.nova.file.starter.client.LocalFileStorageClient;
import com.nova.file.starter.client.S3FileStorageClient;
import com.nova.file.starter.enums.StorageType;
import com.nova.file.starter.model.StorageConfig;

/**
 * 按管理后台配置创建存储客户端。
 */
public class FileStorageClientFactory {

    public FileStorageClient create(StorageConfig config) {
        StorageType type = StorageType.fromCode(config.getStorageType());
        return switch (type) {
            case LOCAL -> new LocalFileStorageClient(config);
            case MINIO, RUSTFS, OSS, S3 -> new S3FileStorageClient(config);
        };
    }
}
