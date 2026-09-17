package com.nova.mq.annotation;

import org.springframework.core.annotation.AliasFor;
import org.springframework.stereotype.Component;

import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * 标记 RabbitMQ 消费组件（等同于 {@link Component}）。
 * <p>
 * 启动时 {@link com.nova.mq.client.RabbitMqClient} 会扫描带本注解的 Bean，
 * 读取类或方法上的 {@code @RabbitListener#queues()}，自动声明队列并绑定到直连交换机。
 * <pre>
 * {@code
 * @RabbitComponent("demoReceiver")
 * @RabbitListener(queues = "demo.queue")
 * public class DemoReceiver extends BaseRabbitMqHandler<BaseMap> { ... }
 * }
 * </pre>
 */
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@Documented
@Component
public @interface RabbitComponent {

    /**
     * Bean 名称，透传给 {@link Component#value()}。
     */
    @AliasFor(annotation = Component.class)
    String value() default "";
}
