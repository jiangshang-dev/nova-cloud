package com.nova.file.config;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.Configuration;

@Configuration
@MapperScan("com.nova.file.mapper")
public class FileMybatisConfig {
}
