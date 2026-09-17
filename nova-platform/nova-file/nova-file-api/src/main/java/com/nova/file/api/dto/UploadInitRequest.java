package com.nova.file.api.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

import java.io.Serial;
import java.io.Serializable;

@Data
public class UploadInitRequest implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

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
