package com.nova.ai.core.domain.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("ai_agent_session")
public class AiAgentSession {
    @TableId
    private Long id;
    private Long tenantId;
    private Long agentId;
    private String sessionId;
    private Long userId;
    private String title;
    private Integer status;
    private LocalDateTime lastMessageTime;
    private String extJson;
    private Long createBy;
    private Long updateBy;
    @TableLogic
    private Integer isDeleted;
    private LocalDateTime gmtCreate;
    private LocalDateTime gmtModified;
}
