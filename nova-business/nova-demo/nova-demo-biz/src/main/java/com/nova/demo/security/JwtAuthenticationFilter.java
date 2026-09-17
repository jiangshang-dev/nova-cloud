package com.nova.demo.security;

import com.nova.security.constants.SecurityConstants;
import com.nova.security.inner.InnerAuthSupport;
import com.nova.security.jwt.JwtTokenProvider;
import com.nova.security.model.LoginUser;
import com.nova.security.properties.InnerAuthProperties;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

/**
 * JWT / 网关透传头鉴权；优先识别服务间内部 Token 免登。
 */
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtTokenProvider jwtTokenProvider;
    private final InnerAuthProperties innerAuthProperties;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        if (InnerAuthSupport.isInnerRequest(request, innerAuthProperties)) {
            List<SimpleGrantedAuthority> authorities = List.of(
                    new SimpleGrantedAuthority(SecurityConstants.ROLE_INNER));
            LoginUser loginUser = LoginUser.builder()
                    .userId(0L)
                    .username(SecurityConstants.INNER_USERNAME)
                    .authorities(List.of(SecurityConstants.ROLE_INNER))
                    .build();
            SecurityContextHolder.getContext().setAuthentication(
                    new UsernamePasswordAuthenticationToken(loginUser, null, authorities));
            filterChain.doFilter(request, response);
            return;
        }

        String userId = request.getHeader(SecurityConstants.USER_ID_HEADER);
        String username = request.getHeader(SecurityConstants.USERNAME_HEADER);
        String authoritiesHeader = request.getHeader(SecurityConstants.AUTHORITIES_HEADER);

        if (StringUtils.hasText(userId) && StringUtils.hasText(username)) {
            List<SimpleGrantedAuthority> authorities = StringUtils.hasText(authoritiesHeader)
                    ? List.of(authoritiesHeader.split(",")).stream().map(SimpleGrantedAuthority::new).toList()
                    : List.of();
            LoginUser loginUser = LoginUser.builder()
                    .userId(Long.valueOf(userId))
                    .username(username)
                    .tenantId(parseLong(request.getHeader(SecurityConstants.TENANT_ID_HEADER)))
                    .authorities(authorities.stream().map(SimpleGrantedAuthority::getAuthority).toList())
                    .build();
            SecurityContextHolder.getContext().setAuthentication(
                    new UsernamePasswordAuthenticationToken(loginUser, null, authorities));
        } else {
            String authorization = request.getHeader(HttpHeaders.AUTHORIZATION);
            if (StringUtils.hasText(authorization) && authorization.startsWith(SecurityConstants.BEARER_PREFIX)) {
                String token = authorization.substring(SecurityConstants.BEARER_PREFIX.length());
                if (jwtTokenProvider.validate(token)) {
                    LoginUser loginUser = jwtTokenProvider.parseToken(token);
                    List<SimpleGrantedAuthority> authorities = loginUser.getAuthorities() == null
                            ? List.of()
                            : loginUser.getAuthorities().stream().map(SimpleGrantedAuthority::new).toList();
                    SecurityContextHolder.getContext().setAuthentication(
                            new UsernamePasswordAuthenticationToken(loginUser, null, authorities));
                }
            }
        }
        filterChain.doFilter(request, response);
    }

    private static Long parseLong(String value) {
        if (!StringUtils.hasText(value) || "null".equals(value)) {
            return null;
        }
        return Long.valueOf(value);
    }
}
