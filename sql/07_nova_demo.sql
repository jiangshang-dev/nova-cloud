-- =========================================================
-- nova-demo：分表示例（ShardingSphere 逻辑表 demo_order）
-- 规范：阿里巴巴 Java 开发手册 2.0 建表规约（无外键）
-- =========================================================
USE `nova_cloud`;

DROP TABLE IF EXISTS `demo_order_0`;
CREATE TABLE `demo_order_0` (
  `id`            BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `user_id`       BIGINT UNSIGNED NOT NULL COMMENT '用户ID（分片键）',
  `order_no`      VARCHAR(64)     NOT NULL COMMENT '订单号',
  `amount`        DECIMAL(18, 2)  NOT NULL DEFAULT 0.00 COMMENT '金额',
  `status`        TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0待支付 1已支付 2已取消',
  `gmt_create`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_demo_order0_order_no` (`order_no`),
  KEY `idx_demo_order0_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='演示订单分表0';

DROP TABLE IF EXISTS `demo_order_1`;
CREATE TABLE `demo_order_1` (
  `id`            BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `user_id`       BIGINT UNSIGNED NOT NULL COMMENT '用户ID（分片键）',
  `order_no`      VARCHAR(64)     NOT NULL COMMENT '订单号',
  `amount`        DECIMAL(18, 2)  NOT NULL DEFAULT 0.00 COMMENT '金额',
  `status`        TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0待支付 1已支付 2已取消',
  `gmt_create`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_demo_order1_order_no` (`order_no`),
  KEY `idx_demo_order1_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='演示订单分表1';
