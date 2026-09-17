package com.nova.ai.core.domain.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("ai_model_provider")
public class AiModelProvider {
    @TableId
    private Long id;
    private Long tenantId;
    private String providerCode;
    private String providerName;
    private String baseUrl;
    private String apiKeyCipher;
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
