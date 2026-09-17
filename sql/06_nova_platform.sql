-- =========================================================
-- nova-search / nova-job / nova-monitor 业务辅助表
-- 说明：XXL-JOB / Nacos / SkyWalking 自带库表不在此重复
-- 规范：阿里巴巴 Java 开发手册 2.0 建表规约（无外键）
-- =========================================================
USE `nova_cloud`;

-- ----------------------------
-- 搜索索引元数据
-- ----------------------------
DROP TABLE IF EXISTS `search_index_meta`;
CREATE TABLE `search_index_meta` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `index_code`      VARCHAR(64)     NOT NULL COMMENT '业务索引编码',
  `index_name`      VARCHAR(128)    NOT NULL COMMENT 'ES索引名',
  `index_alias`     VARCHAR(128)             DEFAULT NULL COMMENT '索引别名',
  `mapping_json`    JSON                     DEFAULT NULL COMMENT 'mapping定义JSON',
  `settings_json`   JSON                     DEFAULT NULL COMMENT 'settings定义JSON',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0停用 1正常',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_index_code` (`tenant_id`, `index_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='搜索索引元数据表';

-- ----------------------------
-- 搜索同步任务
-- ----------------------------
DROP TABLE IF EXISTS `search_sync_task`;
CREATE TABLE `search_sync_task` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `index_id`        BIGINT UNSIGNED NOT NULL COMMENT '索引元数据ID',
  `task_no`         VARCHAR(64)     NOT NULL COMMENT '任务编号',
  `sync_type`       VARCHAR(32)     NOT NULL DEFAULT 'full' COMMENT '类型：full/incr',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0待执行 1执行中 2成功 3失败',
  `total_count`     BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '总条数',
  `success_count`   BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '成功条数',
  `fail_count`      BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '失败条数',
  `error_msg`       VARCHAR(2000)            DEFAULT NULL COMMENT '错误信息',
  `start_time`      DATETIME                 DEFAULT NULL COMMENT '开始时间',
  `end_time`        DATETIME                 DEFAULT NULL COMMENT '结束时间',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_task_no` (`task_no`),
  KEY `idx_index_create` (`index_id`, `gmt_create`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='搜索同步任务表';

-- ----------------------------
-- 业务任务定义
-- ----------------------------
DROP TABLE IF EXISTS `job_definition`;
CREATE TABLE `job_definition` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `job_code`        VARCHAR(64)     NOT NULL COMMENT '任务编码',
  `job_name`        VARCHAR(128)    NOT NULL COMMENT '任务名称',
  `xxl_job_id`      INT UNSIGNED             DEFAULT NULL COMMENT 'XXL-JOB任务ID',
  `cron_expr`       VARCHAR(128)             DEFAULT NULL COMMENT 'Cron表达式',
  `handler`         VARCHAR(128)    NOT NULL COMMENT '执行器Handler',
  `param_json`      JSON                     DEFAULT NULL COMMENT '默认参数JSON',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0停用 1正常',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_job_code` (`tenant_id`, `job_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='业务任务定义表';

-- ----------------------------
-- 业务任务执行日志
-- ----------------------------
DROP TABLE IF EXISTS `job_exec_log`;
CREATE TABLE `job_exec_log` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `job_id`          BIGINT UNSIGNED NOT NULL COMMENT '任务定义ID',
  `xxl_log_id`      BIGINT UNSIGNED          DEFAULT NULL COMMENT 'XXL-JOB日志ID',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0执行中 1成功 2失败',
  `trigger_time`    DATETIME                 DEFAULT NULL COMMENT '触发时间',
  `finish_time`     DATETIME                 DEFAULT NULL COMMENT '完成时间',
  `cost_ms`         BIGINT UNSIGNED          DEFAULT NULL COMMENT '耗时，单位毫秒',
  `result_msg`      VARCHAR(2000)            DEFAULT NULL COMMENT '结果摘要',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  KEY `idx_job_create` (`job_id`, `gmt_create`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='业务任务执行日志表';

-- ----------------------------
-- 监控告警规则
-- ----------------------------
DROP TABLE IF EXISTS `monitor_alert_rule`;
CREATE TABLE `monitor_alert_rule` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `rule_code`       VARCHAR(64)     NOT NULL COMMENT '规则编码',
  `rule_name`       VARCHAR(128)    NOT NULL COMMENT '规则名称',
  `metric_expr`     VARCHAR(1000)   NOT NULL COMMENT '指标表达式或PromQL',
  `severity`        VARCHAR(16)     NOT NULL DEFAULT 'critical' COMMENT '级别：info/warn/critical',
  `notify_channel`  VARCHAR(255)             DEFAULT NULL COMMENT '通知渠道：mail,dingtalk,webhook',
  `notify_targets`  VARCHAR(1000)            DEFAULT NULL COMMENT '通知目标',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0停用 1正常',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_rule_code` (`tenant_id`, `rule_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='监控告警规则表';

-- ----------------------------
-- 监控告警记录
-- ----------------------------
DROP TABLE IF EXISTS `monitor_alert_record`;
CREATE TABLE `monitor_alert_record` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `rule_id`         BIGINT UNSIGNED NOT NULL COMMENT '规则ID',
  `alert_title`     VARCHAR(255)    NOT NULL COMMENT '告警标题',
  `alert_content`   TEXT                     COMMENT '告警内容',
  `severity`        VARCHAR(16)     NOT NULL DEFAULT 'critical' COMMENT '级别：info/warn/critical',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0待处理 1已确认 2已关闭',
  `fired_time`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '触发时间',
  `resolved_time`   DATETIME                 DEFAULT NULL COMMENT '恢复时间',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  KEY `idx_rule_fired` (`rule_id`, `fired_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='监控告警记录表';
