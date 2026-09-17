package com.nova.sharding.starter.config;

import com.nova.sharding.starter.properties.NovaShardingProperties;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnClass;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Conditional;
import org.springframework.context.annotation.Primary;

import javax.sql.DataSource;
import java.sql.SQLException;

/**
 * ShardingSphere-JDBC 自动配置。
 * <p>
 * 启用条件见 {@link OnNovaShardingEnabledCondition}（{@code nova.sharding.enabled}
 * 或 {@code nova.datasource.mode=sharding*}）。
 */
@Slf4j
@AutoConfiguration(before = DataSourceAutoConfiguration.class)
@ConditionalOnClass(name = "org.apache.shardingsphere.driver.api.yaml.YamlShardingSphereDataSourceFactory")
@Conditional(OnNovaShardingEnabledCondition.class)
@EnableConfigurationProperties(NovaShardingProperties.class)
public class NovaShardingAutoConfiguration {

    @Bean
    @Primary
    public DataSource dataSource(NovaShardingProperties properties) throws SQLException, java.io.IOException {
        boolean rw = properties.getReadwriteSplitting() != null && properties.getReadwriteSplitting().isEnabled();
        // mode=sharding-read-write 且未显式配置时，可在业务 yml 打开 readwrite-splitting.enabled
        log.info("启用 Nova ShardingSphere DataSource, readwrite-splitting={}", rw);
        return ShardingYamlDataSourceFactory.create(properties);
    }
}
