package com.nova.security.config;

import com.nova.security.jwt.JwtTokenProvider;
import com.nova.security.properties.InnerAuthProperties;
import com.nova.security.properties.JwtProperties;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;

/**
 * 安全自动配置：JWT + 内部调用属性。
 * <p>
 * Feign 拦截器见 {@link NovaFeignInnerAuthAutoConfiguration}（仅在 classpath 存在 Feign 时加载）。
 */
@AutoConfiguration
@EnableConfigurationProperties({JwtProperties.class, InnerAuthProperties.class})
public class NovaSecurityAutoConfiguration {

    @Bean
    @ConditionalOnMissingBean
    public JwtTokenProvider jwtTokenProvider(JwtProperties jwtProperties) {
        return new JwtTokenProvider(jwtProperties);
    }
}
