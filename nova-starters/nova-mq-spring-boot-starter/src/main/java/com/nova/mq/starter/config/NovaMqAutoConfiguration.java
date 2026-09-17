package com.nova.mq.starter.config;

import com.nova.mq.client.RabbitMqClient;
import com.nova.mq.properties.NovaMqProperties;
import org.springframework.amqp.core.AcknowledgeMode;
import org.springframework.amqp.rabbit.annotation.RabbitListenerConfigurer;
import org.springframework.amqp.rabbit.config.SimpleRabbitListenerContainerFactory;
import org.springframework.amqp.rabbit.connection.ConnectionFactory;
import org.springframework.amqp.rabbit.core.RabbitAdmin;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.amqp.rabbit.listener.RabbitListenerEndpointRegistrar;
import org.springframework.amqp.rabbit.listener.SimpleMessageListenerContainer;
import org.springframework.amqp.rabbit.listener.api.RabbitListenerErrorHandler;
import org.springframework.amqp.support.ConsumerTagStrategy;
import org.springframework.amqp.support.converter.Jackson2JsonMessageConverter;
import org.springframework.amqp.support.converter.MessageConverter;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.boot.autoconfigure.AutoConfigureBefore;
import org.springframework.boot.autoconfigure.amqp.RabbitAutoConfiguration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnClass;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.ApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.messaging.converter.MappingJackson2MessageConverter;
import org.springframework.messaging.handler.annotation.support.DefaultMessageHandlerMethodFactory;
import org.springframework.messaging.handler.annotation.support.MessageHandlerMethodFactory;

import java.util.UUID;

/**
 * Nova RabbitMQ 自动配置。
 * <p>
 * 业务侧：配置 {@code spring.rabbitmq.*}，注入 {@link RabbitMqClient} 发送；
 * 使用 {@code @RabbitComponent} + {@code @RabbitListener} 自行实现消费。
 */
@AutoConfiguration
@AutoConfigureBefore(RabbitAutoConfiguration.class)
@ConditionalOnClass(RabbitTemplate.class)
@ConditionalOnProperty(prefix = "nova.mq", name = "enabled", havingValue = "true", matchIfMissing = true)
@EnableConfigurationProperties(NovaMqProperties.class)
public class NovaMqAutoConfiguration implements RabbitListenerConfigurer {

    private MessageHandlerMethodFactory messageHandlerMethodFactory;

    @Bean
    @ConditionalOnMissingBean
    public RabbitAdmin rabbitAdmin(ConnectionFactory connectionFactory) {
        RabbitAdmin rabbitAdmin = new RabbitAdmin(connectionFactory);
        rabbitAdmin.setIgnoreDeclarationExceptions(true);
        return rabbitAdmin;
    }

    @Bean
    @ConditionalOnMissingBean
    public RabbitMqClient rabbitMqClient(RabbitAdmin rabbitAdmin,
                                         RabbitTemplate rabbitTemplate,
                                         ApplicationContext applicationContext,
                                         NovaMqProperties properties) {
        return new RabbitMqClient(rabbitAdmin, rabbitTemplate, applicationContext, properties);
    }

    @Bean
    @ConditionalOnMissingBean(name = "messageListenerContainer")
    public SimpleMessageListenerContainer messageListenerContainer(ConnectionFactory connectionFactory,
                                                                   NovaMqProperties properties) {
        SimpleMessageListenerContainer container = new SimpleMessageListenerContainer();
        container.setConnectionFactory(connectionFactory);
        container.setAcknowledgeMode(AcknowledgeMode.MANUAL);
        container.setConcurrentConsumers(properties.getConcurrentConsumers());
        container.setMaxConcurrentConsumers(properties.getMaxConcurrentConsumers());
        container.setDefaultRequeueRejected(properties.isDefaultRequeueRejected());
        container.setConsumerTagStrategy((ConsumerTagStrategy) queue -> queue + "_" + UUID.randomUUID());
        return container;
    }

    @Bean
    @ConditionalOnMissingBean
    public RabbitListenerErrorHandler rabbitListenerErrorHandler() {
        return (amqpMessage, channel, message, exception) -> {
            throw exception;
        };
    }

    @Bean
    @ConditionalOnMissingBean
    public MessageHandlerMethodFactory messageHandlerMethodFactory(
            MappingJackson2MessageConverter consumerJackson2MessageConverter) {
        DefaultMessageHandlerMethodFactory factory = new DefaultMessageHandlerMethodFactory();
        factory.setMessageConverter(consumerJackson2MessageConverter);
        this.messageHandlerMethodFactory = factory;
        return factory;
    }

    @Bean
    @ConditionalOnMissingBean(name = "rabbitListenerContainerFactory")
    public SimpleRabbitListenerContainerFactory rabbitListenerContainerFactory(ConnectionFactory connectionFactory,
                                                                               NovaMqProperties properties,
                                                                               MessageConverter messageConverter) {
        SimpleRabbitListenerContainerFactory factory = new SimpleRabbitListenerContainerFactory();
        factory.setConnectionFactory(connectionFactory);
        factory.setConcurrentConsumers(properties.getConcurrentConsumers());
        factory.setMaxConcurrentConsumers(properties.getMaxConcurrentConsumers());
        factory.setAcknowledgeMode(AcknowledgeMode.MANUAL);
        factory.setPrefetchCount(properties.getPrefetch());
        factory.setMessageConverter(messageConverter);
        return factory;
    }

    @Bean
    @ConditionalOnMissingBean
    public MappingJackson2MessageConverter consumerJackson2MessageConverter() {
        return new MappingJackson2MessageConverter();
    }

    @Bean
    @ConditionalOnMissingBean
    public MessageConverter messageConverter() {
        return new Jackson2JsonMessageConverter();
    }

    @Override
    public void configureRabbitListeners(RabbitListenerEndpointRegistrar registrar) {
        if (messageHandlerMethodFactory != null) {
            registrar.setMessageHandlerMethodFactory(messageHandlerMethodFactory);
        }
    }
}
