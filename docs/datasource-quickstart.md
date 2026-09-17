# Nova 多数据库兼容

## 职责

| 模块 | 职责 |
|------|------|
| 业务服务 | 配置 `nova.datasource.db-type` / `mode`、URL、账号；按需引入 JDBC 驱动 |
| `nova-datasource-spring-boot-starter` | 方言、Driver 缺省填充、DatabaseId、mode→分片推导 |
| `nova-mybatis-spring-boot-starter` | MyBatis-Plus 分页（跟随方言 DbType） |
| `nova-shardingsphere-spring-boot-starter` | `mode=sharding*` 时分库分表 |

## 业务引入

```xml
<dependency>
  <groupId>com.nova</groupId>
  <artifactId>nova-datasource-spring-boot-starter</artifactId>
</dependency>
<dependency>
  <groupId>com.nova</groupId>
  <artifactId>nova-mybatis-spring-boot-starter</artifactId>
</dependency>
<!-- 按实际库种引入一种驱动即可 -->
<dependency>
  <groupId>com.mysql</groupId>
  <artifactId>mysql-connector-j</artifactId>
  <scope>runtime</scope>
</dependency>
```

## 配置

```yaml
nova:
  datasource:
    db-type: mysql          # mysql | postgresql | oracle | dameng
    mode: single            # single | read-write-splitting | sharding | sharding-read-write

spring:
  datasource:
    url: jdbc:mysql://127.0.0.1:3306/nova_order
    username: root
    password: 123456
    # driver-class-name 可省略，Starter 按 db-type 自动填充
```

Profile 切换：`dev,mysql` / `dev,pg` / `dev,oracle` / `dev,dm`。

## 预留扩展（TODO）

SQL Server、人大金仓、OceanBase、TiDB、GaussDB — 枚举已占位，方言待实现。
