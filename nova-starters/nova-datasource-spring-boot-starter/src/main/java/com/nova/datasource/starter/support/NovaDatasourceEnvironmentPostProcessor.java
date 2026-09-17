package com.nova.datasource.starter.support;

import com.nova.datasource.starter.enums.DatasourceMode;
import com.nova.datasource.starter.enums.NovaDbType;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.env.EnvironmentPostProcessor;
import org.springframework.core.Ordered;
import org.springframework.core.env.ConfigurableEnvironment;
import org.springframework.core.env.MapPropertySource;
import org.springframework.util.StringUtils;

import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

/**
 * 早期环境增强：在能读到配置时同步 mode→sharding 开关，并尽量填充 driver。
 * <p>
 * 分片是否启用以 AutoConfig 条件为准（见 OnNovaShardingEnabledCondition），
 * 此处写入便于其它组件直接读取 {@code nova.sharding.*}。
 */
public class NovaDatasourceEnvironmentPostProcessor implements EnvironmentPostProcessor, Ordered {

    public static final String PROPERTY_SOURCE_NAME = "novaDatasourceDefaults";

    @Override
    public void postProcessEnvironment(ConfigurableEnvironment environment, SpringApplication application) {
        Map<String, Object> map = new HashMap<>(8);

        String modeRaw = environment.getProperty("nova.datasource.mode");
        if (StringUtils.hasText(modeRaw)) {
            DatasourceMode mode = parseMode(modeRaw);
            if (!environment.containsProperty("nova.sharding.enabled")) {
                map.put("nova.sharding.enabled", String.valueOf(mode.isSharding()));
            }
            if (!environment.containsProperty("nova.sharding.readwrite-splitting.enabled")) {
                map.put("nova.sharding.readwrite-splitting.enabled", String.valueOf(mode.isReadWriteSplitting()));
            }
        }

        boolean autoDriver = environment.getProperty("nova.datasource.auto-driver-class-name", Boolean.class, true);
        if (autoDriver && !StringUtils.hasText(environment.getProperty("spring.datasource.driver-class-name"))) {
            String dbTypeRaw = environment.getProperty("nova.datasource.db-type");
            if (StringUtils.hasText(dbTypeRaw)) {
                NovaDbType dbType = parseDbType(dbTypeRaw);
                map.put("spring.datasource.driver-class-name", dbType.getDriverClassName());
            }
        }

        if (!map.isEmpty()) {
            environment.getPropertySources().addFirst(new MapPropertySource(PROPERTY_SOURCE_NAME, map));
        }
    }

    private static DatasourceMode parseMode(String raw) {
        String v = raw.trim().toUpperCase(Locale.ROOT).replace('-', '_');
        try {
            return DatasourceMode.valueOf(v);
        } catch (IllegalArgumentException ex) {
            return DatasourceMode.SINGLE;
        }
    }

    private static NovaDbType parseDbType(String raw) {
        String v = raw.trim().toUpperCase(Locale.ROOT).replace('-', '_');
        try {
            return NovaDbType.valueOf(v);
        } catch (IllegalArgumentException ex) {
            return NovaDbType.MYSQL;
        }
    }

    @Override
    public int getOrder() {
        return Ordered.LOWEST_PRECEDENCE;
    }
}
