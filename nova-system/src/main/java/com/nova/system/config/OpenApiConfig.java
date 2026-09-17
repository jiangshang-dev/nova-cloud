package com.nova.system.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI novaOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("NovaCloud System API")
                        .description("NovaCloud 系统管理服务接口文档")
                        .version("1.0.0")
                        .contact(new Contact().name("NovaCloud").url("https://github.com/nova-cloud")));
    }
}
