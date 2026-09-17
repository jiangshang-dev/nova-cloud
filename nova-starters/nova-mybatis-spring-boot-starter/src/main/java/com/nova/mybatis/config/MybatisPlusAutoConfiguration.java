package com.nova.mybatis.config;

import com.baomidou.mybatisplus.annotation.DbType;
import com.baomidou.mybatisplus.extension.plugins.MybatisPlusInterceptor;
import com.baomidou.mybatisplus.extension.plugins.inner.PaginationInnerInterceptor;
import com.nova.datasource.starter.dialect.DatabaseDialect;
import com.nova.datasource.starter.enums.NovaDbType;
import com.nova.datasource.starter.support.MybatisPlusDbTypeMapper;
import org.apache.ibatis.mapping.DatabaseIdProvider;
import org.apache.ibatis.mapping.VendorDatabaseIdProvider;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.boot.autoconfigure.AutoConfiguration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnClass;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.context.annotation.Bean;

import java.util.Properties;

/**
 * MyBatis-Plus 自动配置：分页插件跟随 {@link DatabaseDialect}；注册 DatabaseIdProvider。
 */
@AutoConfiguration
@ConditionalOnClass(MybatisPlusInterceptor.class)
public class MybatisPlusAutoConfiguration {

    @Bean
    @ConditionalOnMissingBean
    public MybatisPlusInterceptor mybatisPlusInterceptor(ObjectProvider<DatabaseDialect> dialectProvider) {
        DbType dbType = dialectProvider
                .stream()
                .findFirst()
                .map(d -> MybatisPlusDbTypeMapper.toMybatisPlus(d.dbType()))
                .orElse(DbType.MYSQL);
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        interceptor.addInnerInterceptor(new PaginationInnerInterceptor(dbType));
        return interceptor;
    }

    @Bean
    @ConditionalOnMissingBean
    public DatabaseIdProvider databaseIdProvider() {
        VendorDatabaseIdProvider provider = new VendorDatabaseIdProvider();
        Properties properties = new Properties();
        for (NovaDbType type : NovaDbType.values()) {
            properties.setProperty(type.getProductName(), type.getDatabaseId());
        }
        properties.setProperty("DM", NovaDbType.DAMENG.getDatabaseId());
        properties.setProperty("Oracle Database", NovaDbType.ORACLE.getDatabaseId());
        provider.setProperties(properties);
        return provider;
    }
}
