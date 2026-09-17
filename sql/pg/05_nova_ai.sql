-- =========================================================
-- NovaCloud PostgreSQL 脚本（由 MySQL 版对照生成）
-- 源文件: sql/05_nova_ai.sql
-- PostgreSQL 14+
-- 约定：
-- 1. 表名小写；必备 id / gmt_create / gmt_modified
-- 2. id 为 BIGINT，应用侧雪花 ID（不用 SERIAL）
-- 3. 原 TINYINT UNSIGNED → SMALLINT；BIGINT/INTEGER UNSIGNED → BIGINT/INTEGER
-- 4. DATETIME → TIMESTAMP；无 ON UPDATE（由应用更新 gmt_modified）
-- 5. 禁止外键；注释使用 COMMENT ON
-- =========================================================

-- 请先连接到 nova_cloud

-- =========================================================
-- AI 平台：模型 / Agent / 知识库 / RAG / 工作流 / 媒体任务
-- 规范：阿里巴巴 Java 开发手册 2.0 建表规约（无外键）
-- =========================================================
-- ----------------------------
-- 模型提供商
-- ----------------------------

DROP TABLE IF EXISTS ai_model_provider CASCADE;
CREATE TABLE ai_model_provider (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  provider_code   VARCHAR(64)     NOT NULL,
  provider_name   VARCHAR(128)    NOT NULL,
  base_url        VARCHAR(255)             DEFAULT NULL,
  api_key_cipher  VARCHAR(512)             DEFAULT NULL,
  status          SMALLINT NOT NULL DEFAULT 1,
  ext_config      JSON                     DEFAULT NULL,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_model_provider PRIMARY KEY (id),
  CONSTRAINT uk_tenant_provider_code UNIQUE (tenant_id, provider_code)
);
COMMENT ON TABLE ai_model_provider IS 'AI模型提供商表';
COMMENT ON COLUMN ai_model_provider.id IS '主键';
COMMENT ON COLUMN ai_model_provider.tenant_id IS '租户ID，0表示平台';
COMMENT ON COLUMN ai_model_provider.provider_code IS '提供商编码：dashscope/openai/anthropic/ollama';
COMMENT ON COLUMN ai_model_provider.provider_name IS '提供商名称';
COMMENT ON COLUMN ai_model_provider.base_url IS '自定义Endpoint';
COMMENT ON COLUMN ai_model_provider.api_key_cipher IS 'API Key密文';
COMMENT ON COLUMN ai_model_provider.status IS '状态：0停用 1正常';
COMMENT ON COLUMN ai_model_provider.ext_config IS '扩展配置JSON';
COMMENT ON COLUMN ai_model_provider.create_by IS '创建人';
COMMENT ON COLUMN ai_model_provider.update_by IS '修改人';
COMMENT ON COLUMN ai_model_provider.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN ai_model_provider.remark IS '备注';
COMMENT ON COLUMN ai_model_provider.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_model_provider.gmt_modified IS '修改时间';

-- ----------------------------
-- 模型定义
-- ----------------------------

DROP TABLE IF EXISTS ai_model CASCADE;
CREATE TABLE ai_model (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  provider_id     BIGINT NOT NULL,
  model_code      VARCHAR(128)    NOT NULL,
  model_name      VARCHAR(128)    NOT NULL,
  model_type      VARCHAR(32)     NOT NULL DEFAULT 'chat',
  context_window  INTEGER             DEFAULT NULL,
  max_tokens      INTEGER             DEFAULT NULL,
  status          SMALLINT NOT NULL DEFAULT 1,
  ext_config      JSON                     DEFAULT NULL,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_model PRIMARY KEY (id),
  CONSTRAINT uk_tenant_model_code UNIQUE (tenant_id, model_code)
);
COMMENT ON TABLE ai_model IS 'AI模型定义表';
COMMENT ON COLUMN ai_model.id IS '主键';
COMMENT ON COLUMN ai_model.tenant_id IS '租户ID';
COMMENT ON COLUMN ai_model.provider_id IS '提供商ID';
COMMENT ON COLUMN ai_model.model_code IS '模型编码，如dashscope:qwen-plus';
COMMENT ON COLUMN ai_model.model_name IS '模型显示名';
COMMENT ON COLUMN ai_model.model_type IS '类型：chat/embedding/image/video/rerank';
COMMENT ON COLUMN ai_model.context_window IS '上下文窗口';
COMMENT ON COLUMN ai_model.max_tokens IS '默认最大输出token';
COMMENT ON COLUMN ai_model.status IS '状态：0停用 1正常';
COMMENT ON COLUMN ai_model.ext_config IS '默认参数JSON';
COMMENT ON COLUMN ai_model.create_by IS '创建人';
COMMENT ON COLUMN ai_model.update_by IS '修改人';
COMMENT ON COLUMN ai_model.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN ai_model.remark IS '备注';
COMMENT ON COLUMN ai_model.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_model.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_provider_id ON ai_model (provider_id);

-- ----------------------------
-- Agent 定义
-- ----------------------------

DROP TABLE IF EXISTS ai_agent CASCADE;
CREATE TABLE ai_agent (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  agent_code      VARCHAR(64)     NOT NULL,
  agent_name      VARCHAR(128)    NOT NULL,
  model_id        BIGINT          DEFAULT NULL,
  sys_prompt      TEXT,
  workspace_path  VARCHAR(512)             DEFAULT NULL,
  compaction_json JSON                     DEFAULT NULL,
  tools_json      JSON                     DEFAULT NULL,
  skills_json     JSON                     DEFAULT NULL,
  status          SMALLINT NOT NULL DEFAULT 1,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_agent PRIMARY KEY (id),
  CONSTRAINT uk_tenant_agent_code UNIQUE (tenant_id, agent_code)
);
COMMENT ON TABLE ai_agent IS 'AI Agent定义表';
COMMENT ON COLUMN ai_agent.id IS '主键';
COMMENT ON COLUMN ai_agent.tenant_id IS '租户ID';
COMMENT ON COLUMN ai_agent.agent_code IS 'Agent编码';
COMMENT ON COLUMN ai_agent.agent_name IS 'Agent名称';
COMMENT ON COLUMN ai_agent.model_id IS '默认模型ID';
COMMENT ON COLUMN ai_agent.sys_prompt IS '系统提示词';
COMMENT ON COLUMN ai_agent.workspace_path IS '工作区路径';
COMMENT ON COLUMN ai_agent.compaction_json IS '压缩策略配置JSON';
COMMENT ON COLUMN ai_agent.tools_json IS '工具声明JSON';
COMMENT ON COLUMN ai_agent.skills_json IS '技能配置JSON';
COMMENT ON COLUMN ai_agent.status IS '状态：0停用 1正常';
COMMENT ON COLUMN ai_agent.create_by IS '创建人';
COMMENT ON COLUMN ai_agent.update_by IS '修改人';
COMMENT ON COLUMN ai_agent.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN ai_agent.remark IS '备注';
COMMENT ON COLUMN ai_agent.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_agent.gmt_modified IS '修改时间';

-- ----------------------------
-- Agent 会话
-- ----------------------------

DROP TABLE IF EXISTS ai_agent_session CASCADE;
CREATE TABLE ai_agent_session (
  id                BIGINT NOT NULL,
  tenant_id         BIGINT NOT NULL DEFAULT 0,
  agent_id          BIGINT NOT NULL,
  session_id        VARCHAR(128)    NOT NULL,
  user_id           BIGINT          DEFAULT NULL,
  title             VARCHAR(255)             DEFAULT NULL,
  status            SMALLINT NOT NULL DEFAULT 1,
  last_message_time TIMESTAMP                 DEFAULT NULL,
  ext_json          JSON                     DEFAULT NULL,
  create_by         BIGINT          DEFAULT NULL,
  update_by         BIGINT          DEFAULT NULL,
  is_deleted        SMALLINT NOT NULL DEFAULT 0,
  gmt_create        TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_agent_session PRIMARY KEY (id),
  CONSTRAINT uk_tenant_agent_session UNIQUE (tenant_id, agent_id, session_id)
);
COMMENT ON TABLE ai_agent_session IS 'AI Agent会话表';
COMMENT ON COLUMN ai_agent_session.id IS '主键';
COMMENT ON COLUMN ai_agent_session.tenant_id IS '租户ID';
COMMENT ON COLUMN ai_agent_session.agent_id IS 'AgentID';
COMMENT ON COLUMN ai_agent_session.session_id IS '会话业务ID';
COMMENT ON COLUMN ai_agent_session.user_id IS '业务用户ID';
COMMENT ON COLUMN ai_agent_session.title IS '会话标题';
COMMENT ON COLUMN ai_agent_session.status IS '状态：0关闭 1进行中';
COMMENT ON COLUMN ai_agent_session.last_message_time IS '最后消息时间';
COMMENT ON COLUMN ai_agent_session.ext_json IS '扩展信息JSON';
COMMENT ON COLUMN ai_agent_session.create_by IS '创建人';
COMMENT ON COLUMN ai_agent_session.update_by IS '修改人';
COMMENT ON COLUMN ai_agent_session.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN ai_agent_session.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_agent_session.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_tenant_user ON ai_agent_session (tenant_id, user_id);

-- ----------------------------
-- Agent 消息
-- ----------------------------

DROP TABLE IF EXISTS ai_agent_message CASCADE;
CREATE TABLE ai_agent_message (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  session_pk      BIGINT NOT NULL,
  role            VARCHAR(32)     NOT NULL,
  content         TEXT,
  content_blocks  JSON                     DEFAULT NULL,
  token_usage     JSON                     DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_agent_message PRIMARY KEY (id)
);
COMMENT ON TABLE ai_agent_message IS 'AI Agent消息表';
COMMENT ON COLUMN ai_agent_message.id IS '主键';
COMMENT ON COLUMN ai_agent_message.tenant_id IS '租户ID';
COMMENT ON COLUMN ai_agent_message.session_pk IS '会话表主键';
COMMENT ON COLUMN ai_agent_message.role IS '角色：user/assistant/system/tool';
COMMENT ON COLUMN ai_agent_message.content IS '消息内容';
COMMENT ON COLUMN ai_agent_message.content_blocks IS '多模态或工具调用块JSON';
COMMENT ON COLUMN ai_agent_message.token_usage IS 'token统计JSON';
COMMENT ON COLUMN ai_agent_message.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_agent_message.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_session_create ON ai_agent_message (session_pk, gmt_create);

-- ----------------------------
-- 知识库
-- ----------------------------

DROP TABLE IF EXISTS ai_knowledge_base CASCADE;
CREATE TABLE ai_knowledge_base (
  id                 BIGINT NOT NULL,
  tenant_id          BIGINT NOT NULL DEFAULT 0,
  kb_code            VARCHAR(64)     NOT NULL,
  kb_name            VARCHAR(128)    NOT NULL,
  embedding_model_id BIGINT          DEFAULT NULL,
  index_name         VARCHAR(128)             DEFAULT NULL,
  chunk_size         INTEGER    NOT NULL DEFAULT 500,
  chunk_overlap      INTEGER    NOT NULL DEFAULT 50,
  status             SMALLINT NOT NULL DEFAULT 1,
  create_by          BIGINT          DEFAULT NULL,
  update_by          BIGINT          DEFAULT NULL,
  is_deleted         SMALLINT NOT NULL DEFAULT 0,
  remark             VARCHAR(500)             DEFAULT NULL,
  gmt_create         TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified       TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_knowledge_base PRIMARY KEY (id),
  CONSTRAINT uk_tenant_kb_code UNIQUE (tenant_id, kb_code)
);
COMMENT ON TABLE ai_knowledge_base IS '知识库表';
COMMENT ON COLUMN ai_knowledge_base.id IS '主键';
COMMENT ON COLUMN ai_knowledge_base.tenant_id IS '租户ID';
COMMENT ON COLUMN ai_knowledge_base.kb_code IS '知识库编码';
COMMENT ON COLUMN ai_knowledge_base.kb_name IS '知识库名称';
COMMENT ON COLUMN ai_knowledge_base.embedding_model_id IS '向量模型ID';
COMMENT ON COLUMN ai_knowledge_base.index_name IS '检索索引名';
COMMENT ON COLUMN ai_knowledge_base.chunk_size IS '默认分片大小';
COMMENT ON COLUMN ai_knowledge_base.chunk_overlap IS '分片重叠长度';
COMMENT ON COLUMN ai_knowledge_base.status IS '状态：0停用 1正常';
COMMENT ON COLUMN ai_knowledge_base.create_by IS '创建人';
COMMENT ON COLUMN ai_knowledge_base.update_by IS '修改人';
COMMENT ON COLUMN ai_knowledge_base.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN ai_knowledge_base.remark IS '备注';
COMMENT ON COLUMN ai_knowledge_base.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_knowledge_base.gmt_modified IS '修改时间';

-- ----------------------------
-- 知识库文档
-- ----------------------------

DROP TABLE IF EXISTS ai_knowledge_doc CASCADE;
CREATE TABLE ai_knowledge_doc (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  kb_id           BIGINT NOT NULL,
  file_id         BIGINT          DEFAULT NULL,
  doc_name        VARCHAR(255)    NOT NULL,
  doc_type        VARCHAR(32)              DEFAULT NULL,
  source_url      VARCHAR(1000)            DEFAULT NULL,
  parse_status    SMALLINT NOT NULL DEFAULT 0,
  chunk_count     INTEGER    NOT NULL DEFAULT 0,
  error_msg       VARCHAR(1000)            DEFAULT NULL,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_knowledge_doc PRIMARY KEY (id)
);
COMMENT ON TABLE ai_knowledge_doc IS '知识库文档表';
COMMENT ON COLUMN ai_knowledge_doc.id IS '主键';
COMMENT ON COLUMN ai_knowledge_doc.tenant_id IS '租户ID';
COMMENT ON COLUMN ai_knowledge_doc.kb_id IS '知识库ID';
COMMENT ON COLUMN ai_knowledge_doc.file_id IS '文件ID';
COMMENT ON COLUMN ai_knowledge_doc.doc_name IS '文档名';
COMMENT ON COLUMN ai_knowledge_doc.doc_type IS '类型：pdf/md/docx/html/url';
COMMENT ON COLUMN ai_knowledge_doc.source_url IS '来源URL';
COMMENT ON COLUMN ai_knowledge_doc.parse_status IS '解析状态：0待处理 1处理中 2成功 3失败';
COMMENT ON COLUMN ai_knowledge_doc.chunk_count IS '分片数';
COMMENT ON COLUMN ai_knowledge_doc.error_msg IS '失败原因';
COMMENT ON COLUMN ai_knowledge_doc.create_by IS '创建人';
COMMENT ON COLUMN ai_knowledge_doc.update_by IS '修改人';
COMMENT ON COLUMN ai_knowledge_doc.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN ai_knowledge_doc.remark IS '备注';
COMMENT ON COLUMN ai_knowledge_doc.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_knowledge_doc.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_kb_id ON ai_knowledge_doc (kb_id);
CREATE INDEX IF NOT EXISTS idx_parse_status ON ai_knowledge_doc (parse_status);

-- ----------------------------
-- 知识库分片
-- ----------------------------

DROP TABLE IF EXISTS ai_knowledge_chunk CASCADE;
CREATE TABLE ai_knowledge_chunk (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  kb_id           BIGINT NOT NULL,
  doc_id          BIGINT NOT NULL,
  chunk_index     INTEGER    NOT NULL DEFAULT 0,
  content         TEXT      NOT NULL,
  token_count     INTEGER             DEFAULT NULL,
  vector_id       VARCHAR(128)             DEFAULT NULL,
  metadata_json   JSON                     DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_knowledge_chunk PRIMARY KEY (id)
);
COMMENT ON TABLE ai_knowledge_chunk IS '知识库分片表';
COMMENT ON COLUMN ai_knowledge_chunk.id IS '主键';
COMMENT ON COLUMN ai_knowledge_chunk.tenant_id IS '租户ID';
COMMENT ON COLUMN ai_knowledge_chunk.kb_id IS '知识库ID';
COMMENT ON COLUMN ai_knowledge_chunk.doc_id IS '文档ID';
COMMENT ON COLUMN ai_knowledge_chunk.chunk_index IS '分片序号';
COMMENT ON COLUMN ai_knowledge_chunk.content IS '分片文本';
COMMENT ON COLUMN ai_knowledge_chunk.token_count IS 'token数';
COMMENT ON COLUMN ai_knowledge_chunk.vector_id IS '向量库文档ID';
COMMENT ON COLUMN ai_knowledge_chunk.metadata_json IS '元数据JSON';
COMMENT ON COLUMN ai_knowledge_chunk.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN ai_knowledge_chunk.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_knowledge_chunk.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_doc_chunk ON ai_knowledge_chunk (doc_id, chunk_index);
CREATE INDEX IF NOT EXISTS idx_kb_id ON ai_knowledge_chunk (kb_id);

-- ----------------------------
-- RAG 问答日志
-- ----------------------------

DROP TABLE IF EXISTS ai_rag_query_log CASCADE;
CREATE TABLE ai_rag_query_log (
  id               BIGINT NOT NULL,
  tenant_id        BIGINT NOT NULL DEFAULT 0,
  kb_id            BIGINT          DEFAULT NULL,
  user_id          BIGINT          DEFAULT NULL,
  question         TEXT            NOT NULL,
  answer           TEXT,
  retrieved_chunks JSON                     DEFAULT NULL,
  model_code       VARCHAR(128)             DEFAULT NULL,
  latency_ms       BIGINT          DEFAULT NULL,
  gmt_create       TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified     TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_rag_query_log PRIMARY KEY (id)
);
COMMENT ON TABLE ai_rag_query_log IS 'RAG问答日志表';
COMMENT ON COLUMN ai_rag_query_log.id IS '主键';
COMMENT ON COLUMN ai_rag_query_log.tenant_id IS '租户ID';
COMMENT ON COLUMN ai_rag_query_log.kb_id IS '知识库ID';
COMMENT ON COLUMN ai_rag_query_log.user_id IS '用户ID';
COMMENT ON COLUMN ai_rag_query_log.question IS '问题';
COMMENT ON COLUMN ai_rag_query_log.answer IS '回答';
COMMENT ON COLUMN ai_rag_query_log.retrieved_chunks IS '召回分片JSON';
COMMENT ON COLUMN ai_rag_query_log.model_code IS '使用模型编码';
COMMENT ON COLUMN ai_rag_query_log.latency_ms IS '耗时，单位毫秒';
COMMENT ON COLUMN ai_rag_query_log.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_rag_query_log.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_kb_create ON ai_rag_query_log (kb_id, gmt_create);

-- ----------------------------
-- 工作流定义
-- ----------------------------

DROP TABLE IF EXISTS ai_workflow CASCADE;
CREATE TABLE ai_workflow (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  workflow_code   VARCHAR(64)     NOT NULL,
  workflow_name   VARCHAR(128)    NOT NULL,
  version         INTEGER    NOT NULL DEFAULT 1,
  graph_json      JSON                     DEFAULT NULL,
  status          SMALLINT NOT NULL DEFAULT 0,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_workflow PRIMARY KEY (id),
  CONSTRAINT uk_tenant_workflow_ver UNIQUE (tenant_id, workflow_code, version)
);
COMMENT ON TABLE ai_workflow IS 'AI工作流定义表';
COMMENT ON COLUMN ai_workflow.id IS '主键';
COMMENT ON COLUMN ai_workflow.tenant_id IS '租户ID';
COMMENT ON COLUMN ai_workflow.workflow_code IS '工作流编码';
COMMENT ON COLUMN ai_workflow.workflow_name IS '工作流名称';
COMMENT ON COLUMN ai_workflow.version IS '版本号';
COMMENT ON COLUMN ai_workflow.graph_json IS '画布完整JSON';
COMMENT ON COLUMN ai_workflow.status IS '状态：0草稿 1已发布 2停用';
COMMENT ON COLUMN ai_workflow.create_by IS '创建人';
COMMENT ON COLUMN ai_workflow.update_by IS '修改人';
COMMENT ON COLUMN ai_workflow.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN ai_workflow.remark IS '备注';
COMMENT ON COLUMN ai_workflow.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_workflow.gmt_modified IS '修改时间';

-- ----------------------------
-- 工作流节点
-- ----------------------------

DROP TABLE IF EXISTS ai_workflow_node CASCADE;
CREATE TABLE ai_workflow_node (
  id              BIGINT NOT NULL,
  workflow_id     BIGINT NOT NULL,
  node_key        VARCHAR(64)     NOT NULL,
  node_type       VARCHAR(64)     NOT NULL,
  node_name       VARCHAR(128)             DEFAULT NULL,
  config_json     JSON                     DEFAULT NULL,
  position_x      INTEGER                      DEFAULT NULL,
  position_y      INTEGER                      DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_workflow_node PRIMARY KEY (id),
  CONSTRAINT uk_workflow_node UNIQUE (workflow_id, node_key)
);
COMMENT ON TABLE ai_workflow_node IS 'AI工作流节点表';
COMMENT ON COLUMN ai_workflow_node.id IS '主键';
COMMENT ON COLUMN ai_workflow_node.workflow_id IS '工作流ID';
COMMENT ON COLUMN ai_workflow_node.node_key IS '节点唯一键';
COMMENT ON COLUMN ai_workflow_node.node_type IS '类型：start/llm/agent/rag/tool/condition/end';
COMMENT ON COLUMN ai_workflow_node.node_name IS '节点名称';
COMMENT ON COLUMN ai_workflow_node.config_json IS '节点配置JSON';
COMMENT ON COLUMN ai_workflow_node.position_x IS '画布X坐标';
COMMENT ON COLUMN ai_workflow_node.position_y IS '画布Y坐标';
COMMENT ON COLUMN ai_workflow_node.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_workflow_node.gmt_modified IS '修改时间';

-- ----------------------------
-- 工作流连线
-- ----------------------------

DROP TABLE IF EXISTS ai_workflow_edge CASCADE;
CREATE TABLE ai_workflow_edge (
  id              BIGINT NOT NULL,
  workflow_id     BIGINT NOT NULL,
  edge_key        VARCHAR(64)     NOT NULL,
  source_node_key VARCHAR(64)     NOT NULL,
  target_node_key VARCHAR(64)     NOT NULL,
  condition_expr  VARCHAR(512)             DEFAULT NULL,
  config_json     JSON                     DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_workflow_edge PRIMARY KEY (id),
  CONSTRAINT uk_workflow_edge UNIQUE (workflow_id, edge_key)
);
COMMENT ON TABLE ai_workflow_edge IS 'AI工作流连线表';
COMMENT ON COLUMN ai_workflow_edge.id IS '主键';
COMMENT ON COLUMN ai_workflow_edge.workflow_id IS '工作流ID';
COMMENT ON COLUMN ai_workflow_edge.edge_key IS '边唯一键';
COMMENT ON COLUMN ai_workflow_edge.source_node_key IS '源节点键';
COMMENT ON COLUMN ai_workflow_edge.target_node_key IS '目标节点键';
COMMENT ON COLUMN ai_workflow_edge.condition_expr IS '条件表达式';
COMMENT ON COLUMN ai_workflow_edge.config_json IS '扩展配置JSON';
COMMENT ON COLUMN ai_workflow_edge.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_workflow_edge.gmt_modified IS '修改时间';

-- ----------------------------
-- 工作流运行记录
-- ----------------------------

DROP TABLE IF EXISTS ai_workflow_run CASCADE;
CREATE TABLE ai_workflow_run (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  workflow_id     BIGINT NOT NULL,
  run_no          VARCHAR(64)     NOT NULL,
  status          SMALLINT NOT NULL DEFAULT 0,
  input_json      JSON                     DEFAULT NULL,
  output_json     JSON                     DEFAULT NULL,
  error_msg       VARCHAR(2000)            DEFAULT NULL,
  start_time      TIMESTAMP                 DEFAULT NULL,
  end_time        TIMESTAMP                 DEFAULT NULL,
  create_by       BIGINT          DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_workflow_run PRIMARY KEY (id),
  CONSTRAINT uk_run_no UNIQUE (run_no)
);
COMMENT ON TABLE ai_workflow_run IS 'AI工作流运行记录表';
COMMENT ON COLUMN ai_workflow_run.id IS '主键';
COMMENT ON COLUMN ai_workflow_run.tenant_id IS '租户ID';
COMMENT ON COLUMN ai_workflow_run.workflow_id IS '工作流ID';
COMMENT ON COLUMN ai_workflow_run.run_no IS '运行编号';
COMMENT ON COLUMN ai_workflow_run.status IS '状态：0排队 1运行中 2成功 3失败 4取消';
COMMENT ON COLUMN ai_workflow_run.input_json IS '输入JSON';
COMMENT ON COLUMN ai_workflow_run.output_json IS '输出JSON';
COMMENT ON COLUMN ai_workflow_run.error_msg IS '错误信息';
COMMENT ON COLUMN ai_workflow_run.start_time IS '开始时间';
COMMENT ON COLUMN ai_workflow_run.end_time IS '结束时间';
COMMENT ON COLUMN ai_workflow_run.create_by IS '创建人';
COMMENT ON COLUMN ai_workflow_run.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_workflow_run.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_workflow_create ON ai_workflow_run (workflow_id, gmt_create);

-- ----------------------------
-- 媒体生成任务
-- ----------------------------

DROP TABLE IF EXISTS ai_media_task CASCADE;
CREATE TABLE ai_media_task (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  task_no         VARCHAR(64)     NOT NULL,
  media_type      VARCHAR(32)     NOT NULL,
  model_code      VARCHAR(128)             DEFAULT NULL,
  prompt          TEXT,
  params_json     JSON                     DEFAULT NULL,
  status          SMALLINT NOT NULL DEFAULT 0,
  result_file_ids VARCHAR(1000)            DEFAULT NULL,
  result_urls     TEXT,
  error_msg       VARCHAR(2000)            DEFAULT NULL,
  mq_msg_id       VARCHAR(128)             DEFAULT NULL,
  create_by       BIGINT          DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_media_task PRIMARY KEY (id),
  CONSTRAINT uk_task_no UNIQUE (task_no)
);
COMMENT ON TABLE ai_media_task IS 'AI媒体生成任务表';
COMMENT ON COLUMN ai_media_task.id IS '主键';
COMMENT ON COLUMN ai_media_task.tenant_id IS '租户ID';
COMMENT ON COLUMN ai_media_task.task_no IS '任务编号';
COMMENT ON COLUMN ai_media_task.media_type IS '类型：image/video/doc';
COMMENT ON COLUMN ai_media_task.model_code IS '模型编码';
COMMENT ON COLUMN ai_media_task.prompt IS '提示词';
COMMENT ON COLUMN ai_media_task.params_json IS '生成参数JSON';
COMMENT ON COLUMN ai_media_task.status IS '状态：0排队 1处理中 2成功 3失败';
COMMENT ON COLUMN ai_media_task.result_file_ids IS '结果文件ID，逗号分隔';
COMMENT ON COLUMN ai_media_task.result_urls IS '结果URL';
COMMENT ON COLUMN ai_media_task.error_msg IS '错误信息';
COMMENT ON COLUMN ai_media_task.mq_msg_id IS 'MQ消息ID';
COMMENT ON COLUMN ai_media_task.create_by IS '创建人';
COMMENT ON COLUMN ai_media_task.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_media_task.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_tenant_status_create ON ai_media_task (tenant_id, status, gmt_create);
