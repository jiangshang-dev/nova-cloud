package com.nova.core.utils;

import cn.hutool.extra.mail.MailUtil;
import com.nova.core.properties.MailProperties;
import jakarta.annotation.Resource;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.concurrent.CompletableFuture;

@Slf4j
@Component
@ConditionalOnProperty(prefix = "nova.mail", name = "enabled", havingValue = "true")
public class EmailUtil {

    @Resource
    private MailProperties properties;

    @Resource
    private ThreadPoolTaskExecutor executor;

    /**
     * 发送 html 邮件。
     */
    public void sendHtml(String to, String subject, String htmlContent) {
        CompletableFuture.runAsync(() ->
                MailUtil.send(properties.getAccount(), to, subject, htmlContent, true), executor
        ).whenComplete((v, t) -> {
            if (t != null) {
                log.error("发送 HTML 邮件失败", t);
            } else {
                log.info("异步邮件任务执行完成");
            }
        });
    }

    /**
     * 发送文本邮件。
     */
    public void sendText(String to, String subject, String textContent) {
        CompletableFuture.runAsync(() ->
                MailUtil.send(properties.getAccount(), to, subject, textContent, false), executor
        ).whenComplete((v, t) -> {
            if (t != null) {
                log.error("发送文本邮件失败", t);
            } else {
                log.info("异步邮件任务执行完成");
            }
        });
    }

    /**
     * 批量发送文本邮件。
     */
    public void sendText(List<String> to, String subject, String textContent) {
        CompletableFuture.runAsync(() ->
                MailUtil.send(properties.getAccount(), to, subject, textContent, false), executor
        ).whenComplete((v, t) -> {
            if (t != null) {
                log.error("批量发送文本邮件失败", t);
            } else {
                log.info("异步邮件任务执行完成");
            }
        });
    }
}
