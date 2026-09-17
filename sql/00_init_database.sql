-- =========================================================
-- NovaCloud 框架库初始化
-- MySQL 8.0+ / InnoDB / utf8mb4
-- 建表规范：阿里巴巴 Java 开发手册（华山版/2.0）MySQL 规约
-- =========================================================
-- 强制约定：
-- 1. 表名小写 + 下划线，禁止复数；业务前缀_作用（如 sys_user）
-- 2. 表必备三字段：id / gmt_create / gmt_modified
-- 3. id：BIGINT UNSIGNED；分布式场景由应用生成雪花 ID（不使用库自增）
-- 4. 是/否字段：is_xxx + TINYINT UNSIGNED（1是 0否）
-- 5. 非负数字段使用 UNSIGNED
-- 6. 索引：主键默认；唯一 uk_；普通 idx_
-- 7. 禁止外键；字符集 utf8mb4；引擎 InnoDB
-- 8. 表与字段必须有 COMMENT；varchar 不超过 5000，超长独立 TEXT 表或 MEDIUMTEXT
-- =========================================================

CREATE DATABASE IF NOT EXISTS `nova_cloud`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_general_ci;

USE `nova_cloud`;
