package com.nova.mq.core;

import com.nova.mq.listener.MqListener;
import com.rabbitmq.client.Channel;
import lombok.extern.slf4j.Slf4j;

import java.io.IOException;

/**
 * 消费端基类：统一手动 Ack / Nack。
 * <p>
 * 业务监听器继承本类，在 {@code @RabbitHandler} 中调用 {@link #onMessage}，
 * 将具体业务委托给 {@link MqListener} 实现（可用 lambda）。
 * <pre>
 * {@code
 * @RabbitHandler
 * public void onMessage(BaseMap map, Channel channel,
 *                       @Header(AmqpHeaders.DELIVERY_TAG) Long deliveryTag) {
 *     super.onMessage(map, deliveryTag, channel, (data, ch) -> {
 *         // 业务处理
 *     });
 * }
 * }
 * </pre>
 *
 * @param <T> 消息体类型
 */
@Slf4j
public abstract class BaseRabbitMqHandler<T> {

    /**
     * 执行业务并确认消息。
     *
     * @param message     消息体
     * @param deliveryTag 投递标签（用于 Ack/Nack）
     * @param channel     RabbitMQ Channel
     * @param mqListener  业务回调
     */
    public void onMessage(T message, Long deliveryTag, Channel channel, MqListener<T> mqListener) {
        try {
            mqListener.handler(message, channel);
            // multiple=false：仅确认当前消息
            channel.basicAck(deliveryTag, false);
        } catch (Exception e) {
            log.warn("MQ 消费失败，消息重新入队, deliveryTag={}", deliveryTag, e);
            try {
                // requeue=true：拒绝后重新入队
                channel.basicNack(deliveryTag, false, true);
            } catch (IOException ex) {
                log.error("MQ Nack 失败, deliveryTag={}", deliveryTag, ex);
            }
        }
    }
}
