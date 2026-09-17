package com.nova.file.domain.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class UploadInitRequest {
    @NotBlank
    private String fileName;
    @NotBlank
    private String fileMd5;
    @NotNull
    @Min(1)
    private Long fileSize;
    /** 分片大小，默认 5MB；S3 非末片需 >= 5MB */
    private Long chunkSize;
    private String contentType;
    private String bizType;
    private String bizId;
}
