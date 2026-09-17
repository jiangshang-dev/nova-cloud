# Nova 数据源（对齐 JeecgBoot）

使用 `spring.datasource.dynamic` + Druid，**不再**使用自定义 `NovaShardingProperties`。

## 单库

```yaml
spring:
  datasource:
    dynamic:
      primary: master
      datasource:
        master:
          url: jdbc:mysql://127.0.0.1:3306/nova_cloud?...
          username: root
          password: root
          driver-class-name: com.mysql.cj.jdbc.Driver
```

## 从库（可选）

```yaml
spring:
  datasource:
    dynamic:
      datasource:
        master: ...
        slave:
          url: jdbc:mysql://127.0.0.1:3307/nova_cloud?...
          username: root
          password: root
          driver-class-name: com.mysql.cj.jdbc.Driver
```

未配置 slave 时全部走 master；需要读从库时使用 `@DS("slave")`。

## 分片（可选，对齐 Jeecg）

```yaml
spring:
  datasource:
    dynamic:
      datasource:
        master: ...
        sharding-db:
          driver-class-name: org.apache.shardingsphere.driver.ShardingSphereDriver
          url: jdbc:shardingsphere:classpath:sharding.yaml
```

业务侧 `@DS("sharding-db")`，规则写在 `sharding.yaml`。
