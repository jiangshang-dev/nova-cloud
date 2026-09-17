# NovaCloud 业务服务目录

业务微服务请放在本目录下创建，平台能力（网关/认证/系统/文件/任务）在 `nova-platform`。

## 新建业务服务步骤

1. 复制 `nova-demo` 为新模块，例如 `nova-order`
2. 修改 `pom.xml` 的 `artifactId`、描述、`mainClass`
3. 修改包名 `com.nova.demo` → `com.nova.order`
4. 修改 `spring.application.name`、端口、Nacos DataId
5. 在 `nova-business/pom.xml` 的 `<modules>` 中登记新模块
6. 在网关 `nova-platform/nova-gateway/.../application-dev.yml` 增加路由，例如：

```yaml
- id: nova-order
  uri: lb://nova-order
  predicates:
    - Path=/order/**
```

7. 本地改好配置后，把 `application-dev.yml` 内容复制到 Nacos（DataId=`nova-order-dev.yml`）

## 推荐依赖

- `nova-common-core`：统一响应 / 异常 / `@Debounce`
- `nova-common-security`：JWT
- `nova-common-redis` / `nova-common-mybatis`：按需
- `nova-*-spring-boot-starter`：按需（文件、国密等）

## Demo 接口

网关前缀：`/demo/**` → `nova-demo`

- `GET  /demo/item/list`
- `POST /demo/item`
- `PUT  /demo/item/{id}`
- `DELETE /demo/item/{id}`
