package com.nova.file.api.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serial;
import java.io.Serializable;
import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UploadInitResponse implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

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
