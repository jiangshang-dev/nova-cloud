package com.nova.mq.core;

import org.springframework.amqp.core.Message;
import org.springframework.amqp.core.MessageProperties;
import org.springframework.amqp.support.converter.MessageConversionException;
import org.springframework.amqp.support.converter.MessageConverter;

import java.io.ByteArrayInputStream;
import java.io.ObjectInputStream;
import java.util.Map;

/**
 * Map / 文本消息转换器。
 * <p>
 * 发送：将对象 {@code toString()} 后按字节写入消息体。<br>
 * 接收：contentType 含 text 时按字符串解析，否则按 Java 序列化还原为 {@link Map}。
 * <p>
 * 默认生产/消费推荐使用 Jackson JSON（见 starter 自动配置的 {@code MessageConverter}），
 * 本类主要用于兼容历史二进制 Map 消息。
 */
public class MapMessageConverter implements MessageConverter {

    /**
     * 对象转 AMQP Message。
     */
    @Override
    public Message toMessage(Object object, MessageProperties messageProperties) throws MessageConversionException {
        return new Message(String.valueOf(object).getBytes(), messageProperties);
    }

    /**
     * AMQP Message 转对象（String 或 Map）。
     */
    @Override
    public Object fromMessage(Message message) throws MessageConversionException {
        String contentType = message.getMessageProperties().getContentType();
        if (contentType != null && contentType.contains("text")) {
            return new String(message.getBody());
        }
        try (ObjectInputStream objInt = new ObjectInputStream(new ByteArrayInputStream(message.getBody()))) {
            return (Map<?, ?>) objInt.readObject();
        } catch (Exception e) {
            throw new MessageConversionException("Map 消息反序列化失败", e);
        }
    }
}
