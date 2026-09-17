package com.nova.datasource.starter.properties;

import com.nova.datasource.starter.enums.DatasourceMode;
import com.nova.datasource.starter.enums.NovaDbType;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * 多数据库兼容配置（prefix = nova.datasource）。
 * <pre>
 * nova:
 *   datasource:
 *     db-type: mysql
 *     mode: single
 * </pre>
 */
@Data
@ConfigurationProperties(prefix = "nova.datasource")
public class NovaDatasourceProperties {

    /** 是否启用本 Starter */
    private boolean enabled = true;

    /** 数据库类型：mysql / postgresql / oracle / dameng */
    private NovaDbType dbType = NovaDbType.MYSQL;

    /**
     * 访问模式：single / read-write-splitting / sharding / sharding-read-write。
     * 未显式配置 nova.sharding.enabled 时，会据此推导分片与主从开关。
     */
    private DatasourceMode mode = DatasourceMode.SINGLE;

    /** 未配置 spring.datasource.driver-class-name 时，是否按 db-type 自动填充 */
    private boolean autoDriverClassName = true;

    /** Hikari 默认最大连接数（仅作建议写入，不强制覆盖已有配置） */
    private Integer hikariMaximumPoolSize = 10;

    /** Hikari 默认最小空闲 */
    private Integer hikariMinimumIdle = 2;
}
