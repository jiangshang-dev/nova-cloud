# 分片快速开始（ShardingSphereDriver）

1. 准备 `classpath:sharding.yaml`（参考 nova-demo）
2. 在 `application-mysql.yml` 增加：

```yaml
spring.datasource.dynamic.datasource.sharding-db:
  driver-class-name: org.apache.shardingsphere.driver.ShardingSphereDriver
  url: jdbc:shardingsphere:classpath:sharding.yaml
```

3. Mapper/Service 上 `@DS("sharding-db")`
