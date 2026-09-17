package com.nova.log.annotation;

import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * 操作日志注解（参考 Jeecg {@code @AutoLog}）。
 * <pre>
 * {@code @AutoLog(value = "图书-添加")}
 * </pre>
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface AutoLog {

    /** 日志标题 / 内容 */
    String value() default "";

    /**
     * 业务类型：0其它 1新增 2修改 3删除 4授权 5导出 6导入；
     * 为 0 且未显式指定时，按方法名自动推断。
     */
    int businessType() default 0;

    /** 是否保存请求参数 */
    boolean saveRequestData() default true;

    /** 是否保存响应结果 */
    boolean saveResponseData() default false;
}
