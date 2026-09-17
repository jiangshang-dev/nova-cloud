package com.nova.file.domain.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class UploadMergeRequest {
    @NotBlank
    private String uploadId;
}
