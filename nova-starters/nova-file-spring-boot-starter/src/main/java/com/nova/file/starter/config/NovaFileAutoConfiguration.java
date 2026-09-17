package com.nova.file.starter.config;

import com.nova.file.starter.factory.FileStorageClientFactory;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.context.annotation.Bean;

@AutoConfiguration
public class NovaFileAutoConfiguration {

    @Bean
    @ConditionalOnMissingBean
    public FileStorageClientFactory fileStorageClientFactory() {
        return new FileStorageClientFactory();
    }
}
