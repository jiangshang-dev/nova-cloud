package com.nova.mq.properties;

import com.nova.mq.exchange.DelayExchangeBuilder;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * Nova MQ 扩展配置，前缀 {@code nova.mq}。
 * <p>
 * 连接信息仍使用 Spring Boot 标准项 {@code spring.rabbitmq.*}；
 * 本类仅控制 Nova 封装行为（是否启用、交换机名、消费者并发等）。
 * <pre>
 * {@code
 * nova:
 *   mq:
 *     enabled: true
 *     direct-exchange: nova.direct.exchange
 *     delay-exchange: nova.delayed.exchange
 *     concurrent-consumers: 1
 *     max-concurrent-consumers: 1
 *     prefetch: 1
 * }
 * </pre>
 */
@Data
@ConfigurationProperties(prefix = "nova.mq")
public class NovaMqProperties {

    /** 是否启用 Nova MQ 自动装配（false 时不注册 RabbitMqClient 等 Bean） */
    private boolean enabled = true;

    /** 直连交换机名，即时 {@code sendMessage(queue, body)} 使用 */
    private String directExchange = DelayExchangeBuilder.DELAY_EXCHANGE;

    /** 延迟交换机名，需安装 delayed-message 插件 */
    private String delayExchange = DelayExchangeBuilder.DEFAULT_DELAY_EXCHANGE;

    /** 监听容器初始并发消费者数 */
    private int concurrentConsumers = 1;

    /** 监听容器最大并发消费者数 */
    private int maxConcurrentConsumers = 1;

    /** 每个消费者预取未确认消息数 */
    private int prefetch = 1;

    /** 消费端拒绝后是否默认重新入队 */
    private boolean defaultRequeueRejected = true;
}
