package com.nova.core.config;

import com.nova.core.properties.MailProperties;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Import;

/**
 * nova-common-core 自动装配。
 */
@AutoConfiguration
@EnableConfigurationProperties(MailProperties.class)
@Import(ApiDocPrinter.class)
public class NovaCoreAutoConfiguration {
}
