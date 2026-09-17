package com.nova.core.config;

import com.nova.core.debounce.DebounceAspect;
import com.nova.core.debounce.DebounceCacheDefaultConfig;
import com.nova.core.properties.MailProperties;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Import;

/**
 * nova-common-core 自动装配（含防抖切面与默认内存缓存）。
 */
@AutoConfiguration
@EnableConfigurationProperties(MailProperties.class)
@Import({ApiDocPrinter.class, DebounceCacheDefaultConfig.class, DebounceAspect.class})
public class NovaCoreAutoConfiguration {
}
