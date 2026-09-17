package com.nova.datasource.starter.enums;

import lombok.Getter;
import lombok.RequiredArgsConstructor;

/**
 * Nova 支持的数据库类型。
 * <p>
 * 已实现：MySQL / PostgreSQL / Oracle / Dameng。<br>
 * 预留（TODO）：SQL Server、人大金仓、OceanBase、TiDB、GaussDB。
 */
@Getter
@RequiredArgsConstructor
public enum NovaDbType {

    MYSQL("mysql", "com.mysql.cj.jdbc.Driver", "MySQL"),

    POSTGRESQL("postgresql", "org.postgresql.Driver", "PostgreSQL"),

    ORACLE("oracle", "oracle.jdbc.OracleDriver", "Oracle"),

    DAMENG("dameng", "dm.jdbc.driver.DmDriver", "DM DBMS"),

    // ---------- 以下预留扩展，暂未实现方言 ----------
    /** TODO: SQL Server */
    SQLSERVER("sqlserver", "com.microsoft.sqlserver.jdbc.SQLServerDriver", "Microsoft SQL Server"),

    /** TODO: 人大金仓 KingbaseES */
    KINGBASE("kingbase", "com.kingbase8.Driver", "KingbaseES"),

    /** TODO: OceanBase（MySQL 模式可先复用 MYSQL） */
    OCEANBASE("oceanbase", "com.mysql.cj.jdbc.Driver", "OceanBase"),

    /** TODO: TiDB（兼容 MySQL 协议，可先复用 MYSQL） */
    TIDB("tidb", "com.mysql.cj.jdbc.Driver", "TiDB"),

    /** TODO: GaussDB / openGauss */
    GAUSSDB("gaussdb", "org.opengauss.Driver", "GaussDB");

    /** MyBatis databaseId */
    private final String databaseId;

    private final String driverClassName;

    /** JDBC DatabaseMetaData#getDatabaseProductName 匹配关键字（VendorDatabaseIdProvider） */
    private final String productName;
}
