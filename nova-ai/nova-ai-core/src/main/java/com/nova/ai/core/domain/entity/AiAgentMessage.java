package com.nova.ai.core.domain.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("ai_agent_message")
public class AiAgentMessage {
    @TableId
    private Long id;
    private Long tenantId;
    private Long sessionPk;
    private String role;
    private String content;
    private String contentBlocks;
    private String tokenUsage;
    private LocalDateTime gmtCreate;
    private LocalDateTime gmtModified;
}
