package com.nova.datasource.starter.config;

import com.nova.datasource.starter.dialect.DatabaseDialect;
import com.nova.datasource.starter.dialect.DatabaseDialectFactory;
import com.nova.datasource.starter.properties.NovaDatasourceProperties;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;

/**
 * 方言自动配置。数据源由 dynamic-datasource + Druid 接管。
 */
@Slf4j
@AutoConfiguration
@ConditionalOnProperty(prefix = "nova.datasource", name = "enabled", havingValue = "true", matchIfMissing = true)
@EnableConfigurationProperties(NovaDatasourceProperties.class)
public class NovaDatasourceAutoConfiguration {

    @Bean
    @ConditionalOnMissingBean
    public DatabaseDialect databaseDialect(NovaDatasourceProperties properties) {
        DatabaseDialect dialect = DatabaseDialectFactory.create(properties.getDbType());
        log.info("Nova datasource dialect={}, databaseId={}", properties.getDbType(), dialect.databaseId());
        return dialect;
    }
}
