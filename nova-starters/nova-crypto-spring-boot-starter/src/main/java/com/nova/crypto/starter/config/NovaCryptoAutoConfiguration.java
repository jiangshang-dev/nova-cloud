package com.nova.crypto.starter.config;

import com.nova.crypto.properties.CryptoProperties;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

/**
 * 国密加解密自动配置：启用 {@link CryptoProperties}（prefix = nova.crypto）。
 */
@AutoConfiguration
@EnableConfigurationProperties(CryptoProperties.class)
public class NovaCryptoAutoConfiguration {
}
