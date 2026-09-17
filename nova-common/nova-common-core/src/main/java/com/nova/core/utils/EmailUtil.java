package com.nova.core.utils;

import cn.hutool.extra.mail.MailUtil;
import com.ruiyada.common.core.properties.MailProperties;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;
import org.springframework.stereotype.Component;

import javax.annotation.Resource;
import java.util.List;
import java.util.concurrent.CompletableFuture;


@Slf4j
@Component
public class EmailUtil {
    @Resource
    private MailProperties properties;
    @Resource
    private ThreadPoolTaskExecutor executor;

    /**
     * 发送html邮件
     *
     * @param to          收件人
     * @param subject     主题
     * @param htmlContent 内容
     */
    public void sendHtml(String to, String subject, String htmlContent) {
        CompletableFuture.runAsync(() -> {
            MailUtil.send(properties.getAccount(), to, subject, htmlContent, true);
        }, executor).whenComplete((v, t) -> {
            log.info("异步任务执行完成");
        });
    }

    /**
     * 发送文本邮件
     *
     * @param to          收件人
     * @param subject     主题
     * @param textContent 内容
     */
    public void sendText(String to, String subject, String textContent) {
        CompletableFuture.runAsync(() -> {
            MailUtil.send(properties.getAccount(), to, subject, textContent, false);
        }, executor).whenComplete((v, t) -> {
            log.info("异步任务执行完成");
        });
    }

    /**
     * 发送文本邮件
     *
     * @param to          收件人
     * @param subject     主题
     * @param textContent 内容
     */
    public void sendText(List<String> to, String subject, String textContent) {
        CompletableFuture.runAsync(() -> {
            MailUtil.send(properties.getAccount(), to, subject, textContent, false);
        }, executor).whenComplete((v, t) -> {
            log.info("异步任务执行完成");
        });
    }
}