package com.nova.sharding.starter.config;

import com.nova.datasource.starter.enums.DatasourceMode;
import org.springframework.boot.autoconfigure.condition.ConditionMessage;
import org.springframework.boot.autoconfigure.condition.ConditionOutcome;
import org.springframework.boot.autoconfigure.condition.SpringBootCondition;
import org.springframework.context.annotation.ConditionContext;
import org.springframework.core.env.Environment;
import org.springframework.core.type.AnnotatedTypeMetadata;

import java.util.Locale;

/**
 * 分片启用条件：{@code nova.sharding.enabled=true}，
 * 或未显式关闭且 {@code nova.datasource.mode} 为 sharding / sharding-read-write。
 */
public class OnNovaShardingEnabledCondition extends SpringBootCondition {

    @Override
    public ConditionOutcome getMatchOutcome(ConditionContext context, AnnotatedTypeMetadata metadata) {
        Environment env = context.getEnvironment();
        ConditionMessage.Builder message = ConditionMessage.forCondition("Nova Sharding");

        String enabled = env.getProperty("nova.sharding.enabled");
        if ("true".equalsIgnoreCase(enabled)) {
            return ConditionOutcome.match(message.found("nova.sharding.enabled").items("true"));
        }
        if ("false".equalsIgnoreCase(enabled)) {
            return ConditionOutcome.noMatch(message.found("nova.sharding.enabled").items("false"));
        }

        DatasourceMode mode = parseMode(env.getProperty("nova.datasource.mode", "single"));
        if (mode.isSharding()) {
            return ConditionOutcome.match(message.found("nova.datasource.mode").items(mode.name()));
        }
        return ConditionOutcome.noMatch(message.didNotFind("sharding mode").atAll());
    }

    private static DatasourceMode parseMode(String raw) {
        String v = raw.trim().toUpperCase(Locale.ROOT).replace('-', '_');
        try {
            return DatasourceMode.valueOf(v);
        } catch (IllegalArgumentException ex) {
            return DatasourceMode.SINGLE;
        }
    }
}
