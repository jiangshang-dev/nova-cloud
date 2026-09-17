package com.nova.demo.config;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.Configuration;

@Configuration
@MapperScan("com.nova.demo.mapper")
public class DemoMybatisConfig {
}
