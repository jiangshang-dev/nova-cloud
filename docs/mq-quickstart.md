# Nova MQ 使用说明

## 1. 引入依赖

```xml
<dependency>
    <groupId>com.nova</groupId>
    <artifactId>nova-mq-spring-boot-starter</artifactId>
</dependency>
```

> 代码已合并进 starter，无需再引入 `nova-common-mq`。

## 2. 配置 RabbitMQ

```yaml
spring:
  rabbitmq:
    host: 127.0.0.1
    port: 5672
    username: guest
    password: guest
    publisher-confirm-type: correlated
    listener:
      simple:
        acknowledge-mode: manual

nova:
  mq:
    enabled: true
    direct-exchange: nova.direct.exchange
    delay-exchange: nova.delayed.exchange   # 延迟消息需安装 rabbitmq_delayed_message_exchange 插件
    concurrent-consumers: 1
    max-concurrent-consumers: 1
    prefetch: 1
```

## 3. 生产：注入 RabbitMqClient

```java
@Autowired
private RabbitMqClient rabbitMqClient;

// 立即发送
rabbitMqClient.sendMessage("demo.queue", new BaseMap().set("id", 1));

// 延迟发送（毫秒）
rabbitMqClient.sendMessage("demo.queue", payload, 5000);
```

## 4. 消费：实现监听

```java
@Slf4j
@RabbitComponent("demoReceiver")
@RabbitListener(queues = "demo.queue")
public class DemoReceiver extends BaseRabbitMqHandler<BaseMap> {

    @RabbitHandler
    public void onMessage(BaseMap map,
                          Channel channel,
                          @Header(AmqpHeaders.DELIVERY_TAG) Long deliveryTag) {
        super.onMessage(map, deliveryTag, channel, (data, ch) -> {
            log.info("收到消息: {}", data);
            // 业务处理；抛异常会 Nack 并重新入队
        });
    }
}
```

启动时会对带 `@RabbitComponent` 的 `@RabbitListener` 自动声明队列并绑定到直连交换机。
