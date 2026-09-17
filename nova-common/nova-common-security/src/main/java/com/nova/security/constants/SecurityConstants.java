package com.nova.security.constants;

/**
 * 安全常量。
 */
public final class SecurityConstants {

    private SecurityConstants() {
    }

    public static final String AUTHORIZATION_HEADER = "Authorization";
    public static final String BEARER_PREFIX = "Bearer ";
    public static final String USER_ID_HEADER = "X-User-Id";
    public static final String USERNAME_HEADER = "X-Username";
    public static final String TENANT_ID_HEADER = "X-Tenant-Id";
    public static final String AUTHORITIES_HEADER = "X-Authorities";

    /** 服务间内部调用免登 Token 请求头 */
    public static final String INNER_TOKEN_HEADER = "X-Nova-Inner-Token";
    /** 调用来源：inner 表示服务间 Feign 调用 */
    public static final String FROM_SOURCE_HEADER = "X-Nova-From";
    public static final String FROM_INNER = "inner";

    public static final String ROLE_INNER = "ROLE_INNER";
    public static final String INNER_USERNAME = "nova-inner";

    public static final String CLAIM_USER_ID = "userId";
    public static final String CLAIM_USERNAME = "username";
    public static final String CLAIM_TENANT_ID = "tenantId";
    public static final String CLAIM_AUTHORITIES = "authorities";
}
