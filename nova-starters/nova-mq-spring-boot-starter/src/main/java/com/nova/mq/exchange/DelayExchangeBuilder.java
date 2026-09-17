package com.nova.mq.exchange;

import org.springframework.amqp.core.CustomExchange;

import java.util.HashMap;
import java.util.Map;

/**
 * 延迟交换机构造器。
 * <p>
 * 依赖 RabbitMQ 插件 {@code rabbitmq_delayed_message_exchange}，
 * 发送时通过消息头 {@code x-delay}（毫秒）控制延迟。
 * <p>
 * 普通即时消息走 {@link #DELAY_EXCHANGE}（直连）；延迟消息走 {@link #DEFAULT_DELAY_EXCHANGE}。
 */
public final class DelayExchangeBuilder {

    /** 默认延迟消息交换机名称 */
    public static final String DEFAULT_DELAY_EXCHANGE = "nova.delayed.exchange";

    /** 默认直连交换机名称（即时投递） */
    public static final String DELAY_EXCHANGE = "nova.direct.exchange";

    private DelayExchangeBuilder() {
    }

    /**
     * 构建默认名称的延迟交换机（type = x-delayed-message）。
     */
    public static CustomExchange buildExchange() {
        return buildExchange(DEFAULT_DELAY_EXCHANGE);
    }

    /**
     * 构建指定名称的延迟交换机。
     *
     * @param exchangeName 交换机名称
     */
    public static CustomExchange buildExchange(String exchangeName) {
        Map<String, Object> args = new HashMap<>(2);
        // 内部路由类型为 direct，routingKey 通常等于队列名
        args.put("x-delayed-type", "direct");
        return new CustomExchange(exchangeName, "x-delayed-message", true, false, args);
    }
}
