package com.nova.system.config;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.Configuration;

@Configuration
@MapperScan("com.nova.system.mapper")
public class SystemMybatisConfig {
}
