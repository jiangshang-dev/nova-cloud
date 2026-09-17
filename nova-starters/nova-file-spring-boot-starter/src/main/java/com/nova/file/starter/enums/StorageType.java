package com.nova.file.starter.enums;

import lombok.Getter;

/**
 * 文件存储类型。minio / rustfs / oss / s3 统一走 AWS S3 SDK。
 */
@Getter
public enum StorageType {
    LOCAL("local", false),
    MINIO("minio", true),
    RUSTFS("rustfs", true),
    OSS("oss", true),
    S3("s3", true);

    private final String code;
    private final boolean s3Compatible;

    StorageType(String code, boolean s3Compatible) {
        this.code = code;
        this.s3Compatible = s3Compatible;
    }

    public static StorageType fromCode(String code) {
        if (code == null || code.isBlank()) {
            throw new IllegalArgumentException("storageType 不能为空");
        }
        for (StorageType type : values()) {
            if (type.code.equalsIgnoreCase(code.trim())) {
                return type;
            }
        }
        throw new IllegalArgumentException("不支持的存储类型: " + code);
    }
}
