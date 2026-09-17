package com.nova.ai.controller;

import com.nova.ai.agent.service.HarnessAgentChatService;
import com.nova.ai.agent.service.ReActChatService;
import com.nova.ai.core.domain.entity.AiAgentMessage;
import com.nova.ai.core.domain.entity.AiAgentSession;
import com.nova.ai.core.dto.AgentChatRequest;
import com.nova.ai.core.dto.ChatRequest;
import com.nova.ai.core.dto.ChatResponse;
import com.nova.core.debounce.annotation.Debounce;
import com.nova.core.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import reactor.core.publisher.Flux;

import java.util.List;

@Tag(name = "AI 对话")
@RestController
@RequestMapping("/ai")
@RequiredArgsConstructor
public class AiChatController {

    private final ReActChatService reActChatService;
    private final HarnessAgentChatService harnessAgentChatService;

    @Debounce
    @Operation(summary = "方案A：ReAct 简单问答")
    @PostMapping("/chat")
    public R<ChatResponse> chat(@Valid @RequestBody ChatRequest request) {
        return R.ok(reActChatService.chat(request));
    }

    @Operation(summary = "方案A：ReAct 流式问答（SSE）")
    @PostMapping(value = "/chat/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<String> chatStream(@Valid @RequestBody ChatRequest request) {
        return reActChatService.stream(request);
    }

    @Debounce
    @Operation(summary = "方案B：Harness 多轮会话")
    @PostMapping("/agent/chat")
    public R<ChatResponse> agentChat(@Valid @RequestBody AgentChatRequest request) {
        return R.ok(harnessAgentChatService.chat(request));
    }

    @Operation(summary = "方案B：Harness 多轮会话流式（SSE）")
    @PostMapping(value = "/agent/chat/stream", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public Flux<ChatResponse> agentChatStream(@Valid @RequestBody AgentChatRequest request) {
        return harnessAgentChatService.stream(request);
    }

    @Operation(summary = "会话列表")
    @GetMapping("/agent/session/list")
    public R<List<AiAgentSession>> sessions(@RequestParam(defaultValue = "default") String agentCode,
                                            @RequestParam(required = false) Long userId) {
        return R.ok(harnessAgentChatService.listSessions(agentCode, userId));
    }

    @Operation(summary = "会话消息")
    @GetMapping("/agent/session/{sessionPk}/messages")
    public R<List<AiAgentMessage>> messages(@PathVariable Long sessionPk) {
        return R.ok(harnessAgentChatService.listMessages(sessionPk));
    }
}
