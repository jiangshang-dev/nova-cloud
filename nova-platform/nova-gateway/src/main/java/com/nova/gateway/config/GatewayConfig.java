package com.nova.gateway.config;

import com.nova.crypto.properties.CryptoProperties;
import com.nova.gateway.properties.GatewayAuthProperties;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableConfigurationProperties({GatewayAuthProperties.class, CryptoProperties.class})
public class GatewayConfig {
}
