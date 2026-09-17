package com.nova.ai.agent.service;

import cn.hutool.core.util.StrUtil;
import com.nova.ai.core.dto.ChatRequest;
import com.nova.ai.core.dto.ChatResponse;
import com.nova.ai.core.service.AiModelConfigService;
import com.nova.ai.model.AiModelFactory;
import com.nova.ai.model.AiModelRuntimeConfig;
import io.agentscope.core.ReActAgent;
import io.agentscope.core.agent.RuntimeContext;
import io.agentscope.core.event.AgentEventType;
import io.agentscope.core.event.TextBlockDeltaEvent;
import io.agentscope.core.message.Msg;
import io.agentscope.core.message.UserMessage;
import io.agentscope.core.model.Model;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;

import java.util.List;

/**
 * 方案 A：ReActAgent 简单问答（无工作区，适合一次性/轻量对话）。
 */
@Service
@RequiredArgsConstructor
public class ReActChatService {

    private final AiModelConfigService modelConfigService;

    public ChatResponse chat(ChatRequest request) {
        AiModelRuntimeConfig config = resolveConfig(request);
        config.setStream(false);
        Model model = AiModelFactory.create(config);

        ReActAgent.Builder builder = ReActAgent.builder()
                .name("nova-react")
                .model(model);
        if (StrUtil.isNotBlank(request.getSysPrompt())) {
            builder.sysPrompt(request.getSysPrompt());
        }
        ReActAgent agent = builder.build();

        Msg result = agent.call(List.of(new UserMessage(request.getPrompt())), RuntimeContext.empty()).block();
        String content = result == null ? "" : result.getTextContent();
        return ChatResponse.builder()
                .content(content)
                .modelId(config.getModelId())
                .modelCode(config.getModelCode())
                .build();
    }

    public Flux<String> stream(ChatRequest request) {
        AiModelRuntimeConfig config = resolveConfig(request);
        config.setStream(true);
        Model model = AiModelFactory.create(config);

        ReActAgent.Builder builder = ReActAgent.builder()
                .name("nova-react-stream")
                .model(model);
        if (StrUtil.isNotBlank(request.getSysPrompt())) {
            builder.sysPrompt(request.getSysPrompt());
        }
        ReActAgent agent = builder.build();

        return agent.streamEvents(new UserMessage(request.getPrompt()))
                .filter(event -> event.getType() == AgentEventType.TEXT_BLOCK_DELTA)
                .map(event -> ((TextBlockDeltaEvent) event).getDelta())
                .filter(StrUtil::isNotBlank);
    }

    private AiModelRuntimeConfig resolveConfig(ChatRequest request) {
        if (request.getModelId() != null) {
            return modelConfigService.loadRuntimeConfig(request.getModelId());
        }
        if (StrUtil.isNotBlank(request.getModelCode())) {
            return modelConfigService.loadRuntimeConfigByCode(request.getModelCode());
        }
        // 默认取第一条启用 chat 模型
        var models = modelConfigService.listModels(null);
        if (models.isEmpty()) {
            throw new IllegalStateException("未配置可用 AI 模型，请先在 ai_model / ai_model_provider 中配置");
        }
        return modelConfigService.loadRuntimeConfig(models.get(0).getId());
    }
}
