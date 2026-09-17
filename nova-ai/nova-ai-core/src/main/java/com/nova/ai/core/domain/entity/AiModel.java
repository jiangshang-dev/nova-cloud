package com.nova.ai.core.domain.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("ai_model")
public class AiModel {
    @TableId
    private Long id;
    private Long tenantId;
    private Long providerId;
    private String modelCode;
    private String modelName;
    private String modelType;
    private Integer contextWindow;
    private Integer maxTokens;
    private Integer status;
    private String extConfig;
    private Long createBy;
    private Long updateBy;
    @TableLogic
    private Integer isDeleted;
    private String remark;
    private LocalDateTime gmtCreate;
    private LocalDateTime gmtModified;
}
