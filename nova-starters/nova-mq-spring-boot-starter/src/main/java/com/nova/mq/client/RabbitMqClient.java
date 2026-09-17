package com.nova.mq.client;

import com.nova.mq.annotation.RabbitComponent;
import com.nova.mq.exchange.DelayExchangeBuilder;
import com.nova.mq.properties.NovaMqProperties;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.amqp.core.AbstractExchange;
import org.springframework.amqp.core.Binding;
import org.springframework.amqp.core.BindingBuilder;
import org.springframework.amqp.core.CustomExchange;
import org.springframework.amqp.core.DirectExchange;
import org.springframework.amqp.core.Exchange;
import org.springframework.amqp.core.Message;
import org.springframework.amqp.core.MessageProperties;
import org.springframework.amqp.core.Queue;
import org.springframework.amqp.core.TopicExchange;
import org.springframework.amqp.rabbit.annotation.RabbitListener;
import org.springframework.amqp.rabbit.core.RabbitAdmin;
import org.springframework.amqp.rabbit.core.RabbitTemplate;
import org.springframework.aop.support.AopUtils;
import org.springframework.context.ApplicationContext;
import org.springframework.core.annotation.AnnotationUtils;
import org.springframework.util.ObjectUtils;

import java.lang.reflect.Method;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

/**
 * RabbitMQ 生产客户端（由 {@code nova-mq-spring-boot-starter} 自动注册为 Bean）。
 * <p>
 * 常用能力：
 * <ul>
 *   <li>{@link #sendMessage(String, Object)} — 即时发送到直连交换机，routingKey = 队列名</li>
 *   <li>{@link #sendMessage(String, Object, Integer)} — 延迟发送（毫秒），走延迟交换机</li>
 *   <li>{@link #put(String, Object)} + {@link #sendMessage(String)} — 链式组装 Map 后发送</li>
 *   <li>启动时扫描 {@link RabbitComponent}，按 {@link RabbitListener} 自动声明队列并绑定</li>
 * </ul>
 * <pre>
 * {@code
 * @Autowired
 * private RabbitMqClient rabbitMqClient;
 *
 * rabbitMqClient.sendMessage("demo.queue", new BaseMap().set("id", 1));
 * rabbitMqClient.sendMessage("demo.queue", payload, 5000); // 延迟 5 秒
 * }
 * </pre>
 */
@Slf4j
public class RabbitMqClient {

    private final RabbitAdmin rabbitAdmin;
    private final RabbitTemplate rabbitTemplate;
    private final ApplicationContext applicationContext;
    private final NovaMqProperties properties;

    /** 链式 put 暂存区，配合 {@link #sendMessage(String)} 使用 */
    private final Map<String, Object> sentObj = new HashMap<>();

    public RabbitMqClient(RabbitAdmin rabbitAdmin,
                          RabbitTemplate rabbitTemplate,
                          ApplicationContext applicationContext,
                          NovaMqProperties properties) {
        this.rabbitAdmin = rabbitAdmin;
        this.rabbitTemplate = rabbitTemplate;
        this.applicationContext = applicationContext;
        this.properties = properties;
    }

    /**
     * 扫描 {@link RabbitComponent} Bean，自动创建其 {@link RabbitListener} 声明的队列。
     */
    @PostConstruct
    public void initQueue() {
        Map<String, Object> beans = applicationContext.getBeansWithAnnotation(RabbitComponent.class);
        for (Object bean : beans.values()) {
            Class<?> clazz = AopUtils.getTargetClass(bean);
            RabbitListener classListener = AnnotationUtils.findAnnotation(clazz, RabbitListener.class);
            if (classListener != null) {
                createQueue(classListener);
            }
            for (Method method : clazz.getMethods()) {
                RabbitListener methodListener = AnnotationUtils.findAnnotation(method, RabbitListener.class);
                if (methodListener != null) {
                    createQueue(methodListener);
                }
            }
        }
    }

    /**
     * 按 {@link RabbitListener#queues()} 声明队列并绑定直连交换机。
     */
    private void createQueue(RabbitListener rabbitListener) {
        String[] queues = rabbitListener.queues();
        if (ObjectUtils.isEmpty(queues)) {
            return;
        }
        DirectExchange directExchange = createExchange(properties.getDirectExchange());
        rabbitAdmin.declareExchange(directExchange);
        for (String queueName : queues) {
            ensureQueueBound(queueName, directExchange);
        }
    }

    /**
     * 手动创建队列并绑定到配置的直连交换机（routingKey = 队列名）。
     *
     * @param queueName 队列名
     * @return true 表示新建；false 表示队列已存在
     */
    public boolean createQueue(String queueName) {
        DirectExchange directExchange = createExchange(properties.getDirectExchange());
        rabbitAdmin.declareExchange(directExchange);
        return ensureQueueBound(queueName, directExchange);
    }

    private boolean ensureQueueBound(String queueName, DirectExchange directExchange) {
        Properties result = rabbitAdmin.getQueueProperties(queueName);
        if (result == null || result.isEmpty()) {
            Queue queue = new Queue(queueName);
            addQueue(queue);
            Binding binding = BindingBuilder.bind(queue).to(directExchange).with(queueName);
            rabbitAdmin.declareBinding(binding);
            log.info("创建队列: {}", queueName);
            return true;
        }
        log.info("已有队列: {}", queueName);
        return false;
    }

    /**
     * 即时发送：直连交换机 + routingKey = queueName。
     *
     * @param queueName 队列名（同时作为 routingKey）
     * @param params    消息体（推荐 {@link com.nova.mq.model.BaseMap} 或 POJO，JSON 序列化）
     */
    public void sendMessage(String queueName, Object params) {
        log.debug("发送消息到队列: {}", queueName);
        rabbitTemplate.convertAndSend(properties.getDirectExchange(), queueName, params);
    }

    /**
     * 将此前 {@link #put} 的键值作为消息体发送，发送后清空暂存。
     *
     * @param queueName 队列名
     */
    public void sendMessage(String queueName) {
        send(queueName, new HashMap<>(this.sentObj), 0);
        this.sentObj.clear();
    }

    /**
     * 链式写入待发送字段，最后调用 {@link #sendMessage(String)}。
     */
    public RabbitMqClient put(String key, Object value) {
        this.sentObj.put(key, value);
        return this;
    }

    /**
     * 延迟发送（毫秒），走延迟交换机；expiration &lt;= 0 时立即投递。
     *
     * @param queueName  队列名
     * @param params     消息体
     * @param expiration 延迟毫秒数
     */
    public void sendMessage(String queueName, Object params, Integer expiration) {
        send(queueName, params, expiration);
    }

    /**
     * 声明延迟交换机与绑定后发送，消息头写入 {@code x-delay}。
     */
    private void send(String queueName, Object params, Integer expiration) {
        Queue queue = new Queue(queueName);
        addQueue(queue);
        CustomExchange customExchange = DelayExchangeBuilder.buildExchange(properties.getDelayExchange());
        rabbitAdmin.declareExchange(customExchange);
        Binding binding = BindingBuilder.bind(queue).to(customExchange).with(queueName).noargs();
        rabbitAdmin.declareBinding(binding);
        log.debug("延迟发送时间: {}, queue={}, delayMs={}",
                new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date()), queueName, expiration);
        rabbitTemplate.convertAndSend(properties.getDelayExchange(), queueName, params, message -> {
            if (expiration != null && expiration > 0) {
                message.getMessageProperties().setHeader("x-delay", expiration);
            }
            return message;
        });
    }

    /**
     * 按 contentType 构造简单 Message（字节来自 {@code msg.toString()}）。
     */
    public Message getMessage(String messageType, Object msg) {
        MessageProperties messageProperties = new MessageProperties();
        messageProperties.setContentType(messageType);
        return new Message(String.valueOf(msg).getBytes(), messageProperties);
    }

    /**
     * 向指定 Topic 交换机按 routingKey 发送。
     */
    public void sendMessageToExchange(TopicExchange topicExchange, String routingKey, Object msg) {
        Message message = getMessage(MessageProperties.CONTENT_TYPE_JSON, msg);
        rabbitTemplate.send(topicExchange.getName(), routingKey, message);
    }

    /**
     * 声明交换机后向 Topic 交换机发送（routingKey 为 msg 字符串）。
     */
    public void sendMessageToExchange(TopicExchange topicExchange, AbstractExchange exchange, String msg) {
        addExchange(exchange);
        log.info("RabbitMQ send {} -> {}", exchange.getName(), msg);
        rabbitTemplate.convertAndSend(topicExchange.getName(), msg);
    }

    /**
     * 从队列拉取一条消息（同步，可能返回 null）。
     */
    public String receiveFromQueue(String queueName) {
        return receiveFromQueue(DirectExchange.DEFAULT, queueName);
    }

    /**
     * 绑定直连交换机后从队列拉取一条消息。
     */
    public String receiveFromQueue(DirectExchange directExchange, String queueName) {
        Queue queue = new Queue(queueName);
        addQueue(queue);
        Binding binding = BindingBuilder.bind(queue).to(directExchange).withQueueName();
        rabbitAdmin.declareBinding(binding);
        Object messages = rabbitTemplate.receiveAndConvert(queueName);
        return messages == null ? null : String.valueOf(messages);
    }

    /** 声明交换机 */
    public void addExchange(AbstractExchange exchange) {
        rabbitAdmin.declareExchange(exchange);
    }

    /** 删除交换机 */
    public boolean deleteExchange(String exchangeName) {
        return rabbitAdmin.deleteExchange(exchangeName);
    }

    /** 声明匿名队列（exclusive / autoDelete） */
    public Queue addQueue() {
        return rabbitAdmin.declareQueue();
    }

    /** 声明指定队列 */
    public String addQueue(Queue queue) {
        return rabbitAdmin.declareQueue(queue);
    }

    /** 按条件删除队列 */
    public void deleteQueue(String queueName, boolean unused, boolean empty) {
        rabbitAdmin.deleteQueue(queueName, unused, empty);
    }

    /** 删除队列 */
    public boolean deleteQueue(String queueName) {
        return rabbitAdmin.deleteQueue(queueName);
    }

    /** 队列绑定到 Topic 交换机 */
    public void addBinding(Queue queue, TopicExchange exchange, String routingKey) {
        Binding binding = BindingBuilder.bind(queue).to(exchange).with(routingKey);
        rabbitAdmin.declareBinding(binding);
    }

    /** Exchange 绑定到 Topic 交换机 */
    public void addBinding(Exchange exchange, TopicExchange topicExchange, String routingKey) {
        Binding binding = BindingBuilder.bind(exchange).to(topicExchange).with(routingKey);
        rabbitAdmin.declareBinding(binding);
    }

    /** 移除绑定 */
    public void removeBinding(Binding binding) {
        rabbitAdmin.removeBinding(binding);
    }

    /**
     * 创建持久化、非自动删除的直连交换机。
     */
    public DirectExchange createExchange(String exchangeName) {
        return new DirectExchange(exchangeName, true, false);
    }
}
