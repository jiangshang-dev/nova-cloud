package com.nova.redis.debounce;

import cn.hutool.core.util.StrUtil;
import com.nova.core.debounce.DebounceCache;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;

import java.util.concurrent.TimeUnit;

/**
 * 基于 Redis 的防抖缓存。
 */
@RequiredArgsConstructor
public class DebounceRedisCache implements DebounceCache {

    private final StringRedisTemplate redisTemplate;

    @Override
    public void put(String key, long expireEpochMs) {
        if (StrUtil.isBlank(key)) {
            return;
        }
        long ttl = expireEpochMs - System.currentTimeMillis();
        if (ttl <= 0) {
            return;
        }
        redisTemplate.opsForValue().set(key, String.valueOf(expireEpochMs), ttl, TimeUnit.MILLISECONDS);
    }

    @Override
    public Long get(String key) {
        if (StrUtil.isBlank(key)) {
            return null;
        }
        String value = redisTemplate.opsForValue().get(key);
        if (StrUtil.isBlank(value)) {
            return null;
        }
        return Long.valueOf(value);
    }

    @Override
    public void remove(String key) {
        if (StrUtil.isBlank(key)) {
            return;
        }
        redisTemplate.delete(key);
    }

    @Override
    public boolean containsKey(String key) {
        if (StrUtil.isBlank(key)) {
            return false;
        }
        Boolean has = redisTemplate.hasKey(key);
        return Boolean.TRUE.equals(has);
    }
}
