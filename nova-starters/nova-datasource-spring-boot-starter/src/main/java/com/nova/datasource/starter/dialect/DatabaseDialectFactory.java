package com.nova.datasource.starter.dialect;

import com.nova.datasource.starter.enums.NovaDbType;

/**
 * 按 {@link NovaDbType} 创建方言。未实现类型会抛出明确异常（预留库种）。
 */
public final class DatabaseDialectFactory {

    private DatabaseDialectFactory() {
    }

    public static DatabaseDialect create(NovaDbType dbType) {
        if (dbType == null) {
            return new MysqlDialect();
        }
        return switch (dbType) {
            case MYSQL, OCEANBASE, TIDB -> new MysqlDialect();
            case POSTGRESQL -> new PostgreSqlDialect();
            case ORACLE -> new OracleDialect();
            case DAMENG -> new DamengDialect();
            case SQLSERVER, KINGBASE, GAUSSDB -> throw new UnsupportedOperationException(
                    "数据库类型 " + dbType + " 尚未实现方言，请在 NovaDbType / DatabaseDialect 中扩展（见 docs/1.md TODO）");
        };
    }
}
