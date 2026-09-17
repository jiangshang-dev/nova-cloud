package com.nova.sharding.starter.config;

import com.nova.sharding.starter.properties.NovaShardingProperties;
import com.nova.sharding.starter.properties.NovaShardingProperties.AlgorithmItem;
import com.nova.sharding.starter.properties.NovaShardingProperties.DataSourceItem;
import com.nova.sharding.starter.properties.NovaShardingProperties.KeyGenerateStrategy;
import com.nova.sharding.starter.properties.NovaShardingProperties.ReadWriteSplitting;
import com.nova.sharding.starter.properties.NovaShardingProperties.StandardStrategy;
import com.nova.sharding.starter.properties.NovaShardingProperties.TableRule;
import lombok.extern.slf4j.Slf4j;
import org.apache.shardingsphere.driver.api.yaml.YamlShardingSphereDataSourceFactory;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import javax.sql.DataSource;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.Map;

/**
 * 根据 {@link NovaShardingProperties} 生成 ShardingSphere YAML 并创建 DataSource。
 */
@Slf4j
public final class ShardingYamlDataSourceFactory {

    private ShardingYamlDataSourceFactory() {
    }

    public static DataSource create(NovaShardingProperties props) throws SQLException, java.io.IOException {
        String yaml = buildYaml(props);
        log.info("Nova ShardingSphere YAML:\n{}", yaml);
        return YamlShardingSphereDataSourceFactory.createDataSource(yaml.getBytes(StandardCharsets.UTF_8));
    }

    static String buildYaml(NovaShardingProperties props) {
        if (CollectionUtils.isEmpty(props.getDatasources())) {
            throw new IllegalStateException("nova.sharding.datasources 不能为空");
        }

        StringBuilder sb = new StringBuilder(2048);
        sb.append("dataSources:\n");
        for (Map.Entry<String, DataSourceItem> e : props.getDatasources().entrySet()) {
            DataSourceItem ds = e.getValue();
            if (!StringUtils.hasText(ds.getJdbcUrl())) {
                throw new IllegalStateException("数据源 " + e.getKey() + " 缺少 jdbc-url");
            }
            sb.append("  ").append(e.getKey()).append(":\n");
            sb.append("    dataSourceClassName: com.zaxxer.hikari.HikariDataSource\n");
            sb.append("    driverClassName: ").append(ds.getDriverClassName()).append('\n');
            sb.append("    jdbcUrl: ").append(ds.getJdbcUrl()).append('\n');
            sb.append("    username: ").append(nullToEmpty(ds.getUsername())).append('\n');
            sb.append("    password: ").append(nullToEmpty(ds.getPassword())).append('\n');
            if (ds.getMaximumPoolSize() != null) {
                sb.append("    maximumPoolSize: ").append(ds.getMaximumPoolSize()).append('\n');
            }
            if (ds.getMinimumIdle() != null) {
                sb.append("    minimumIdle: ").append(ds.getMinimumIdle()).append('\n');
            }
        }

        sb.append("rules:\n");
        boolean hasSharding = !CollectionUtils.isEmpty(props.getTables());
        ReadWriteSplitting rw = props.getReadwriteSplitting();
        boolean rwEnabled = rw != null && rw.isEnabled();

        if (!hasSharding && !rwEnabled) {
            throw new IllegalStateException(
                    "nova.sharding 已启用，但未配置 tables 且未开启 readwrite-splitting，请至少配置一项");
        }
        // 主从逻辑库需先于分片规则声明，便于 actual-data-nodes 引用 readwrite_ds
        if (rwEnabled) {
            appendReadWriteRule(sb, rw);
        }
        if (hasSharding) {
            appendShardingRule(sb, props);
        }

        sb.append("props:\n");
        sb.append("  sql-show: ").append(props.isSqlShow()).append('\n');
        return sb.toString();
    }

    private static void appendShardingRule(StringBuilder sb, NovaShardingProperties props) {
        sb.append("- !SHARDING\n");
        sb.append("  tables:\n");
        for (Map.Entry<String, TableRule> e : props.getTables().entrySet()) {
            TableRule table = e.getValue();
            sb.append("    ").append(e.getKey()).append(":\n");
            sb.append("      actualDataNodes: ").append(table.getActualDataNodes()).append('\n');
            appendStrategy(sb, "tableStrategy", table.getTableStrategy());
            appendStrategy(sb, "databaseStrategy", table.getDatabaseStrategy());
            KeyGenerateStrategy key = table.getKeyGenerateStrategy();
            if (key != null && StringUtils.hasText(key.getColumn())) {
                sb.append("      keyGenerateStrategy:\n");
                sb.append("        column: ").append(key.getColumn()).append('\n');
                sb.append("        keyGeneratorName: ").append(key.getKeyGeneratorName()).append('\n');
            }
        }
        if (!CollectionUtils.isEmpty(props.getBindingTables())) {
            sb.append("  bindingTables:\n");
            for (String bt : props.getBindingTables()) {
                sb.append("    - ").append(bt).append('\n');
            }
        }
        if (!CollectionUtils.isEmpty(props.getBroadcastTables())) {
            sb.append("  broadcastTables:\n");
            for (String bt : props.getBroadcastTables()) {
                sb.append("    - ").append(bt).append('\n');
            }
        }
        if (!CollectionUtils.isEmpty(props.getShardingAlgorithms())) {
            sb.append("  shardingAlgorithms:\n");
            appendAlgorithms(sb, props.getShardingAlgorithms());
        }
        if (!CollectionUtils.isEmpty(props.getKeyGenerators())) {
            sb.append("  keyGenerators:\n");
            appendAlgorithms(sb, props.getKeyGenerators());
        }
    }

    private static void appendStrategy(StringBuilder sb, String name, StandardStrategy strategy) {
        if (strategy == null || !StringUtils.hasText(strategy.getShardingColumn())) {
            return;
        }
        sb.append("      ").append(name).append(":\n");
        sb.append("        standard:\n");
        sb.append("          shardingColumn: ").append(strategy.getShardingColumn()).append('\n');
        sb.append("          shardingAlgorithmName: ").append(strategy.getShardingAlgorithmName()).append('\n');
    }

    private static void appendAlgorithms(StringBuilder sb, Map<String, AlgorithmItem> algorithms) {
        for (Map.Entry<String, AlgorithmItem> e : algorithms.entrySet()) {
            AlgorithmItem alg = e.getValue();
            sb.append("    ").append(e.getKey()).append(":\n");
            sb.append("      type: ").append(alg.getType()).append('\n');
            if (!CollectionUtils.isEmpty(alg.getProps())) {
                sb.append("      props:\n");
                for (Map.Entry<String, String> p : alg.getProps().entrySet()) {
                    sb.append("        ").append(p.getKey()).append(": ").append(p.getValue()).append('\n');
                }
            }
        }
    }

    private static void appendReadWriteRule(StringBuilder sb, ReadWriteSplitting rw) {
        if (!StringUtils.hasText(rw.getWriteDataSourceName())
                || CollectionUtils.isEmpty(rw.getReadDataSourceNames())) {
            throw new IllegalStateException(
                    "开启读写分离时必须配置 write-data-source-name 与 read-data-source-names");
        }
        sb.append("- !READWRITE_SPLITTING\n");
        sb.append("  dataSources:\n");
        sb.append("    ").append(rw.getName()).append(":\n");
        sb.append("      writeDataSourceName: ").append(rw.getWriteDataSourceName()).append('\n');
        sb.append("      readDataSourceNames:\n");
        for (String read : rw.getReadDataSourceNames()) {
            sb.append("        - ").append(read).append('\n');
        }
        sb.append("      loadBalancerName: ").append(rw.getLoadBalancerName()).append('\n');
        sb.append("  loadBalancers:\n");
        sb.append("    ").append(rw.getLoadBalancerName()).append(":\n");
        sb.append("      type: ").append(rw.getLoadBalancerType()).append('\n');
    }

    private static String nullToEmpty(String v) {
        return v == null ? "" : v;
    }
}
