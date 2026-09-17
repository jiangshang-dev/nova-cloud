package com.nova.core.enums;

/**
 * 业务枚举统一契约。
 *
 * @param <T> code 类型
 */
public interface IBaseEnum<T> {

    T getCode();

    String getMessage();
}
