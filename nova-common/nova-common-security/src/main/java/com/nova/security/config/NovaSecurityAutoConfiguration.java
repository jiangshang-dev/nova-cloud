package com.nova.security.config;

import com.nova.security.feign.FeignInnerAuthRequestInterceptor;
import com.nova.security.jwt.JwtTokenProvider;
import com.nova.security.properties.InnerAuthProperties;
import com.nova.security.properties.JwtProperties;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnClass;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;

/**
 * 安全自动配置：JWT + 内部调用免登。
 */
@AutoConfiguration
@EnableConfigurationProperties({JwtProperties.class, InnerAuthProperties.class})
public class NovaSecurityAutoConfiguration {

    @Bean
    @ConditionalOnMissingBean
    public JwtTokenProvider jwtTokenProvider(JwtProperties jwtProperties) {
        return new JwtTokenProvider(jwtProperties);
    }

    @Bean
    @ConditionalOnMissingBean
    @ConditionalOnClass(name = "feign.RequestInterceptor")
    @ConditionalOnProperty(prefix = "nova.security.inner", name = "enabled", havingValue = "true", matchIfMissing = true)
    public FeignInnerAuthRequestInterceptor feignInnerAuthRequestInterceptor(InnerAuthProperties properties) {
        return new FeignInnerAuthRequestInterceptor(properties);
    }
}
