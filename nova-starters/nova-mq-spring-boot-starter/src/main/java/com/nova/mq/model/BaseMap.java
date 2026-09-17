package com.nova.mq.model;

import java.util.HashMap;
import java.util.Map;

/**
 * MQ 常用消息载体，继承 {@link HashMap}，支持链式 {@link #set} 与泛型 {@link #get(String)}。
 * <pre>
 * {@code
 * BaseMap map = new BaseMap().set("id", 1L).set("title", "hello");
 * Long id = map.get("id");
 * }
 * </pre>
 */
public class BaseMap extends HashMap<String, Object> {

    private static final long serialVersionUID = 1L;

    public BaseMap() {
        super();
    }

    /**
     * 从已有 Map 拷贝构造。
     */
    public BaseMap(Map<? extends String, ?> map) {
        super(map);
    }

    /**
     * 按 key 取值并转型（调用方需保证类型正确）。
     */
    @SuppressWarnings("unchecked")
    public <T> T get(String key) {
        return (T) super.get(key);
    }

    /**
     * 链式 put。
     */
    public BaseMap set(String key, Object value) {
        put(key, value);
        return this;
    }
}
