# Nova ShardingSphere 使用说明

## 依赖

```xml
<dependency>
    <groupId>com.nova</groupId>
    <artifactId>nova-shardingsphere-spring-boot-starter</artifactId>
</dependency>
<dependency>
    <groupId>com.nova</groupId>
    <artifactId>nova-mybatis-spring-boot-starter</artifactId>
</dependency>
```

## 开关

| 配置 | 含义 |
|------|------|
| `nova.sharding.enabled` | 总开关。`false` 时不接管 DataSource，继续用 `spring.datasource` |
| `nova.sharding.readwrite-splitting.enabled` | 主从读写分离。可关；开启需配置写库 + 读库列表 |

## Demo

1. 执行 `sql/07_nova_demo.sql`
2. 启动 `nova-demo`，调用 `POST /demo/order`（需登录态）
3. 偶数 `userId` 进 `demo_order_0`，奇数进 `demo_order_1`

开启主从时：配置 `ds0_slave`，将 `readwrite-splitting.enabled=true`，并把 `actual-data-nodes` 改为 `readwrite_ds.demo_order_$->{0..1}`。
