-- =========================================================
-- nova-system：操作 / 登录日志（Jeecg 兼容 API 表）
-- =========================================================
USE `nova_cloud`;

DROP TABLE IF EXISTS `sys_oper_log`;
CREATE TABLE `sys_oper_log` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `title`           VARCHAR(128)             DEFAULT NULL COMMENT '模块标题',
  `business_type`   TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '业务类型：0其它 1新增 2修改 3删除 4授权 5导出 6导入',
  `method`          VARCHAR(255)             DEFAULT NULL COMMENT '方法名称',
  `request_method`  VARCHAR(16)              DEFAULT NULL COMMENT '请求方式',
  `oper_name`       VARCHAR(64)              DEFAULT NULL COMMENT '操作人员',
  `oper_url`        VARCHAR(512)             DEFAULT NULL COMMENT '请求URL',
  `oper_ip`         VARCHAR(64)              DEFAULT NULL COMMENT '主机地址',
  `oper_param`      TEXT                     COMMENT '请求参数',
  `json_result`     TEXT                     COMMENT '返回参数',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0异常 1正常',
  `error_msg`       TEXT                     COMMENT '错误消息',
  `oper_time`       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  `cost_time`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '消耗时间，毫秒',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  KEY `idx_oper_time` (`oper_time`),
  KEY `idx_oper_name` (`oper_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='操作日志表';

DROP TABLE IF EXISTS `sys_login_log`;
CREATE TABLE `sys_login_log` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `user_id`         BIGINT UNSIGNED          DEFAULT NULL COMMENT '用户ID',
  `username`        VARCHAR(64)              DEFAULT NULL COMMENT '用户账号',
  `ip`              VARCHAR(64)              DEFAULT NULL COMMENT '登录IP',
  `location`        VARCHAR(255)             DEFAULT NULL COMMENT '登录地点',
  `browser`         VARCHAR(128)             DEFAULT NULL COMMENT '浏览器类型',
  `os`              VARCHAR(128)             DEFAULT NULL COMMENT '操作系统',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0失败 1成功',
  `msg`             VARCHAR(500)             DEFAULT NULL COMMENT '提示消息',
  `login_time`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登录时间',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  KEY `idx_username` (`username`),
  KEY `idx_login_time` (`login_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='登录日志表';
