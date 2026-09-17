package com.nova.file.starter.model;

import lombok.Builder;
import lombok.Data;

/**
 * 运行时存储配置（来自管理后台 / DB，不写死在 yml）。
 */
@Data
@Builder
public class StorageConfig {

    private Long id;
    private String storageCode;
    private String storageName;
    /** local / minio / rustfs / oss / s3 */
    private String storageType;
    private String endpoint;
    private String region;
    private String accessKey;
    private String secretKey;
    private String bucketName;
    /** 本地存储根目录（仅 local 生效；S3/MinIO/OSS 忽略） */
    private String basePath;
    /** 对外访问域名，可含 http(s) */
    private String domain;
    /**
     * 扩展 JSON，例如：
     * {"pathStyle":true,"chunkTempDir":"/tmp/nova-chunks"}
     */
    private String extConfig;
}
