package com.nova.datasource.starter.config;

import com.nova.datasource.starter.dialect.DatabaseDialect;
import com.nova.datasource.starter.dialect.DatabaseDialectFactory;
import com.nova.datasource.starter.properties.NovaDatasourceProperties;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnClass;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.autoconfigure.jdbc.DataSourceProperties;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.util.StringUtils;

/**
 * 多数据库兼容自动配置：方言 + Driver 缺省填充。
 * <p>
 * MyBatis {@code DatabaseIdProvider} 由 {@code nova-mybatis-spring-boot-starter} 注册。
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
        log.info("Nova datasource dialect={}, mode={}, databaseId={}",
                properties.getDbType(), properties.getMode(), dialect.databaseId());
        return dialect;
    }

    @Bean
    @ConditionalOnClass(DataSourceProperties.class)
    @ConditionalOnProperty(prefix = "nova.datasource", name = "auto-driver-class-name", havingValue = "true", matchIfMissing = true)
    public static BeanPostProcessor dataSourceDriverClassNamePostProcessor(NovaDatasourceProperties properties) {
        return new BeanPostProcessor() {
            @Override
            public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
                if (bean instanceof DataSourceProperties dsp && !StringUtils.hasText(dsp.getDriverClassName())) {
                    String driver = properties.getDbType().getDriverClassName();
                    dsp.setDriverClassName(driver);
                    log.debug("已按 db-type={} 填充 driver-class-name={}", properties.getDbType(), driver);
                }
                return bean;
            }
        };
    }
}
