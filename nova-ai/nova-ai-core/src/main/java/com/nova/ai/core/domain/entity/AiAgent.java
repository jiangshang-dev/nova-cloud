package com.nova.ai.core.domain.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("ai_agent")
public class AiAgent {
    @TableId
    private Long id;
    private Long tenantId;
    private String agentCode;
    private String agentName;
    private Long modelId;
    private String sysPrompt;
    private String workspacePath;
    private String compactionJson;
    private String toolsJson;
    private String skillsJson;
    private Integer status;
    private Long createBy;
    private Long updateBy;
    @TableLogic
    private Integer isDeleted;
    private String remark;
    private LocalDateTime gmtCreate;
    private LocalDateTime gmtModified;
}
