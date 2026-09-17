-- =========================================================
-- NovaCloud PostgreSQL 建库
-- PostgreSQL 14+
-- =========================================================
-- 需具备创建库权限。若库已存在请跳过本文件。
-- 用法示例：
--   psql -U postgres -f 00_init_database.sql
--   psql -U postgres -d nova_cloud -f 01_nova_system.sql
-- =========================================================

CREATE DATABASE nova_cloud WITH ENCODING = 'UTF8';

-- 可选：指定排序规则（按操作系统 locale 调整，失败时可仅保留上一行）
-- CREATE DATABASE nova_cloud
--   WITH ENCODING = 'UTF8'
--        LC_COLLATE = 'en_US.UTF-8'
--        LC_CTYPE = 'en_US.UTF-8'
--        TEMPLATE = template0;
