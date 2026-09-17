package com.nova.ai.model;

import cn.hutool.core.util.StrUtil;
import io.agentscope.core.model.Model;
import io.agentscope.core.model.ModelCreationContext;
import io.agentscope.core.model.ModelRegistry;
import io.agentscope.extensions.model.dashscope.DashScopeChatModel;
import io.agentscope.extensions.model.dashscope.formatter.DashScopeChatFormatter;
import io.agentscope.extensions.model.ollama.OllamaChatModel;
import io.agentscope.extensions.model.openai.OpenAIChatModel;
import io.agentscope.extensions.model.openai.formatter.OpenAIChatFormatter;

/**
 * 根据库表配置创建 AgentScope {@link Model}。
 * <p>
 * 优先 {@link ModelRegistry#resolve(String, ModelCreationContext)}；失败时回退到显式 builder。
 */
public final class AiModelFactory {

    private AiModelFactory() {
    }

    public static Model create(AiModelRuntimeConfig config) {
        if (config == null) {
            throw new IllegalArgumentException("模型配置不能为空");
        }
        String provider = StrUtil.blankToDefault(config.getProviderCode(), "").toLowerCase();
        String modelName = resolveModelName(config);
        String apiKey = resolveApiKey(config, provider);
        String modelId = resolveModelId(config, provider, modelName);

        try {
            ModelCreationContext.Builder ctx = ModelCreationContext.builder().stream(config.isStream());
            if (StrUtil.isNotBlank(apiKey)) {
                ctx.apiKey(apiKey);
            }
            if (StrUtil.isNotBlank(config.getBaseUrl())) {
                ctx.baseUrl(config.getBaseUrl());
            }
            return ModelRegistry.resolve(modelId, ctx.build());
        } catch (Exception ignored) {
            // 回退显式 builder
        }
        return createByBuilder(provider, modelName, apiKey, config);
    }

    private static Model createByBuilder(String provider, String modelName, String apiKey, AiModelRuntimeConfig config) {
        return switch (provider) {
            case "dashscope" -> DashScopeChatModel.builder()
                    .apiKey(apiKey)
                    .modelName(modelName)
                    .stream(config.isStream())
                    .formatter(new DashScopeChatFormatter())
                    .build();
            case "openai", "deepseek", "kimi" -> {
                var builder = OpenAIChatModel.builder()
                        .apiKey(apiKey)
                        .modelName(modelName)
                        .stream(config.isStream())
                        .formatter(new OpenAIChatFormatter());
                if (StrUtil.isNotBlank(config.getBaseUrl())) {
                    builder.baseUrl(config.getBaseUrl());
                }
                yield builder.build();
            }
            case "ollama" -> {
                var builder = OllamaChatModel.builder()
                        .modelName(modelName)
                        .stream(config.isStream());
                if (StrUtil.isNotBlank(config.getBaseUrl())) {
                    builder.baseUrl(config.getBaseUrl());
                }
                yield builder.build();
            }
            default -> throw new IllegalArgumentException("暂不支持的模型提供商: " + provider);
        };
    }

    private static String resolveModelId(AiModelRuntimeConfig config, String provider, String modelName) {
        String code = config.getModelCode();
        if (StrUtil.isNotBlank(code) && code.contains(":")) {
            return code;
        }
        return provider + ":" + modelName;
    }

    private static String resolveModelName(AiModelRuntimeConfig config) {
        String code = config.getModelCode();
        if (StrUtil.isNotBlank(code) && code.contains(":")) {
            return code.substring(code.indexOf(':') + 1);
        }
        if (StrUtil.isNotBlank(code)) {
            return code;
        }
        return config.getModelName();
    }

    private static String resolveApiKey(AiModelRuntimeConfig config, String provider) {
        if (StrUtil.isNotBlank(config.getApiKey())) {
            return config.getApiKey();
        }
        return switch (provider) {
            case "dashscope" -> System.getenv("DASHSCOPE_API_KEY");
            case "openai" -> System.getenv("OPENAI_API_KEY");
            case "deepseek" -> System.getenv("DEEPSEEK_API_KEY");
            case "anthropic" -> System.getenv("ANTHROPIC_API_KEY");
            default -> null;
        };
    }
}
