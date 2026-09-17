package com.nova.ai.config;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.Configuration;

@Configuration
@MapperScan("com.nova.ai.core.mapper")
public class AiMybatisConfig {
}
