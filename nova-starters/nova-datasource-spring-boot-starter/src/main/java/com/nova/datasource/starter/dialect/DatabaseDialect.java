package com.nova.datasource.starter.dialect;

import com.nova.datasource.starter.enums.NovaDbType;

/**
 * 数据库方言：封装分页、时间、拼接等差异。
 * <p>
 * 业务侧尽量写通用 SQL；差异通过本接口或 MyBatis {@code databaseId} 解决。
 */
public interface DatabaseDialect {

    NovaDbType dbType();

    /** MyBatis databaseId，如 mysql / postgresql / oracle / dameng */
    default String databaseId() {
        return dbType().getDatabaseId();
    }

    /** 当前时间表达式（用于原生 SQL 拼装场景） */
    String currentTime();

    /** 字符串拼接表达式 */
    String concat(String... columns);

    /**
     * 在已有 SELECT SQL 外包一层分页（一般优先用 MyBatis-Plus 分页插件）。
     *
     * @param sql    原始 SQL
     * @param offset 偏移
     * @param size   条数
     */
    String pagination(String sql, long offset, long size);

    /** 空值函数：IFNULL / COALESCE / NVL */
    String ifNull(String expr, String defaultExpr);
}
