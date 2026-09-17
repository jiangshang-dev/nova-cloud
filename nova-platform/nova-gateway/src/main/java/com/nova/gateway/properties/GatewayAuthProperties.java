package com.nova.gateway.properties;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

import java.util.ArrayList;
import java.util.List;

@Data
@ConfigurationProperties(prefix = "nova.gateway.auth")
public class GatewayAuthProperties {

    /**
     * 是否开启 Token 鉴权。
     */
    private boolean enabled = true;

    /**
     * 白名单路径（Ant 风格）。
     */
    private List<String> whiteList = new ArrayList<>(List.of(
            "/auth/**",
            "/oauth2/**",
            "/.well-known/**",
            "/actuator/**",
            "/v3/api-docs/**",
            "/swagger-ui/**",
            "/swagger-ui.html",
            "/doc.html"
    ));
}
