package com.nova.ai.core.domain.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("ai_knowledge_base")
public class AiKnowledgeBase {
    @TableId
    private Long id;
    private Long tenantId;
    private String kbCode;
    private String kbName;
    private Long embeddingModelId;
    private String indexName;
    private Integer chunkSize;
    private Integer chunkOverlap;
    private Integer status;
    private Long createBy;
    private Long updateBy;
    @TableLogic
    private Integer isDeleted;
    private String remark;
    private LocalDateTime gmtCreate;
    private LocalDateTime gmtModified;
}
