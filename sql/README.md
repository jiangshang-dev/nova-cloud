# NovaCloud SQL 说明

## 规范依据

严格遵循《阿里巴巴 Java 开发手册》2.0（华山版）MySQL 建表规约：

| 条目 | 落地方式 |
|------|----------|
| 必备三字段 | `id` / `gmt_create` / `gmt_modified` |
| 主键类型 | `BIGINT UNSIGNED`，应用侧雪花 ID |
| 是/否字段 | `is_xxx` + `TINYINT UNSIGNED`（1是 0否） |
| 非负字段 | `UNSIGNED` |
| 索引命名 | 唯一 `uk_`，普通 `idx_` |
| 禁止外键 | 全部逻辑关联，无 `FOREIGN KEY` |
| 字符集 | `utf8mb4` + `InnoDB` |
| 注释 | 表、字段均有 `COMMENT` |
| 表名 | 小写单数，`业务_作用` |

## 脚本清单

| 文件 | 内容 |
|------|------|
| `00_init_database.sql` | 建库 |
| `01_nova_system.sql` | 租户/部门/用户/RBAC/字典/参数/公告 |
| `02_nova_auth.sql` | OAuth2 客户端与授权 |
| `03_nova_file.sql` | 存储配置/文件/分片 |
| `04_nova_log.sql` | 登录/操作/审计日志 |
| `05_nova_ai.sql` | 模型/Agent/知识库/RAG/工作流/媒体任务 |
| `06_nova_platform.sql` | 搜索/任务/监控告警 |
| `99_init_data.sql` | 开发环境初始数据 |
| `all.sql` | 一键执行入口 |

## 执行方式

```bash
# 在 sql 目录下
mysql -uroot -p < all.sql

# 或
mysql -uroot -p -e "source /absolute/path/to/sql/all.sql"
```

## 默认账号

- 用户：`admin`
- 密码：`admin123`（BCrypt，请上线前修改）
