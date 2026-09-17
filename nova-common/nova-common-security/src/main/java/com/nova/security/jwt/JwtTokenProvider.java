package com.nova.security.jwt;

import com.nova.security.constants.SecurityConstants;
import com.nova.security.model.LoginUser;
import com.nova.security.properties.JwtProperties;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import lombok.RequiredArgsConstructor;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.util.Collections;
import java.util.Date;
import java.util.List;

/**
 * JWT 签发与解析。
 */
@RequiredArgsConstructor
public class JwtTokenProvider {

    private final JwtProperties properties;

    public String createToken(LoginUser user) {
        Instant now = Instant.now();
        Instant expireAt = now.plusSeconds(properties.getExpireSeconds());
        return Jwts.builder()
                .issuer(properties.getIssuer())
                .subject(user.getUsername())
                .issuedAt(Date.from(now))
                .expiration(Date.from(expireAt))
                .claim(SecurityConstants.CLAIM_USER_ID, user.getUserId())
                .claim(SecurityConstants.CLAIM_USERNAME, user.getUsername())
                .claim(SecurityConstants.CLAIM_TENANT_ID, user.getTenantId())
                .claim(SecurityConstants.CLAIM_AUTHORITIES, user.getAuthorities())
                .signWith(secretKey())
                .compact();
    }

    public LoginUser parseToken(String token) {
        Claims claims = Jwts.parser()
                .verifyWith(secretKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();

        Object authoritiesObj = claims.get(SecurityConstants.CLAIM_AUTHORITIES);
        List<String> authorities = authoritiesObj instanceof List<?> list
                ? list.stream().map(String::valueOf).toList()
                : Collections.emptyList();

        return LoginUser.builder()
                .userId(asLong(claims.get(SecurityConstants.CLAIM_USER_ID)))
                .tenantId(asLong(claims.get(SecurityConstants.CLAIM_TENANT_ID)))
                .username(String.valueOf(claims.get(SecurityConstants.CLAIM_USERNAME)))
                .authorities(authorities)
                .build();
    }

    public boolean validate(String token) {
        try {
            parseToken(token);
            return true;
        } catch (Exception ex) {
            return false;
        }
    }

    private SecretKey secretKey() {
        byte[] keyBytes = properties.getSecret().getBytes(StandardCharsets.UTF_8);
        return Keys.hmacShaKeyFor(keyBytes.length >= 32 ? keyBytes : pad(keyBytes));
    }

    private static byte[] pad(byte[] src) {
        byte[] fixed = new byte[32];
        System.arraycopy(src, 0, fixed, 0, Math.min(src.length, 32));
        return fixed;
    }

    private static Long asLong(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Number number) {
            return number.longValue();
        }
        return Long.parseLong(String.valueOf(value));
    }
}
