package com.nova.ai.model;

import lombok.Builder;
import lombok.Data;

/**
 * 运行时模型配置（来自 ai_model_provider + ai_model，不写死 yml）。
 */
@Data
@Builder
public class AiModelRuntimeConfig {

    private Long modelId;
    private Long providerId;
    /** dashscope / openai / anthropic / ollama */
    private String providerCode;
    /** 如 dashscope:qwen-plus 或 qwen-plus */
    private String modelCode;
    private String modelName;
    /** chat / embedding / image ... */
    private String modelType;
    private String apiKey;
    private String baseUrl;
    private Integer maxTokens;
    private boolean stream;
}
