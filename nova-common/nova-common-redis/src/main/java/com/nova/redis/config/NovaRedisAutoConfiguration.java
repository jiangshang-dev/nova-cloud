package com.nova.redis.config;

import com.nova.core.debounce.DebounceCache;
import com.nova.redis.debounce.DebounceRedisCache;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnBean;
import org.springframework.boot.autoconfigure.condition.ConditionalOnClass;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import org.springframework.data.redis.core.StringRedisTemplate;

/**
 * Redis 模块自动装配：有 StringRedisTemplate 时优先用 Redis 防抖缓存。
 */
@AutoConfiguration(afterName = "org.springframework.boot.autoconfigure.data.redis.RedisAutoConfiguration")
@ConditionalOnClass(StringRedisTemplate.class)
public class NovaRedisAutoConfiguration {

    @Bean
    @Primary
    @ConditionalOnBean(StringRedisTemplate.class)
    public DebounceCache debounceRedisCache(StringRedisTemplate stringRedisTemplate) {
        return new DebounceRedisCache(stringRedisTemplate);
    }
}
