-- =========================================================
-- NovaCloud 一键初始化入口
-- 用法（在 sql 目录下执行）：
--   mysql -uroot -p < all.sql
-- 或逐个执行 00 ~ 99 脚本
-- =========================================================

SOURCE 00_init_database.sql;
SOURCE 01_nova_system.sql;
SOURCE 02_nova_auth.sql;
SOURCE 03_nova_file.sql;
SOURCE 04_nova_log.sql;
SOURCE 05_nova_ai.sql;
SOURCE 06_nova_platform.sql;
SOURCE 99_init_data.sql;
