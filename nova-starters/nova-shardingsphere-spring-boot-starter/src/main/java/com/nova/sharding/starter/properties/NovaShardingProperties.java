package com.nova.sharding.starter.properties;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * ShardingSphere 配置（prefix = nova.sharding）。
 * <p>
 * {@code enabled=false} 时不接管 DataSource，继续使用 {@code spring.datasource}。<br>
 * {@code readwrite-splitting.enabled} 控制是否启用主从读写分离（可关）。
 */
@Data
@ConfigurationProperties(prefix = "nova.sharding")
public class NovaShardingProperties {

    /** 总开关：true 时由本 Starter 创建 ShardingSphere DataSource */
    private boolean enabled = false;

    /** 是否打印改写后的 SQL */
    private boolean sqlShow = true;

    /** 物理数据源（Hikari），key 为逻辑名，如 ds0 / ds0_slave */
    private Map<String, DataSourceItem> datasources = new LinkedHashMap<>();

    /** 读写分离（主从），可关闭 */
    private ReadWriteSplitting readwriteSplitting = new ReadWriteSplitting();

    /** 分片表规则 */
    private Map<String, TableRule> tables = new LinkedHashMap<>();

    /** 分片算法 */
    private Map<String, AlgorithmItem> shardingAlgorithms = new LinkedHashMap<>();

    /** 分布式主键生成器 */
    private Map<String, AlgorithmItem> keyGenerators = new LinkedHashMap<>();

    /** 绑定表组（可选） */
    private List<String> bindingTables = new ArrayList<>();

    /** 广播表（可选） */
    private List<String> broadcastTables = new ArrayList<>();

    @Data
    public static class DataSourceItem {
        private String driverClassName = "com.mysql.cj.jdbc.Driver";
        private String jdbcUrl;
        private String username;
        private String password;
        private Integer maximumPoolSize = 10;
        private Integer minimumIdle = 2;
    }

    @Data
    public static class ReadWriteSplitting {
        /** 主从开关：false 时不做读写分离，直接使用分片数据源名 */
        private boolean enabled = false;
        /** 读写分离逻辑数据源名，分片 actual-data-nodes 可引用此名 */
        private String name = "readwrite_ds";
        private String writeDataSourceName;
        private List<String> readDataSourceNames = new ArrayList<>();
        private String loadBalancerName = "round_robin";
        private String loadBalancerType = "ROUND_ROBIN";
    }

    @Data
    public static class TableRule {
        /** 如 ds0.demo_order_$->{0..1} 或 readwrite_ds.demo_order_$->{0..1} */
        private String actualDataNodes;
        private StandardStrategy tableStrategy;
        private StandardStrategy databaseStrategy;
        private KeyGenerateStrategy keyGenerateStrategy;
    }

    @Data
    public static class StandardStrategy {
        private String shardingColumn;
        private String shardingAlgorithmName;
    }

    @Data
    public static class KeyGenerateStrategy {
        private String column;
        private String keyGeneratorName;
    }

    @Data
    public static class AlgorithmItem {
        private String type;
        private Map<String, String> props = new LinkedHashMap<>();
    }
}
