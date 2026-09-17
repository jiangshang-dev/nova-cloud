package com.nova.datasource.starter.support;

import com.baomidou.mybatisplus.annotation.DbType;
import com.nova.datasource.starter.enums.NovaDbType;

/**
 * NovaDbType → MyBatis-Plus {@link DbType} 映射（分页插件用）。
 */
public final class MybatisPlusDbTypeMapper {

    private MybatisPlusDbTypeMapper() {
    }

    public static DbType toMybatisPlus(NovaDbType novaDbType) {
        if (novaDbType == null) {
            return DbType.MYSQL;
        }
        return switch (novaDbType) {
            case MYSQL, OCEANBASE, TIDB -> DbType.MYSQL;
            case POSTGRESQL -> DbType.POSTGRE_SQL;
            case ORACLE -> DbType.ORACLE;
            case DAMENG -> DbType.DM;
            case SQLSERVER -> DbType.SQL_SERVER;
            case KINGBASE -> DbType.KINGBASE_ES;
            case GAUSSDB -> DbType.OPENGAUSS;
        };
    }
}
