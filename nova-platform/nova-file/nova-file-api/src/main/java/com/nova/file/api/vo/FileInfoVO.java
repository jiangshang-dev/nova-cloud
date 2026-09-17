package com.nova.file.api.vo;

import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.time.LocalDateTime;

/**
 * 文件信息（服务间远程调用 VO，不含内部实现字段）。
 */
@Data
public class FileInfoVO implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long id;
    private Long tenantId;
    private Long storageId;
    private String fileName;
    private String fileSuffix;
    private String contentType;
    private Long fileSize;
    private String fileMd5;
    private String bucketName;
    private String objectKey;
    private String accessUrl;
    private String bizType;
    private String bizId;
    private Integer uploadStatus;
    private LocalDateTime gmtCreate;
}
