package com.nova.datasource.starter.dialect;

import com.nova.datasource.starter.enums.NovaDbType;

/**
 * PostgreSQL 方言。
 */
public class PostgreSqlDialect implements DatabaseDialect {

    @Override
    public NovaDbType dbType() {
        return NovaDbType.POSTGRESQL;
    }

    @Override
    public String currentTime() {
        return "CURRENT_TIMESTAMP";
    }

    @Override
    public String concat(String... columns) {
        return String.join(" || ", columns);
    }

    @Override
    public String pagination(String sql, long offset, long size) {
        return sql + " LIMIT " + size + " OFFSET " + offset;
    }

    @Override
    public String ifNull(String expr, String defaultExpr) {
        return "COALESCE(" + expr + ", " + defaultExpr + ")";
    }
}
