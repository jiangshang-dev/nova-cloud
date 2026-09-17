package com.nova.crypto.config;

import com.nova.crypto.properties.CryptoProperties;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

@AutoConfiguration
@EnableConfigurationProperties(CryptoProperties.class)
public class NovaCryptoAutoConfiguration {
}
