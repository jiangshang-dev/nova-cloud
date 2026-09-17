package com.nova.ai.starter.config;

import com.nova.ai.model.AiModelFactory;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;

@AutoConfiguration
@EnableConfigurationProperties(NovaAiProperties.class)
public class NovaAiAutoConfiguration {

    @Bean
    public AiModelFactoryMarker aiModelFactoryMarker() {
        // 仅用于标记 starter 已加载；工厂为静态工具类
        return new AiModelFactoryMarker();
    }

    public static final class AiModelFactoryMarker {
        public Class<?> factoryClass() {
            return AiModelFactory.class;
        }
    }
}
