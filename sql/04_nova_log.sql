-- =========================================================
-- nova-common-log：登录 / 操作 / 审计日志
-- 规范：阿里巴巴 Java 开发手册 2.0 建表规约（无外键）
-- =========================================================
USE `nova_cloud`;

-- ----------------------------
-- 登录日志
-- ----------------------------
DROP TABLE IF EXISTS `log_login`;
CREATE TABLE `log_login` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `user_id`         BIGINT UNSIGNED          DEFAULT NULL COMMENT '用户ID',
  `username`        VARCHAR(64)              DEFAULT NULL COMMENT '用户账号',
  `login_type`      VARCHAR(32)     NOT NULL DEFAULT 'password' COMMENT '登录方式：password/sms/oauth2',
  `client_id`       VARCHAR(128)             DEFAULT NULL COMMENT '客户端标识',
  `ip`              VARCHAR(64)              DEFAULT NULL COMMENT '登录IP',
  `location`        VARCHAR(255)             DEFAULT NULL COMMENT '登录地点',
  `browser`         VARCHAR(128)             DEFAULT NULL COMMENT '浏览器',
  `os`              VARCHAR(128)             DEFAULT NULL COMMENT '操作系统',
  `user_agent`      VARCHAR(512)             DEFAULT NULL COMMENT 'User-Agent',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0失败 1成功',
  `msg`             VARCHAR(500)             DEFAULT NULL COMMENT '提示消息',
  `login_time`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登录时间',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  KEY `idx_tenant_username` (`tenant_id`, `username`),
  KEY `idx_login_time` (`login_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='登录日志表';

-- ----------------------------
-- 操作日志
-- ----------------------------
DROP TABLE IF EXISTS `log_operation`;
CREATE TABLE `log_operation` (
  `id`               BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`        BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `trace_id`         VARCHAR(64)              DEFAULT NULL COMMENT '链路追踪ID',
  `user_id`          BIGINT UNSIGNED          DEFAULT NULL COMMENT '操作用户ID',
  `username`         VARCHAR(64)              DEFAULT NULL COMMENT '操作用户名',
  `module`           VARCHAR(64)              DEFAULT NULL COMMENT '模块名',
  `business_type`    TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '业务类型：0其它 1新增 2修改 3删除 4授权 5导出 6导入',
  `method`           VARCHAR(255)             DEFAULT NULL COMMENT '方法名',
  `request_method`   VARCHAR(16)              DEFAULT NULL COMMENT '请求方式',
  `operator_type`    TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '操作类别：1后台用户 2手机端 3其它',
  `request_url`      VARCHAR(512)             DEFAULT NULL COMMENT '请求URL',
  `request_ip`       VARCHAR(64)              DEFAULT NULL COMMENT '主机地址',
  `request_location` VARCHAR(255)             DEFAULT NULL COMMENT '操作地点',
  `request_param`    TEXT                     COMMENT '请求参数',
  `response_result`  TEXT                     COMMENT '返回结果',
  `status`           TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0异常 1正常',
  `error_msg`        TEXT                     COMMENT '错误消息',
  `cost_time`        BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '耗时，单位毫秒',
  `operate_time`     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  `gmt_create`       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  KEY `idx_tenant_user` (`tenant_id`, `user_id`),
  KEY `idx_operate_time` (`operate_time`),
  KEY `idx_trace_id` (`trace_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='操作日志表';

-- ----------------------------
-- 审计日志
-- ----------------------------
DROP TABLE IF EXISTS `log_audit`;
CREATE TABLE `log_audit` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `user_id`         BIGINT UNSIGNED          DEFAULT NULL COMMENT '操作人ID',
  `username`        VARCHAR(64)              DEFAULT NULL COMMENT '操作人账号',
  `audit_type`      VARCHAR(64)     NOT NULL COMMENT '审计类型：role_change/perm_change/crypto/config',
  `biz_type`        VARCHAR(64)              DEFAULT NULL COMMENT '业务对象类型',
  `biz_id`          VARCHAR(64)              DEFAULT NULL COMMENT '业务对象ID',
  `action`          VARCHAR(64)     NOT NULL COMMENT '动作',
  `before_data`     JSON                     DEFAULT NULL COMMENT '变更前数据',
  `after_data`      JSON                     DEFAULT NULL COMMENT '变更后数据',
  `ip`              VARCHAR(64)              DEFAULT NULL COMMENT 'IP地址',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  KEY `idx_tenant_biz` (`tenant_id`, `biz_type`, `biz_id`),
  KEY `idx_gmt_create` (`gmt_create`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='审计日志表';
