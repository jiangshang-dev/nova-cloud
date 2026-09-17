package com.nova.ai.core.domain.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("ai_workflow")
public class AiWorkflow {
    @TableId
    private Long id;
    private Long tenantId;
    private String workflowCode;
    private String workflowName;
    private Integer version;
    private String graphJson;
    private Integer status;
    private Long createBy;
    private Long updateBy;
    @TableLogic
    private Integer isDeleted;
    private String remark;
    private LocalDateTime gmtCreate;
    private LocalDateTime gmtModified;
}
