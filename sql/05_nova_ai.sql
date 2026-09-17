-- =========================================================
-- AI 平台：模型 / Agent / 知识库 / RAG / 工作流 / 媒体任务
-- 规范：阿里巴巴 Java 开发手册 2.0 建表规约（无外键）
-- =========================================================
USE `nova_cloud`;

-- ----------------------------
-- 模型提供商
-- ----------------------------
DROP TABLE IF EXISTS `ai_model_provider`;
CREATE TABLE `ai_model_provider` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID，0表示平台',
  `provider_code`   VARCHAR(64)     NOT NULL COMMENT '提供商编码：dashscope/openai/anthropic/ollama',
  `provider_name`   VARCHAR(128)    NOT NULL COMMENT '提供商名称',
  `base_url`        VARCHAR(255)             DEFAULT NULL COMMENT '自定义Endpoint',
  `api_key_cipher`  VARCHAR(512)             DEFAULT NULL COMMENT 'API Key密文',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0停用 1正常',
  `ext_config`      JSON                     DEFAULT NULL COMMENT '扩展配置JSON',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_provider_code` (`tenant_id`, `provider_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='AI模型提供商表';

-- ----------------------------
-- 模型定义
-- ----------------------------
DROP TABLE IF EXISTS `ai_model`;
CREATE TABLE `ai_model` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `provider_id`     BIGINT UNSIGNED NOT NULL COMMENT '提供商ID',
  `model_code`      VARCHAR(128)    NOT NULL COMMENT '模型编码，如dashscope:qwen-plus',
  `model_name`      VARCHAR(128)    NOT NULL COMMENT '模型显示名',
  `model_type`      VARCHAR(32)     NOT NULL DEFAULT 'chat' COMMENT '类型：chat/embedding/image/video/rerank',
  `context_window`  INT UNSIGNED             DEFAULT NULL COMMENT '上下文窗口',
  `max_tokens`      INT UNSIGNED             DEFAULT NULL COMMENT '默认最大输出token',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0停用 1正常',
  `ext_config`      JSON                     DEFAULT NULL COMMENT '默认参数JSON',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_model_code` (`tenant_id`, `model_code`),
  KEY `idx_provider_id` (`provider_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='AI模型定义表';

-- ----------------------------
-- Agent 定义
-- ----------------------------
DROP TABLE IF EXISTS `ai_agent`;
CREATE TABLE `ai_agent` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `agent_code`      VARCHAR(64)     NOT NULL COMMENT 'Agent编码',
  `agent_name`      VARCHAR(128)    NOT NULL COMMENT 'Agent名称',
  `model_id`        BIGINT UNSIGNED          DEFAULT NULL COMMENT '默认模型ID',
  `sys_prompt`      MEDIUMTEXT               COMMENT '系统提示词',
  `workspace_path`  VARCHAR(512)             DEFAULT NULL COMMENT '工作区路径',
  `compaction_json` JSON                     DEFAULT NULL COMMENT '压缩策略配置JSON',
  `tools_json`      JSON                     DEFAULT NULL COMMENT '工具声明JSON',
  `skills_json`     JSON                     DEFAULT NULL COMMENT '技能配置JSON',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0停用 1正常',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_agent_code` (`tenant_id`, `agent_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='AI Agent定义表';

-- ----------------------------
-- Agent 会话
-- ----------------------------
DROP TABLE IF EXISTS `ai_agent_session`;
CREATE TABLE `ai_agent_session` (
  `id`                BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`         BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `agent_id`          BIGINT UNSIGNED NOT NULL COMMENT 'AgentID',
  `session_id`        VARCHAR(128)    NOT NULL COMMENT '会话业务ID',
  `user_id`           BIGINT UNSIGNED          DEFAULT NULL COMMENT '业务用户ID',
  `title`             VARCHAR(255)             DEFAULT NULL COMMENT '会话标题',
  `status`            TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0关闭 1进行中',
  `last_message_time` DATETIME                 DEFAULT NULL COMMENT '最后消息时间',
  `ext_json`          JSON                     DEFAULT NULL COMMENT '扩展信息JSON',
  `create_by`         BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`         BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`        TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `gmt_create`        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_agent_session` (`tenant_id`, `agent_id`, `session_id`),
  KEY `idx_tenant_user` (`tenant_id`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='AI Agent会话表';

-- ----------------------------
-- Agent 消息
-- ----------------------------
DROP TABLE IF EXISTS `ai_agent_message`;
CREATE TABLE `ai_agent_message` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `session_pk`      BIGINT UNSIGNED NOT NULL COMMENT '会话表主键',
  `role`            VARCHAR(32)     NOT NULL COMMENT '角色：user/assistant/system/tool',
  `content`         MEDIUMTEXT               COMMENT '消息内容',
  `content_blocks`  JSON                     DEFAULT NULL COMMENT '多模态或工具调用块JSON',
  `token_usage`     JSON                     DEFAULT NULL COMMENT 'token统计JSON',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  KEY `idx_session_create` (`session_pk`, `gmt_create`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='AI Agent消息表';

-- ----------------------------
-- 知识库
-- ----------------------------
DROP TABLE IF EXISTS `ai_knowledge_base`;
CREATE TABLE `ai_knowledge_base` (
  `id`                 BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`          BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `kb_code`            VARCHAR(64)     NOT NULL COMMENT '知识库编码',
  `kb_name`            VARCHAR(128)    NOT NULL COMMENT '知识库名称',
  `embedding_model_id` BIGINT UNSIGNED          DEFAULT NULL COMMENT '向量模型ID',
  `index_name`         VARCHAR(128)             DEFAULT NULL COMMENT '检索索引名',
  `chunk_size`         INT UNSIGNED    NOT NULL DEFAULT 500 COMMENT '默认分片大小',
  `chunk_overlap`      INT UNSIGNED    NOT NULL DEFAULT 50 COMMENT '分片重叠长度',
  `status`             TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0停用 1正常',
  `create_by`          BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`          BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`         TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`             VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`         DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_kb_code` (`tenant_id`, `kb_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='知识库表';

-- ----------------------------
-- 知识库文档
-- ----------------------------
DROP TABLE IF EXISTS `ai_knowledge_doc`;
CREATE TABLE `ai_knowledge_doc` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `kb_id`           BIGINT UNSIGNED NOT NULL COMMENT '知识库ID',
  `file_id`         BIGINT UNSIGNED          DEFAULT NULL COMMENT '文件ID',
  `doc_name`        VARCHAR(255)    NOT NULL COMMENT '文档名',
  `doc_type`        VARCHAR(32)              DEFAULT NULL COMMENT '类型：pdf/md/docx/html/url',
  `source_url`      VARCHAR(1000)            DEFAULT NULL COMMENT '来源URL',
  `parse_status`    TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '解析状态：0待处理 1处理中 2成功 3失败',
  `chunk_count`     INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT '分片数',
  `error_msg`       VARCHAR(1000)            DEFAULT NULL COMMENT '失败原因',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  KEY `idx_kb_id` (`kb_id`),
  KEY `idx_parse_status` (`parse_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='知识库文档表';

-- ----------------------------
-- 知识库分片
-- ----------------------------
DROP TABLE IF EXISTS `ai_knowledge_chunk`;
CREATE TABLE `ai_knowledge_chunk` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `kb_id`           BIGINT UNSIGNED NOT NULL COMMENT '知识库ID',
  `doc_id`          BIGINT UNSIGNED NOT NULL COMMENT '文档ID',
  `chunk_index`     INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT '分片序号',
  `content`         MEDIUMTEXT      NOT NULL COMMENT '分片文本',
  `token_count`     INT UNSIGNED             DEFAULT NULL COMMENT 'token数',
  `vector_id`       VARCHAR(128)             DEFAULT NULL COMMENT '向量库文档ID',
  `metadata_json`   JSON                     DEFAULT NULL COMMENT '元数据JSON',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  KEY `idx_doc_chunk` (`doc_id`, `chunk_index`),
  KEY `idx_kb_id` (`kb_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='知识库分片表';

-- ----------------------------
-- RAG 问答日志
-- ----------------------------
DROP TABLE IF EXISTS `ai_rag_query_log`;
CREATE TABLE `ai_rag_query_log` (
  `id`               BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`        BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `kb_id`            BIGINT UNSIGNED          DEFAULT NULL COMMENT '知识库ID',
  `user_id`          BIGINT UNSIGNED          DEFAULT NULL COMMENT '用户ID',
  `question`         TEXT            NOT NULL COMMENT '问题',
  `answer`           MEDIUMTEXT               COMMENT '回答',
  `retrieved_chunks` JSON                     DEFAULT NULL COMMENT '召回分片JSON',
  `model_code`       VARCHAR(128)             DEFAULT NULL COMMENT '使用模型编码',
  `latency_ms`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '耗时，单位毫秒',
  `gmt_create`       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  KEY `idx_kb_create` (`kb_id`, `gmt_create`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='RAG问答日志表';

-- ----------------------------
-- 工作流定义
-- ----------------------------
DROP TABLE IF EXISTS `ai_workflow`;
CREATE TABLE `ai_workflow` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `workflow_code`   VARCHAR(64)     NOT NULL COMMENT '工作流编码',
  `workflow_name`   VARCHAR(128)    NOT NULL COMMENT '工作流名称',
  `version`         INT UNSIGNED    NOT NULL DEFAULT 1 COMMENT '版本号',
  `graph_json`      JSON                     DEFAULT NULL COMMENT '画布完整JSON',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0草稿 1已发布 2停用',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_workflow_ver` (`tenant_id`, `workflow_code`, `version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='AI工作流定义表';

-- ----------------------------
-- 工作流节点
-- ----------------------------
DROP TABLE IF EXISTS `ai_workflow_node`;
CREATE TABLE `ai_workflow_node` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `workflow_id`     BIGINT UNSIGNED NOT NULL COMMENT '工作流ID',
  `node_key`        VARCHAR(64)     NOT NULL COMMENT '节点唯一键',
  `node_type`       VARCHAR(64)     NOT NULL COMMENT '类型：start/llm/agent/rag/tool/condition/end',
  `node_name`       VARCHAR(128)             DEFAULT NULL COMMENT '节点名称',
  `config_json`     JSON                     DEFAULT NULL COMMENT '节点配置JSON',
  `position_x`      INT                      DEFAULT NULL COMMENT '画布X坐标',
  `position_y`      INT                      DEFAULT NULL COMMENT '画布Y坐标',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_workflow_node` (`workflow_id`, `node_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='AI工作流节点表';

-- ----------------------------
-- 工作流连线
-- ----------------------------
DROP TABLE IF EXISTS `ai_workflow_edge`;
CREATE TABLE `ai_workflow_edge` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `workflow_id`     BIGINT UNSIGNED NOT NULL COMMENT '工作流ID',
  `edge_key`        VARCHAR(64)     NOT NULL COMMENT '边唯一键',
  `source_node_key` VARCHAR(64)     NOT NULL COMMENT '源节点键',
  `target_node_key` VARCHAR(64)     NOT NULL COMMENT '目标节点键',
  `condition_expr`  VARCHAR(512)             DEFAULT NULL COMMENT '条件表达式',
  `config_json`     JSON                     DEFAULT NULL COMMENT '扩展配置JSON',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_workflow_edge` (`workflow_id`, `edge_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='AI工作流连线表';

-- ----------------------------
-- 工作流运行记录
-- ----------------------------
DROP TABLE IF EXISTS `ai_workflow_run`;
CREATE TABLE `ai_workflow_run` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `workflow_id`     BIGINT UNSIGNED NOT NULL COMMENT '工作流ID',
  `run_no`          VARCHAR(64)     NOT NULL COMMENT '运行编号',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0排队 1运行中 2成功 3失败 4取消',
  `input_json`      JSON                     DEFAULT NULL COMMENT '输入JSON',
  `output_json`     JSON                     DEFAULT NULL COMMENT '输出JSON',
  `error_msg`       VARCHAR(2000)            DEFAULT NULL COMMENT '错误信息',
  `start_time`      DATETIME                 DEFAULT NULL COMMENT '开始时间',
  `end_time`        DATETIME                 DEFAULT NULL COMMENT '结束时间',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_run_no` (`run_no`),
  KEY `idx_workflow_create` (`workflow_id`, `gmt_create`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='AI工作流运行记录表';

-- ----------------------------
-- 媒体生成任务
-- ----------------------------
DROP TABLE IF EXISTS `ai_media_task`;
CREATE TABLE `ai_media_task` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `task_no`         VARCHAR(64)     NOT NULL COMMENT '任务编号',
  `media_type`      VARCHAR(32)     NOT NULL COMMENT '类型：image/video/doc',
  `model_code`      VARCHAR(128)             DEFAULT NULL COMMENT '模型编码',
  `prompt`          TEXT                     COMMENT '提示词',
  `params_json`     JSON                     DEFAULT NULL COMMENT '生成参数JSON',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0排队 1处理中 2成功 3失败',
  `result_file_ids` VARCHAR(1000)            DEFAULT NULL COMMENT '结果文件ID，逗号分隔',
  `result_urls`     TEXT                     COMMENT '结果URL',
  `error_msg`       VARCHAR(2000)            DEFAULT NULL COMMENT '错误信息',
  `mq_msg_id`       VARCHAR(128)             DEFAULT NULL COMMENT 'MQ消息ID',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_task_no` (`task_no`),
  KEY `idx_tenant_status_create` (`tenant_id`, `status`, `gmt_create`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='AI媒体生成任务表';
