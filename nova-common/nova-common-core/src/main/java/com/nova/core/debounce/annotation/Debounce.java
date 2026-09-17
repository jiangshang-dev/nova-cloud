package com.nova.core.debounce.annotation;

import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * 接口防重复提交（防抖）。建议标注在增删改接口上。
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface Debounce {

    /**
     * 防重过期时间，单位毫秒，默认 2000ms。
     */
    long expire() default 1000 * 2;
}
