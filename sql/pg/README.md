# NovaCloud PostgreSQL SQL 说明

对照根目录 MySQL 脚本生成，表结构与字段语义保持一致。

## 与 MySQL 的差异

| MySQL | PostgreSQL |
|------|------------|
| `BIGINT UNSIGNED` / `INT UNSIGNED` | `BIGINT` / `INTEGER` |
| `TINYINT UNSIGNED` | `SMALLINT` |
| `DATETIME` + `ON UPDATE` | `TIMESTAMP`（`gmt_modified` 由应用更新） |
| 列内联 `COMMENT` | `COMMENT ON COLUMN/TABLE` |
| `KEY idx_xxx` | `CREATE INDEX` |
| `ENGINE=InnoDB utf8mb4` | 默认表空间 + UTF8 库编码 |
| 前缀索引 `col(191)` | 整列索引 |

## 脚本清单

| 文件 | 内容 |
|------|------|
| `00_init_database.sql` | 建库 `nova_cloud` |
| `01_nova_system.sql` | 租户/部门/用户/RBAC/字典/参数/公告 |
| `02_nova_auth.sql` | OAuth2 客户端与授权 |
| `03_nova_file.sql` | 存储配置/文件/分片 |
| `04_nova_log.sql` | 登录/操作/审计日志 |
| `05_nova_ai.sql` | 模型/Agent/知识库/RAG/工作流/媒体任务 |
| `06_nova_platform.sql` | 搜索/任务/监控告警 |
| `07_nova_demo.sql` | Demo 分表示例 |
| `99_init_data.sql` | 开发环境初始数据 |
| `all.sql` | 一键执行入口 |

## 执行方式

```bash
# 一键（需能创建数据库）
psql -U postgres -f all.sql

# 或分步
psql -U postgres -f 00_init_database.sql
psql -U postgres -d nova_cloud -f 01_nova_system.sql
psql -U postgres -d nova_cloud -f 02_nova_auth.sql
# ... 依次执行其余脚本
psql -U postgres -d nova_cloud -f 99_init_data.sql
```

## 默认账号

- 用户：`admin`
- 密码：`admin123`（BCrypt，请上线前修改）

## 业务配置

切换到 PostgreSQL 时：

```bash
SPRING_PROFILES_ACTIVE=dev,pg
```

并确保已引入 `postgresql` 驱动，配置见 `application-pg.yml`。
