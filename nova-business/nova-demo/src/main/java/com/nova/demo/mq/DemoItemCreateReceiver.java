package com.nova.demo.mq;

import com.nova.demo.constants.DemoMqConstants;
import com.nova.mq.annotation.RabbitComponent;
import com.nova.mq.core.BaseRabbitMqHandler;
import com.nova.mq.model.BaseMap;
import com.rabbitmq.client.Channel;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.rabbit.annotation.RabbitHandler;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.amqp.support.AmqpHeaders;
import org.springframework.messaging.handler.annotation.Header;

/**
 * DemoItem 创建消息消费示例。
 * <p>
 * 配合 {@link com.nova.demo.service.DemoItemService#create} 发送的消息，演示如何自行实现消费端。
 */
@Slf4j
@RabbitComponent("demoItemCreateReceiver")
@RabbitListener(queues = DemoMqConstants.DEMO_ITEM_CREATE_QUEUE)
public class DemoItemCreateReceiver extends BaseRabbitMqHandler<BaseMap> {

    @RabbitHandler
    public void onMessage(BaseMap map,
                          Channel channel,
                          @Header(AmqpHeaders.DELIVERY_TAG) Long deliveryTag) {
        super.onMessage(map, deliveryTag, channel, (data, ch) -> {
            log.info("收到 DemoItem 创建消息: id={}, title={}", data.get("id"), data.get("title"));
            // TODO: 在此补充真实业务（如写库、发通知、同步缓存等）
        });
    }
}
