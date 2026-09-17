package com.nova.auth.service;

import cn.hutool.captcha.CaptchaUtil;
import cn.hutool.captcha.LineCaptcha;
import cn.hutool.core.util.StrUtil;
import com.nova.core.exception.ServiceException;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.util.concurrent.TimeUnit;

/**
 * 图形验证码（Hutool + Redis）。
 */
@Service
@RequiredArgsConstructor
public class CaptchaService {

    private static final String CAPTCHA_PREFIX = "nova:auth:captcha:";

    private final StringRedisTemplate redisTemplate;

    @Value("${nova.auth.captcha.expire-minutes:5}")
    private long expireMinutes;

    @Value("${nova.auth.captcha.width:130}")
    private int width;

    @Value("${nova.auth.captcha.height:40}")
    private int height;

    @Value("${nova.auth.captcha.length:4}")
    private int length;

    /**
     * 生成验证码图片（data:image/...;base64,...），并写入 Redis。
     */
    public String createImage(String checkKey) {
        if (StrUtil.isBlank(checkKey)) {
            throw new ServiceException("验证码标识不能为空");
        }
        LineCaptcha captcha = CaptchaUtil.createLineCaptcha(width, height, length, 20);
        redisTemplate.opsForValue().set(
                CAPTCHA_PREFIX + checkKey,
                captcha.getCode().toLowerCase(),
                expireMinutes,
                TimeUnit.MINUTES
        );
        return captcha.getImageBase64Data();
    }

    /**
     * 校验验证码（忽略大小写，一次性）。
     */
    public void validate(String checkKey, String captcha) {
        if (StrUtil.hasBlank(checkKey, captcha)) {
            throw new ServiceException("请输入验证码");
        }
        String key = CAPTCHA_PREFIX + checkKey;
        String cached = redisTemplate.opsForValue().get(key);
        redisTemplate.delete(key);
        if (StrUtil.isBlank(cached)) {
            throw new ServiceException("验证码已失效，请刷新后重试");
        }
        if (!StrUtil.equalsIgnoreCase(cached, captcha.trim())) {
            throw new ServiceException("验证码错误");
        }
    }
}
