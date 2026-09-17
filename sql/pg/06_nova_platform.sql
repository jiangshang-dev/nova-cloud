-- =========================================================
-- NovaCloud PostgreSQL 脚本（由 MySQL 版对照生成）
-- 源文件: sql/06_nova_platform.sql
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
-- nova-search / nova-job / nova-monitor 业务辅助表
-- 说明：XXL-JOB / Nacos / SkyWalking 自带库表不在此重复
-- 规范：阿里巴巴 Java 开发手册 2.0 建表规约（无外键）
-- =========================================================
-- ----------------------------
-- 搜索索引元数据
-- ----------------------------

DROP TABLE IF EXISTS search_index_meta CASCADE;
CREATE TABLE search_index_meta (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  index_code      VARCHAR(64)     NOT NULL,
  index_name      VARCHAR(128)    NOT NULL,
  index_alias     VARCHAR(128)             DEFAULT NULL,
  mapping_json    JSON                     DEFAULT NULL,
  settings_json   JSON                     DEFAULT NULL,
  status          SMALLINT NOT NULL DEFAULT 1,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_search_index_meta PRIMARY KEY (id),
  CONSTRAINT uk_tenant_index_code UNIQUE (tenant_id, index_code)
);
COMMENT ON TABLE search_index_meta IS '搜索索引元数据表';
COMMENT ON COLUMN search_index_meta.id IS '主键';
COMMENT ON COLUMN search_index_meta.tenant_id IS '租户ID';
COMMENT ON COLUMN search_index_meta.index_code IS '业务索引编码';
COMMENT ON COLUMN search_index_meta.index_name IS 'ES索引名';
COMMENT ON COLUMN search_index_meta.index_alias IS '索引别名';
COMMENT ON COLUMN search_index_meta.mapping_json IS 'mapping定义JSON';
COMMENT ON COLUMN search_index_meta.settings_json IS 'settings定义JSON';
COMMENT ON COLUMN search_index_meta.status IS '状态：0停用 1正常';
COMMENT ON COLUMN search_index_meta.create_by IS '创建人';
COMMENT ON COLUMN search_index_meta.update_by IS '修改人';
COMMENT ON COLUMN search_index_meta.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN search_index_meta.remark IS '备注';
COMMENT ON COLUMN search_index_meta.gmt_create IS '创建时间';
COMMENT ON COLUMN search_index_meta.gmt_modified IS '修改时间';

-- ----------------------------
-- 搜索同步任务
-- ----------------------------

DROP TABLE IF EXISTS search_sync_task CASCADE;
CREATE TABLE search_sync_task (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  index_id        BIGINT NOT NULL,
  task_no         VARCHAR(64)     NOT NULL,
  sync_type       VARCHAR(32)     NOT NULL DEFAULT 'full',
  status          SMALLINT NOT NULL DEFAULT 0,
  total_count     BIGINT NOT NULL DEFAULT 0,
  success_count   BIGINT NOT NULL DEFAULT 0,
  fail_count      BIGINT NOT NULL DEFAULT 0,
  error_msg       VARCHAR(2000)            DEFAULT NULL,
  start_time      TIMESTAMP                 DEFAULT NULL,
  end_time        TIMESTAMP                 DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_search_sync_task PRIMARY KEY (id),
  CONSTRAINT uk_task_no UNIQUE (task_no)
);
COMMENT ON TABLE search_sync_task IS '搜索同步任务表';
COMMENT ON COLUMN search_sync_task.id IS '主键';
COMMENT ON COLUMN search_sync_task.tenant_id IS '租户ID';
COMMENT ON COLUMN search_sync_task.index_id IS '索引元数据ID';
COMMENT ON COLUMN search_sync_task.task_no IS '任务编号';
COMMENT ON COLUMN search_sync_task.sync_type IS '类型：full/incr';
COMMENT ON COLUMN search_sync_task.status IS '状态：0待执行 1执行中 2成功 3失败';
COMMENT ON COLUMN search_sync_task.total_count IS '总条数';
COMMENT ON COLUMN search_sync_task.success_count IS '成功条数';
COMMENT ON COLUMN search_sync_task.fail_count IS '失败条数';
COMMENT ON COLUMN search_sync_task.error_msg IS '错误信息';
COMMENT ON COLUMN search_sync_task.start_time IS '开始时间';
COMMENT ON COLUMN search_sync_task.end_time IS '结束时间';
COMMENT ON COLUMN search_sync_task.gmt_create IS '创建时间';
COMMENT ON COLUMN search_sync_task.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_index_create ON search_sync_task (index_id, gmt_create);

-- ----------------------------
-- 业务任务定义
-- ----------------------------

DROP TABLE IF EXISTS job_definition CASCADE;
CREATE TABLE job_definition (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  job_code        VARCHAR(64)     NOT NULL,
  job_name        VARCHAR(128)    NOT NULL,
  xxl_job_id      INTEGER             DEFAULT NULL,
  cron_expr       VARCHAR(128)             DEFAULT NULL,
  handler         VARCHAR(128)    NOT NULL,
  param_json      JSON                     DEFAULT NULL,
  status          SMALLINT NOT NULL DEFAULT 1,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_job_definition PRIMARY KEY (id),
  CONSTRAINT uk_tenant_job_code UNIQUE (tenant_id, job_code)
);
COMMENT ON TABLE job_definition IS '业务任务定义表';
COMMENT ON COLUMN job_definition.id IS '主键';
COMMENT ON COLUMN job_definition.tenant_id IS '租户ID';
COMMENT ON COLUMN job_definition.job_code IS '任务编码';
COMMENT ON COLUMN job_definition.job_name IS '任务名称';
COMMENT ON COLUMN job_definition.xxl_job_id IS 'XXL-JOB任务ID';
COMMENT ON COLUMN job_definition.cron_expr IS 'Cron表达式';
COMMENT ON COLUMN job_definition.handler IS '执行器Handler';
COMMENT ON COLUMN job_definition.param_json IS '默认参数JSON';
COMMENT ON COLUMN job_definition.status IS '状态：0停用 1正常';
COMMENT ON COLUMN job_definition.create_by IS '创建人';
COMMENT ON COLUMN job_definition.update_by IS '修改人';
COMMENT ON COLUMN job_definition.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN job_definition.remark IS '备注';
COMMENT ON COLUMN job_definition.gmt_create IS '创建时间';
COMMENT ON COLUMN job_definition.gmt_modified IS '修改时间';

-- ----------------------------
-- 业务任务执行日志
-- ----------------------------

DROP TABLE IF EXISTS job_exec_log CASCADE;
CREATE TABLE job_exec_log (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  job_id          BIGINT NOT NULL,
  xxl_log_id      BIGINT          DEFAULT NULL,
  status          SMALLINT NOT NULL DEFAULT 0,
  trigger_time    TIMESTAMP                 DEFAULT NULL,
  finish_time     TIMESTAMP                 DEFAULT NULL,
  cost_ms         BIGINT          DEFAULT NULL,
  result_msg      VARCHAR(2000)            DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_job_exec_log PRIMARY KEY (id)
);
COMMENT ON TABLE job_exec_log IS '业务任务执行日志表';
COMMENT ON COLUMN job_exec_log.id IS '主键';
COMMENT ON COLUMN job_exec_log.tenant_id IS '租户ID';
COMMENT ON COLUMN job_exec_log.job_id IS '任务定义ID';
COMMENT ON COLUMN job_exec_log.xxl_log_id IS 'XXL-JOB日志ID';
COMMENT ON COLUMN job_exec_log.status IS '状态：0执行中 1成功 2失败';
COMMENT ON COLUMN job_exec_log.trigger_time IS '触发时间';
COMMENT ON COLUMN job_exec_log.finish_time IS '完成时间';
COMMENT ON COLUMN job_exec_log.cost_ms IS '耗时，单位毫秒';
COMMENT ON COLUMN job_exec_log.result_msg IS '结果摘要';
COMMENT ON COLUMN job_exec_log.gmt_create IS '创建时间';
COMMENT ON COLUMN job_exec_log.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_job_create ON job_exec_log (job_id, gmt_create);

-- ----------------------------
-- 监控告警规则
-- ----------------------------

DROP TABLE IF EXISTS monitor_alert_rule CASCADE;
CREATE TABLE monitor_alert_rule (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  rule_code       VARCHAR(64)     NOT NULL,
  rule_name       VARCHAR(128)    NOT NULL,
  metric_expr     VARCHAR(1000)   NOT NULL,
  severity        VARCHAR(16)     NOT NULL DEFAULT 'critical',
  notify_channel  VARCHAR(255)             DEFAULT NULL,
  notify_targets  VARCHAR(1000)            DEFAULT NULL,
  status          SMALLINT NOT NULL DEFAULT 1,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_monitor_alert_rule PRIMARY KEY (id),
  CONSTRAINT uk_tenant_rule_code UNIQUE (tenant_id, rule_code)
);
COMMENT ON TABLE monitor_alert_rule IS '监控告警规则表';
COMMENT ON COLUMN monitor_alert_rule.id IS '主键';
COMMENT ON COLUMN monitor_alert_rule.tenant_id IS '租户ID';
COMMENT ON COLUMN monitor_alert_rule.rule_code IS '规则编码';
COMMENT ON COLUMN monitor_alert_rule.rule_name IS '规则名称';
COMMENT ON COLUMN monitor_alert_rule.metric_expr IS '指标表达式或PromQL';
COMMENT ON COLUMN monitor_alert_rule.severity IS '级别：info/warn/critical';
COMMENT ON COLUMN monitor_alert_rule.notify_channel IS '通知渠道：mail,dingtalk,webhook';
COMMENT ON COLUMN monitor_alert_rule.notify_targets IS '通知目标';
COMMENT ON COLUMN monitor_alert_rule.status IS '状态：0停用 1正常';
COMMENT ON COLUMN monitor_alert_rule.create_by IS '创建人';
COMMENT ON COLUMN monitor_alert_rule.update_by IS '修改人';
COMMENT ON COLUMN monitor_alert_rule.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN monitor_alert_rule.remark IS '备注';
COMMENT ON COLUMN monitor_alert_rule.gmt_create IS '创建时间';
COMMENT ON COLUMN monitor_alert_rule.gmt_modified IS '修改时间';

-- ----------------------------
-- 监控告警记录
-- ----------------------------

DROP TABLE IF EXISTS monitor_alert_record CASCADE;
CREATE TABLE monitor_alert_record (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  rule_id         BIGINT NOT NULL,
  alert_title     VARCHAR(255)    NOT NULL,
  alert_content   TEXT,
  severity        VARCHAR(16)     NOT NULL DEFAULT 'critical',
  status          SMALLINT NOT NULL DEFAULT 0,
  fired_time      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  resolved_time   TIMESTAMP                 DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_monitor_alert_record PRIMARY KEY (id)
);
COMMENT ON TABLE monitor_alert_record IS '监控告警记录表';
COMMENT ON COLUMN monitor_alert_record.id IS '主键';
COMMENT ON COLUMN monitor_alert_record.tenant_id IS '租户ID';
COMMENT ON COLUMN monitor_alert_record.rule_id IS '规则ID';
COMMENT ON COLUMN monitor_alert_record.alert_title IS '告警标题';
COMMENT ON COLUMN monitor_alert_record.alert_content IS '告警内容';
COMMENT ON COLUMN monitor_alert_record.severity IS '级别：info/warn/critical';
COMMENT ON COLUMN monitor_alert_record.status IS '状态：0待处理 1已确认 2已关闭';
COMMENT ON COLUMN monitor_alert_record.fired_time IS '触发时间';
COMMENT ON COLUMN monitor_alert_record.resolved_time IS '恢复时间';
COMMENT ON COLUMN monitor_alert_record.gmt_create IS '创建时间';
COMMENT ON COLUMN monitor_alert_record.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_rule_fired ON monitor_alert_record (rule_id, fired_time);
