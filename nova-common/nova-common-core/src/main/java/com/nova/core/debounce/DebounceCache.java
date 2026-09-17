package com.nova.core.debounce;

/**
 * 防抖缓存抽象，默认内存实现；引入 redis 模块后可替换为 Redis。
 */
public interface DebounceCache {

    /**
     * @param key            键
     * @param expireEpochMs  过期时间戳（毫秒）
     */
    void put(String key, long expireEpochMs);

    /**
     * @return 过期时间戳，不存在返回 null
     */
    Long get(String key);

    void remove(String key);

    boolean containsKey(String key);
}
