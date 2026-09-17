package com.nova.file.starter.config;

import com.nova.file.starter.factory.FileStorageClientFactory;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.context.annotation.Bean;

/**
 * 仅注册存储客户端工厂；实际存储由文件服务管理后台启用后注入 {@code NovaFileService}。
 */
@AutoConfiguration
public class NovaFileAutoConfiguration {

    @Bean
    @ConditionalOnMissingBean
    public FileStorageClientFactory fileStorageClientFactory() {
        return new FileStorageClientFactory();
    }
}
