package com.nova.ai.core.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ChatRequest {
    /** 优先用 modelId；为空则用 modelCode */
    private Long modelId;
    private String modelCode;
    @NotBlank
    private String prompt;
    private String sysPrompt;
    private Boolean stream;
}
