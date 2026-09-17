package com.nova.ai.agent.service;

import cn.hutool.core.util.IdUtil;
import cn.hutool.core.util.StrUtil;
import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nova.ai.core.domain.entity.AiAgent;
import com.nova.ai.core.domain.entity.AiAgentMessage;
import com.nova.ai.core.domain.entity.AiAgentSession;
import com.nova.ai.core.dto.AgentChatRequest;
import com.nova.ai.core.dto.ChatResponse;
import com.nova.ai.core.mapper.AiAgentMapper;
import com.nova.ai.core.mapper.AiAgentMessageMapper;
import com.nova.ai.core.mapper.AiAgentSessionMapper;
import com.nova.ai.core.service.AiModelConfigService;
import com.nova.ai.model.AiModelFactory;
import com.nova.ai.model.AiModelRuntimeConfig;
import com.nova.ai.starter.config.NovaAiProperties;
import com.nova.core.utils.AssertUtil;
import com.nova.core.utils.IdGeneratorUtil;
import io.agentscope.core.agent.RuntimeContext;
import io.agentscope.core.event.AgentEventType;
import io.agentscope.core.event.TextBlockDeltaEvent;
import io.agentscope.core.message.Msg;
import io.agentscope.core.message.UserMessage;
import io.agentscope.core.model.Model;
import io.agentscope.harness.agent.HarnessAgent;
import io.agentscope.harness.agent.memory.compaction.CompactionConfig;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import reactor.core.publisher.Flux;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicReference;

/**
 * 方案 B：HarnessAgent 多轮会话（工作区 + RuntimeContext 会话隔离）。
 */
@Service
@RequiredArgsConstructor
public class HarnessAgentChatService {

    private final AiAgentMapper agentMapper;
    private final AiAgentSessionMapper sessionMapper;
    private final AiAgentMessageMapper messageMapper;
    private final AiModelConfigService modelConfigService;
    private final NovaAiProperties aiProperties;

    private final Map<String, HarnessAgent> agentCache = new ConcurrentHashMap<>();

    @Transactional(rollbackFor = Exception.class)
    public ChatResponse chat(AgentChatRequest request) {
        PreparedChat prepared = prepare(request, false);
        Msg result = prepared.agent().call(new UserMessage(request.getPrompt()), prepared.ctx()).block();
        String content = result == null ? "" : result.getTextContent();
        finishAssistant(prepared, content);
        return toResponse(prepared, content);
    }

    /**
     * 流式多轮会话：每个 TEXT_BLOCK_DELTA 推一条 {@link ChatResponse}（content 为增量片段）。
     */
    public Flux<ChatResponse> stream(AgentChatRequest request) {
        PreparedChat prepared = prepare(request, true);
        AtomicReference<StringBuilder> buffer = new AtomicReference<>(new StringBuilder());

        return prepared.agent()
                .streamEvents(new UserMessage(request.getPrompt()), prepared.ctx())
                .filter(event -> event.getType() == AgentEventType.TEXT_BLOCK_DELTA)
                .map(event -> {
                    String delta = ((TextBlockDeltaEvent) event).getDelta();
                    if (StrUtil.isNotBlank(delta)) {
                        buffer.get().append(delta);
                    }
                    return toResponse(prepared, StrUtil.nullToEmpty(delta));
                })
                .filter(resp -> StrUtil.isNotBlank(resp.getContent()))
                .doOnComplete(() -> finishAssistant(prepared, buffer.get().toString()))
                .doOnError(err -> finishAssistant(prepared, buffer.get().toString()));
    }

    public List<AiAgentSession> listSessions(String agentCode, Long userId) {
        AiAgent agent = requireAgent(agentCode);
        return sessionMapper.selectList(new LambdaQueryWrapper<AiAgentSession>()
                .eq(AiAgentSession::getAgentId, agent.getId())
                .eq(userId != null, AiAgentSession::getUserId, userId)
                .orderByDesc(AiAgentSession::getLastMessageTime));
    }

    public List<AiAgentMessage> listMessages(Long sessionPk) {
        return messageMapper.selectList(new LambdaQueryWrapper<AiAgentMessage>()
                .eq(AiAgentMessage::getSessionPk, sessionPk)
                .orderByAsc(AiAgentMessage::getGmtCreate));
    }

    private PreparedChat prepare(AgentChatRequest request, boolean stream) {
        AiAgent agentDef = requireAgent(request.getAgentCode());
        AssertUtil.notNull(agentDef.getModelId(), "Agent 未绑定模型");

        AiModelRuntimeConfig modelConfig = modelConfigService.loadRuntimeConfig(agentDef.getModelId());
        modelConfig.setStream(stream);
        HarnessAgent agent = getOrCreateHarness(agentDef, modelConfig, stream);

        String sessionId = StrUtil.blankToDefault(request.getSessionId(), IdUtil.simpleUUID());
        Long userId = request.getUserId() == null ? 0L : request.getUserId();
        AiAgentSession session = getOrCreateSession(agentDef.getId(), sessionId, userId, request.getPrompt());
        saveMessage(session.getId(), "user", request.getPrompt());

        RuntimeContext ctx = RuntimeContext.builder()
                .sessionId(sessionId)
                .userId(String.valueOf(userId))
                .build();
        return new PreparedChat(agent, ctx, modelConfig, sessionId, session.getId());
    }

    private void finishAssistant(PreparedChat prepared, String content) {
        saveMessage(prepared.sessionPk(), "assistant", StrUtil.nullToEmpty(content));
        AiAgentSession session = sessionMapper.selectById(prepared.sessionPk());
        if (session != null) {
            session.setLastMessageTime(LocalDateTime.now());
            sessionMapper.updateById(session);
        }
    }

    private static ChatResponse toResponse(PreparedChat prepared, String content) {
        return ChatResponse.builder()
                .content(content)
                .modelId(prepared.modelConfig().getModelId())
                .modelCode(prepared.modelConfig().getModelCode())
                .sessionId(prepared.sessionId())
                .sessionPk(prepared.sessionPk())
                .build();
    }

    private HarnessAgent getOrCreateHarness(AiAgent agentDef, AiModelRuntimeConfig modelConfig, boolean stream) {
        String cacheKey = agentDef.getAgentCode() + ":" + modelConfig.getModelId() + ":" + stream;
        return agentCache.computeIfAbsent(cacheKey, k -> {
            Model model = AiModelFactory.create(modelConfig);
            Path workspace = Paths.get(StrUtil.blankToDefault(agentDef.getWorkspacePath(), aiProperties.getWorkspace()));
            return HarnessAgent.builder()
                    .name(agentDef.getAgentCode())
                    .sysPrompt(StrUtil.blankToDefault(agentDef.getSysPrompt(), "你是 NovaCloud 智能助手。"))
                    .model(model)
                    .workspace(workspace)
                    .compaction(CompactionConfig.builder()
                            .triggerMessages(aiProperties.getCompactionTriggerMessages())
                            .keepMessages(aiProperties.getCompactionKeepMessages())
                            .build())
                    .build();
        });
    }

    private AiAgent requireAgent(String agentCode) {
        String code = StrUtil.blankToDefault(agentCode, "default");
        AiAgent agent = agentMapper.selectOne(new LambdaQueryWrapper<AiAgent>()
                .eq(AiAgent::getAgentCode, code)
                .eq(AiAgent::getStatus, 1)
                .last("LIMIT 1"));
        AssertUtil.notNull(agent, "Agent 不存在或已停用: " + code);
        return agent;
    }

    private AiAgentSession getOrCreateSession(Long agentId, String sessionId, Long userId, String prompt) {
        AiAgentSession session = sessionMapper.selectOne(new LambdaQueryWrapper<AiAgentSession>()
                .eq(AiAgentSession::getAgentId, agentId)
                .eq(AiAgentSession::getSessionId, sessionId)
                .last("LIMIT 1"));
        if (session != null) {
            return session;
        }
        session = new AiAgentSession();
        session.setId(IdGeneratorUtil.nextId());
        session.setTenantId(0L);
        session.setAgentId(agentId);
        session.setSessionId(sessionId);
        session.setUserId(userId);
        session.setTitle(StrUtil.sub(prompt, 0, Math.min(50, StrUtil.length(prompt))));
        session.setStatus(1);
        session.setLastMessageTime(LocalDateTime.now());
        session.setIsDeleted(0);
        sessionMapper.insert(session);
        return session;
    }

    private void saveMessage(Long sessionPk, String role, String content) {
        AiAgentMessage message = new AiAgentMessage();
        message.setId(IdGeneratorUtil.nextId());
        message.setTenantId(0L);
        message.setSessionPk(sessionPk);
        message.setRole(role);
        message.setContent(content);
        messageMapper.insert(message);
    }

    private record PreparedChat(
            HarnessAgent agent,
            RuntimeContext ctx,
            AiModelRuntimeConfig modelConfig,
            String sessionId,
            Long sessionPk
    ) {
    }
}
