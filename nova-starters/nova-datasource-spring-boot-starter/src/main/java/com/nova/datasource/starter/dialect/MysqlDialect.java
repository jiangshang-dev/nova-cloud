package com.nova.datasource.starter.dialect;

import com.nova.datasource.starter.enums.NovaDbType;

/**
 * MySQL 方言（OceanBase MySQL 模式 / TiDB 可暂时复用）。
 */
public class MysqlDialect implements DatabaseDialect {

    @Override
    public NovaDbType dbType() {
        return NovaDbType.MYSQL;
    }

    @Override
    public String currentTime() {
        return "NOW()";
    }

    @Override
    public String concat(String... columns) {
        return "CONCAT(" + String.join(", ", columns) + ")";
    }

    @Override
    public String pagination(String sql, long offset, long size) {
        return sql + " LIMIT " + size + " OFFSET " + offset;
    }

    @Override
    public String ifNull(String expr, String defaultExpr) {
        return "IFNULL(" + expr + ", " + defaultExpr + ")";
    }
}
