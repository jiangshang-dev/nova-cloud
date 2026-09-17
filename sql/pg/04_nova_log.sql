-- =========================================================
-- NovaCloud PostgreSQL 脚本（由 MySQL 版对照生成）
-- 源文件: sql/04_nova_log.sql
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
-- nova-common-log：登录 / 操作 / 审计日志
-- 规范：阿里巴巴 Java 开发手册 2.0 建表规约（无外键）
-- =========================================================
-- ----------------------------
-- 登录日志
-- ----------------------------

DROP TABLE IF EXISTS log_login CASCADE;
CREATE TABLE log_login (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  user_id         BIGINT          DEFAULT NULL,
  username        VARCHAR(64)              DEFAULT NULL,
  login_type      VARCHAR(32)     NOT NULL DEFAULT 'password',
  client_id       VARCHAR(128)             DEFAULT NULL,
  ip              VARCHAR(64)              DEFAULT NULL,
  location        VARCHAR(255)             DEFAULT NULL,
  browser         VARCHAR(128)             DEFAULT NULL,
  os              VARCHAR(128)             DEFAULT NULL,
  user_agent      VARCHAR(512)             DEFAULT NULL,
  status          SMALLINT NOT NULL DEFAULT 1,
  msg             VARCHAR(500)             DEFAULT NULL,
  login_time      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_log_login PRIMARY KEY (id)
);
COMMENT ON TABLE log_login IS '登录日志表';
COMMENT ON COLUMN log_login.id IS '主键';
COMMENT ON COLUMN log_login.tenant_id IS '租户ID';
COMMENT ON COLUMN log_login.user_id IS '用户ID';
COMMENT ON COLUMN log_login.username IS '用户账号';
COMMENT ON COLUMN log_login.login_type IS '登录方式：password/sms/oauth2';
COMMENT ON COLUMN log_login.client_id IS '客户端标识';
COMMENT ON COLUMN log_login.ip IS '登录IP';
COMMENT ON COLUMN log_login.location IS '登录地点';
COMMENT ON COLUMN log_login.browser IS '浏览器';
COMMENT ON COLUMN log_login.os IS '操作系统';
COMMENT ON COLUMN log_login.user_agent IS 'User-Agent';
COMMENT ON COLUMN log_login.status IS '状态：0失败 1成功';
COMMENT ON COLUMN log_login.msg IS '提示消息';
COMMENT ON COLUMN log_login.login_time IS '登录时间';
COMMENT ON COLUMN log_login.gmt_create IS '创建时间';
COMMENT ON COLUMN log_login.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_tenant_username ON log_login (tenant_id, username);
CREATE INDEX IF NOT EXISTS idx_login_time ON log_login (login_time);

-- ----------------------------
-- 操作日志
-- ----------------------------

DROP TABLE IF EXISTS log_operation CASCADE;
CREATE TABLE log_operation (
  id               BIGINT NOT NULL,
  tenant_id        BIGINT NOT NULL DEFAULT 0,
  trace_id         VARCHAR(64)              DEFAULT NULL,
  user_id          BIGINT          DEFAULT NULL,
  username         VARCHAR(64)              DEFAULT NULL,
  module           VARCHAR(64)              DEFAULT NULL,
  business_type    SMALLINT NOT NULL DEFAULT 0,
  method           VARCHAR(255)             DEFAULT NULL,
  request_method   VARCHAR(16)              DEFAULT NULL,
  operator_type    SMALLINT NOT NULL DEFAULT 1,
  request_url      VARCHAR(512)             DEFAULT NULL,
  request_ip       VARCHAR(64)              DEFAULT NULL,
  request_location VARCHAR(255)             DEFAULT NULL,
  request_param    TEXT,
  response_result  TEXT,
  status           SMALLINT NOT NULL DEFAULT 1,
  error_msg        TEXT,
  cost_time        BIGINT NOT NULL DEFAULT 0,
  operate_time     TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_create       TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified     TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_log_operation PRIMARY KEY (id)
);
COMMENT ON TABLE log_operation IS '操作日志表';
COMMENT ON COLUMN log_operation.id IS '主键';
COMMENT ON COLUMN log_operation.tenant_id IS '租户ID';
COMMENT ON COLUMN log_operation.trace_id IS '链路追踪ID';
COMMENT ON COLUMN log_operation.user_id IS '操作用户ID';
COMMENT ON COLUMN log_operation.username IS '操作用户名';
COMMENT ON COLUMN log_operation.module IS '模块名';
COMMENT ON COLUMN log_operation.business_type IS '业务类型：0其它 1新增 2修改 3删除 4授权 5导出 6导入';
COMMENT ON COLUMN log_operation.method IS '方法名';
COMMENT ON COLUMN log_operation.request_method IS '请求方式';
COMMENT ON COLUMN log_operation.operator_type IS '操作类别：1后台用户 2手机端 3其它';
COMMENT ON COLUMN log_operation.request_url IS '请求URL';
COMMENT ON COLUMN log_operation.request_ip IS '主机地址';
COMMENT ON COLUMN log_operation.request_location IS '操作地点';
COMMENT ON COLUMN log_operation.request_param IS '请求参数';
COMMENT ON COLUMN log_operation.response_result IS '返回结果';
COMMENT ON COLUMN log_operation.status IS '状态：0异常 1正常';
COMMENT ON COLUMN log_operation.error_msg IS '错误消息';
COMMENT ON COLUMN log_operation.cost_time IS '耗时，单位毫秒';
COMMENT ON COLUMN log_operation.operate_time IS '操作时间';
COMMENT ON COLUMN log_operation.gmt_create IS '创建时间';
COMMENT ON COLUMN log_operation.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_tenant_user ON log_operation (tenant_id, user_id);
CREATE INDEX IF NOT EXISTS idx_operate_time ON log_operation (operate_time);
CREATE INDEX IF NOT EXISTS idx_trace_id ON log_operation (trace_id);

-- ----------------------------
-- 审计日志
-- ----------------------------

DROP TABLE IF EXISTS log_audit CASCADE;
CREATE TABLE log_audit (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  user_id         BIGINT          DEFAULT NULL,
  username        VARCHAR(64)              DEFAULT NULL,
  audit_type      VARCHAR(64)     NOT NULL,
  biz_type        VARCHAR(64)              DEFAULT NULL,
  biz_id          VARCHAR(64)              DEFAULT NULL,
  action          VARCHAR(64)     NOT NULL,
  before_data     JSON                     DEFAULT NULL,
  after_data      JSON                     DEFAULT NULL,
  ip              VARCHAR(64)              DEFAULT NULL,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_log_audit PRIMARY KEY (id)
);
COMMENT ON TABLE log_audit IS '审计日志表';
COMMENT ON COLUMN log_audit.id IS '主键';
COMMENT ON COLUMN log_audit.tenant_id IS '租户ID';
COMMENT ON COLUMN log_audit.user_id IS '操作人ID';
COMMENT ON COLUMN log_audit.username IS '操作人账号';
COMMENT ON COLUMN log_audit.audit_type IS '审计类型：role_change/perm_change/crypto/config';
COMMENT ON COLUMN log_audit.biz_type IS '业务对象类型';
COMMENT ON COLUMN log_audit.biz_id IS '业务对象ID';
COMMENT ON COLUMN log_audit.action IS '动作';
COMMENT ON COLUMN log_audit.before_data IS '变更前数据';
COMMENT ON COLUMN log_audit.after_data IS '变更后数据';
COMMENT ON COLUMN log_audit.ip IS 'IP地址';
COMMENT ON COLUMN log_audit.remark IS '备注';
COMMENT ON COLUMN log_audit.gmt_create IS '创建时间';
COMMENT ON COLUMN log_audit.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_tenant_biz ON log_audit (tenant_id, biz_type, biz_id);
CREATE INDEX IF NOT EXISTS idx_gmt_create ON log_audit (gmt_create);
