# Nova Platform 配置说明

与 `nova-demo` 一致：配置按类型拆分，数据库通过 Profile 切换。

## 有数据源的服务（system / auth / file）

| 文件 | 用途 |
|------|------|
| `application.yml` | 应用名、Profile 组合、Nacos |
| `application-dev.yml` | 端口及服务专属项 |
| `application-common.yml` | MyBatis / Swagger / 监控 |
| `application-security.yml` | JWT |
| `application-redis.yml` | Redis |
| `application-mysql.yml` | MySQL（默认 `mode: single`，可改 sharding） |
| `application-pg.yml` | PostgreSQL |
| `application-oracle.yml` | Oracle |
| `application-dm.yml` | 达梦 |

切换：

```bash
SPRING_PROFILES_ACTIVE=dev,mysql   # 默认
SPRING_PROFILES_ACTIVE=dev,pg
SPRING_PROFILES_ACTIVE=dev,oracle
SPRING_PROFILES_ACTIVE=dev,dm
```

依赖：`nova-datasource-spring-boot-starter` + `nova-mybatis-spring-boot-starter` + `nova-shardingsphere-spring-boot-starter`（按需启用分片）。

## 网关（无库）

仅 `common` / `security` + `application-dev.yml`（路由、鉴权白名单、国密）。

## 任务服务 nova-job

脚手架占位，后续按同样方式补齐即可。
