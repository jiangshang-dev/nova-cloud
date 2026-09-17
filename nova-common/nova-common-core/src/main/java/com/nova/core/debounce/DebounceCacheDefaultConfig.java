package com.nova.core.debounce;

import cn.hutool.core.util.StrUtil;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 本地内存防抖缓存（无 Redis 时兜底）。
 */
@Configuration
@EnableScheduling
public class DebounceCacheDefaultConfig {

    private static final Map<String, Long> CACHE_MAP = new ConcurrentHashMap<>();

    @Bean
    @ConditionalOnMissingBean(DebounceCache.class)
    public DebounceCache debounceMemoryCache() {
        return new DebounceMemoryCache();
    }

    public static class DebounceMemoryCache implements DebounceCache {

        @Scheduled(fixedDelay = 5000)
        public void autoClearExpireKey() {
            long now = System.currentTimeMillis();
            CACHE_MAP.entrySet().removeIf(entry -> now > entry.getValue());
        }

        @Override
        public void put(String key, long expireEpochMs) {
            if (StrUtil.isBlank(key)) {
                return;
            }
            CACHE_MAP.put(key, expireEpochMs);
        }

        @Override
        public Long get(String key) {
            if (StrUtil.isBlank(key)) {
                return null;
            }
            return CACHE_MAP.get(key);
        }

        @Override
        public void remove(String key) {
            if (StrUtil.isBlank(key)) {
                return;
            }
            CACHE_MAP.remove(key);
        }

        @Override
        public boolean containsKey(String key) {
            if (StrUtil.isBlank(key)) {
                return false;
            }
            return CACHE_MAP.containsKey(key);
        }
    }
}
