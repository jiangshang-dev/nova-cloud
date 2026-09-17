package com.nova.auth.service;

import cn.hutool.core.util.RandomUtil;
import cn.hutool.core.util.StrUtil;
import cn.hutool.extra.mail.MailAccount;
import cn.hutool.extra.mail.MailUtil;
import com.nova.core.exception.ServiceException;
import com.nova.core.properties.MailProperties;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.util.concurrent.TimeUnit;

/**
 * 邮箱验证码服务（Hutool 发信 + Redis 防刷）。
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class EmailCodeService {

    private static final String CODE_PREFIX = "nova:auth:email:code:";
    private static final String RETRY_PREFIX = "nova:auth:email:retry:";

    private final StringRedisTemplate redisTemplate;
    private final MailProperties mailProperties;

    @Value("${nova.auth.email-code.expire-minutes:5}")
    private long codeExpireMinutes;

    @Value("${nova.auth.email-code.retry-seconds:60}")
    private long codeRetrySeconds;

    @Value("${nova.auth.email-code.length:6}")
    private int codeLength;

    @Value("${nova.auth.email-code.title:NovaCloud 验证码}")
    private String mailTitle;

    public void sendEmailCode(String email, String scene) {
        if (StrUtil.isBlank(email)) {
            throw new ServiceException("邮箱不能为空");
        }
        String safeScene = StrUtil.blankToDefault(scene, "login");
        String retryKey = RETRY_PREFIX + safeScene + ":" + email;

        if (Boolean.TRUE.equals(redisTemplate.hasKey(retryKey))) {
            throw new ServiceException("验证码发送频繁，请稍后再试");
        }

        String code = RandomUtil.randomNumbers(codeLength);
        String codeKey = CODE_PREFIX + safeScene + ":" + email;
        redisTemplate.opsForValue().set(codeKey, code, codeExpireMinutes, TimeUnit.MINUTES);
        redisTemplate.opsForValue().set(retryKey, "1", codeRetrySeconds, TimeUnit.SECONDS);

        try {
            MailAccount account = mailProperties.getAccount();
            if (account == null || StrUtil.isBlank(account.getFrom())) {
                throw new ServiceException("邮箱未配置 nova.mail.account.from / user");
            }
            String content = String.format("您的验证码是：%s，%s分钟内有效。请勿泄露给他人。", code, codeExpireMinutes);
            log.info("发送邮箱验证码, email: {}, scene: {}, code: {}", email, safeScene, code);
            MailUtil.send(account, email, mailTitle, content, false);
            log.info("发送邮箱验证码成功, email: {}, scene: {}", email, safeScene);
        } catch (ServiceException e) {
            redisTemplate.delete(codeKey);
            redisTemplate.delete(retryKey);
            throw e;
        } catch (Exception e) {
            redisTemplate.delete(codeKey);
            redisTemplate.delete(retryKey);
            log.error("发送邮箱验证码失败, email: {}", email, e);
            throw new ServiceException("发送邮箱验证码失败");
        }
    }

    public void validateCode(String email, String scene, String code) {
        if (StrUtil.hasBlank(email, code)) {
            throw new ServiceException("邮箱或验证码不能为空");
        }
        String safeScene = StrUtil.blankToDefault(scene, "login");
        String codeKey = CODE_PREFIX + safeScene + ":" + email;
        String cached = redisTemplate.opsForValue().get(codeKey);
        if (StrUtil.isBlank(cached)) {
            throw new ServiceException("验证码已失效，请重新获取");
        }
        if (!StrUtil.equals(cached, code)) {
            throw new ServiceException("验证码错误");
        }
        redisTemplate.delete(codeKey);
    }
}
