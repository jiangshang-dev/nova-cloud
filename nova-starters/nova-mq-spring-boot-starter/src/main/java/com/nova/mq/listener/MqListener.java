package com.nova.mq.listener;

import com.rabbitmq.client.Channel;

/**
 * 消费端业务回调接口，由业务自行实现。
 * <p>
 * 通常配合 {@link com.nova.mq.core.BaseRabbitMqHandler#onMessage} 使用：
 * 业务逻辑写在 {@link #handler} 中；成功则 Ack，抛异常则 Nack 并重新入队。
 *
 * @param <T> 消息体类型（如 {@link com.nova.mq.model.BaseMap}）
 */
@FunctionalInterface
public interface MqListener<T> {

    /**
     * 处理一条消息。
     *
     * @param message 已反序列化的消息体
     * @param channel RabbitMQ Channel（一般无需手动 Ack，交给 Handler）
     * @throws Exception 业务失败时抛出，触发 Nack 重入队
     */
    void handler(T message, Channel channel) throws Exception;
}
