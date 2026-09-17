package com.nova.gateway.filter;

import com.nova.gateway.properties.GatewayAuthProperties;
import com.nova.security.constants.SecurityConstants;
import com.nova.security.jwt.JwtTokenProvider;
import com.nova.security.model.LoginUser;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.core.io.buffer.DataBuffer;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.stereotype.Component;
import org.springframework.util.AntPathMatcher;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

import java.nio.charset.StandardCharsets;

/**
 * 网关 Token 鉴权，并将用户信息写入下游请求头。
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class AuthGlobalFilter implements GlobalFilter, Ordered {

    private final GatewayAuthProperties authProperties;
    private final JwtTokenProvider jwtTokenProvider;
    private final AntPathMatcher pathMatcher = new AntPathMatcher();

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        if (!authProperties.isEnabled()) {
            return chain.filter(exchange);
        }
        String path = exchange.getRequest().getURI().getPath();
        if (isWhite(path)) {
            return chain.filter(exchange);
        }

        String authorization = exchange.getRequest().getHeaders().getFirst(HttpHeaders.AUTHORIZATION);
        if (authorization == null || !authorization.startsWith(SecurityConstants.BEARER_PREFIX)) {
            return unauthorized(exchange, "缺少访问令牌");
        }
        String token = authorization.substring(SecurityConstants.BEARER_PREFIX.length());
        try {
            LoginUser loginUser = jwtTokenProvider.parseToken(token);
            ServerHttpRequest mutated = exchange.getRequest().mutate()
                    .header(SecurityConstants.USER_ID_HEADER, String.valueOf(loginUser.getUserId()))
                    .header(SecurityConstants.USERNAME_HEADER, loginUser.getUsername())
                    .header(SecurityConstants.TENANT_ID_HEADER, String.valueOf(loginUser.getTenantId()))
                    .header(SecurityConstants.AUTHORITIES_HEADER,
                            loginUser.getAuthorities() == null ? "" : String.join(",", loginUser.getAuthorities()))
                    .build();
            return chain.filter(exchange.mutate().request(mutated).build());
        } catch (Exception ex) {
            log.warn("Token 校验失败: {}", ex.getMessage());
            return unauthorized(exchange, "访问令牌无效或已过期");
        }
    }

    private boolean isWhite(String path) {
        return authProperties.getWhiteList().stream().anyMatch(pattern -> pathMatcher.match(pattern, path));
    }

    private Mono<Void> unauthorized(ServerWebExchange exchange, String message) {
        exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
        exchange.getResponse().getHeaders().setContentType(MediaType.APPLICATION_JSON);
        byte[] bytes = ("{\"code\":401,\"message\":\"" + message + "\",\"data\":null}").getBytes(StandardCharsets.UTF_8);
        DataBuffer buffer = exchange.getResponse().bufferFactory().wrap(bytes);
        return exchange.getResponse().writeWith(Mono.just(buffer));
    }

    @Override
    public int getOrder() {
        return -100;
    }
}
