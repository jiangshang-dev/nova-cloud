package com.nova.core.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnClass;
import org.springframework.boot.autoconfigure.condition.ConditionalOnWebApplication;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

/**
 * 启动完成后在控制台打印可点击的 API 文档地址。
 */
@Slf4j
@Component
@ConditionalOnWebApplication(type = ConditionalOnWebApplication.Type.SERVLET)
@ConditionalOnClass(name = "org.springdoc.core.properties.SpringDocConfigProperties")
public class ApiDocPrinter implements ApplicationRunner {

    private final Environment environment;

    @Value("${server.port:8080}")
    private String port;

    @Value("${server.servlet.context-path:}")
    private String contextPath;

    @Value("${springdoc.swagger-ui.path:/swagger-ui.html}")
    private String swaggerUiPath;

    @Value("${springdoc.api-docs.path:/v3/api-docs}")
    private String apiDocsPath;

    public ApiDocPrinter(Environment environment) {
        this.environment = environment;
    }

    @Override
    public void run(ApplicationArguments args) {
        String host = resolveHost();
        String basePath = normalizeContextPath(contextPath);
        String swaggerPath = normalizePath(swaggerUiPath);
        String docsPath = normalizePath(apiDocsPath);

        String swaggerUrl = "http://" + host + ":" + port + basePath + swaggerPath;
        String openApiUrl = "http://" + host + ":" + port + basePath + docsPath;

        log.info("""
                
                ----------------------------------------------------------
                	NovaCloud 服务启动成功
                	API 文档:   {}
                	OpenAPI:   {}
                	(IDEA 控制台可直接点击上方链接打开)
                ----------------------------------------------------------
                """, swaggerUrl, openApiUrl);
    }

    private String resolveHost() {
        String address = environment.getProperty("server.address");
        if (StringUtils.hasText(address) && !"0.0.0.0".equals(address)) {
            return address;
        }
        return "127.0.0.1";
    }

    private static String normalizeContextPath(String path) {
        if (!StringUtils.hasText(path) || "/".equals(path)) {
            return "";
        }
        return path.startsWith("/") ? path : "/" + path;
    }

    private static String normalizePath(String path) {
        if (!StringUtils.hasText(path)) {
            return "";
        }
        return path.startsWith("/") ? path : "/" + path;
    }
}
