package com.nova.datasource.starter.enums;

/**
 * 数据源访问模式（与数据库类型正交）。
 * <ul>
 *   <li>{@link #SINGLE} — 普通单库，走 spring.datasource</li>
 *   <li>{@link #READ_WRITE_SPLITTING} — 读写分离</li>
 *   <li>{@link #SHARDING} — 分库分表</li>
 *   <li>{@link #SHARDING_READ_WRITE} — 分片 + 读写分离</li>
 * </ul>
 */
public enum DatasourceMode {

    SINGLE,

    READ_WRITE_SPLITTING,

    SHARDING,

    SHARDING_READ_WRITE;

    public boolean isSharding() {
        return this == SHARDING || this == SHARDING_READ_WRITE;
    }

    public boolean isReadWriteSplitting() {
        return this == READ_WRITE_SPLITTING || this == SHARDING_READ_WRITE;
    }
}
