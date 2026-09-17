package com.nova.file.domain.dto;

import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class UploadInitResponse {
    /** 秒传命中 */
    private boolean skipUpload;
    private Long fileId;
    private String accessUrl;
    private String uploadId;
    private String objectKey;
    private long chunkSize;
    private int chunkTotal;
    private List<Integer> uploadedChunks;
}
