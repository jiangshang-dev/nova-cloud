package com.nova.ai.core.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class AgentChatRequest {
    /** Agent 编码，默认 default */
    private String agentCode = "default";
    @NotBlank
    private String prompt;
    /** 会话业务 ID，不传则新建 */
    private String sessionId;
    private Long userId;
}
