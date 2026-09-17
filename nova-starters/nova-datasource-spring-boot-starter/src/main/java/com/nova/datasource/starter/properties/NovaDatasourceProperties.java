package com.nova.datasource.starter.properties;

import com.nova.datasource.starter.enums.NovaDbType;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * 多数据库方言（prefix = nova.datasource）。
 * <p>
 * 连接配置走 Jeecg 同款 {@code spring.datasource.dynamic}，本类只负责方言。
 */
@Data
@ConfigurationProperties(prefix = "nova.datasource")
public class NovaDatasourceProperties {

    private boolean enabled = true;

    /** 数据库类型：mysql / postgresql / oracle / dameng */
    private NovaDbType dbType = NovaDbType.MYSQL;
}
