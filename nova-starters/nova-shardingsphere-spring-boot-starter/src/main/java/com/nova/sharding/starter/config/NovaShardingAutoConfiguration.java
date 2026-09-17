package com.nova.sharding.starter.config;

import com.nova.sharding.starter.properties.NovaShardingProperties;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnClass;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;

import javax.sql.DataSource;
import java.sql.SQLException;

/**
 * ShardingSphere-JDBC 自动配置。
 * <p>
 * 仅当 {@code nova.sharding.enabled=true} 时生效，创建主 DataSource；
 * 未开启时仍走 Spring Boot 默认 {@code spring.datasource}。
 * <p>
 * 主从：{@code nova.sharding.readwrite-splitting.enabled=true} 时追加读写分离规则。
 */
@Slf4j
@AutoConfiguration(before = DataSourceAutoConfiguration.class)
@ConditionalOnClass(name = "org.apache.shardingsphere.driver.api.yaml.YamlShardingSphereDataSourceFactory")
@ConditionalOnProperty(prefix = "nova.sharding", name = "enabled", havingValue = "true")
@EnableConfigurationProperties(NovaShardingProperties.class)
public class NovaShardingAutoConfiguration {

    @Bean
    @Primary
    public DataSource dataSource(NovaShardingProperties properties) throws SQLException, java.io.IOException {
        log.info("启用 Nova ShardingSphere DataSource, readwrite-splitting={}",
                properties.getReadwriteSplitting() != null && properties.getReadwriteSplitting().isEnabled());
        return ShardingYamlDataSourceFactory.create(properties);
    }
}
