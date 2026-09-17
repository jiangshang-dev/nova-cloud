package com.nova.ai.core.dto;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class ChatResponse {
    private String content;
    private Long modelId;
    private String modelCode;
    private String sessionId;
    private Long sessionPk;
}
