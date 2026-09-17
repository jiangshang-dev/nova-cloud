package com.nova.datasource.starter.dialect;

import com.nova.datasource.starter.enums.NovaDbType;

/**
 * Oracle 方言。
 */
public class OracleDialect implements DatabaseDialect {

    @Override
    public NovaDbType dbType() {
        return NovaDbType.ORACLE;
    }

    @Override
    public String currentTime() {
        return "SYSTIMESTAMP";
    }

    @Override
    public String concat(String... columns) {
        return String.join(" || ", columns);
    }

    @Override
    public String pagination(String sql, long offset, long size) {
        long end = offset + size;
        return "SELECT * FROM (SELECT TMP_PAGE.*, ROWNUM RN FROM (" + sql
                + ") TMP_PAGE WHERE ROWNUM <= " + end + ") WHERE RN > " + offset;
    }

    @Override
    public String ifNull(String expr, String defaultExpr) {
        return "NVL(" + expr + ", " + defaultExpr + ")";
    }
}
