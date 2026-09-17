package com.nova.security.config;

import com.nova.security.feign.FeignInnerAuthRequestInterceptor;
import com.nova.security.properties.InnerAuthProperties;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnClass;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;

/**
 * Feign 内部免登拦截器（仅当 classpath 存在 feign.RequestInterceptor 时生效）。
 * <p>
 * 网关等无 OpenFeign 的模块不会加载本配置，避免 NoClassDefFoundError。
 */
@AutoConfiguration(after = NovaSecurityAutoConfiguration.class)
@ConditionalOnClass(name = "feign.RequestInterceptor")
public class NovaFeignInnerAuthAutoConfiguration {

    @Bean
    @ConditionalOnMissingBean
    @ConditionalOnProperty(prefix = "nova.security.inner", name = "enabled", havingValue = "true", matchIfMissing = true)
    public FeignInnerAuthRequestInterceptor feignInnerAuthRequestInterceptor(InnerAuthProperties properties) {
        return new FeignInnerAuthRequestInterceptor(properties);
    }
}
