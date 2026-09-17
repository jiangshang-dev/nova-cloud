package com.nova.auth.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nova.auth.domain.entity.SysUser;
import com.nova.auth.mapper.SysUserMapper;
import com.nova.core.exception.ServiceException;
import com.nova.security.jwt.JwtTokenProvider;
import com.nova.security.model.LoginUser;
import com.nova.security.properties.JwtProperties;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AuthLoginService {

    private final SysUserMapper sysUserMapper;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final JwtProperties jwtProperties;
    private final EmailCodeService emailCodeService;

    public Map<String, Object> loginByPassword(String username, String password) {
        SysUser user = sysUserMapper.selectOne(new LambdaQueryWrapper<SysUser>()
                .eq(SysUser::getUsername, username)
                .last("limit 1"));
        if (user == null) {
            throw new ServiceException("用户名或密码错误");
        }
        if (user.getStatus() != null && user.getStatus() == 0) {
            throw new ServiceException("账号已停用");
        }
        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new ServiceException("用户名或密码错误");
        }
        return buildTokenResponse(user);
    }

    public Map<String, Object> loginByEmail(String email, String code) {
        emailCodeService.validateCode(email, "login", code);
        SysUser user = sysUserMapper.selectOne(new LambdaQueryWrapper<SysUser>()
                .eq(SysUser::getEmail, email)
                .last("limit 1"));
        if (user == null) {
            throw new ServiceException("邮箱未绑定账号");
        }
        if (user.getStatus() != null && user.getStatus() == 0) {
            throw new ServiceException("账号已停用");
        }
        return buildTokenResponse(user);
    }

    public Map<String, Object> currentUserInfo(String token) {
        if (!StringUtils.hasText(token)) {
            throw new ServiceException("未登录或令牌无效");
        }
        LoginUser loginUser;
        try {
            loginUser = jwtTokenProvider.parseToken(token);
        } catch (Exception ex) {
            throw new ServiceException("未登录或令牌无效");
        }
        SysUser user = sysUserMapper.selectById(loginUser.getUserId());
        if (user == null) {
            throw new ServiceException("用户不存在");
        }
        Map<String, Object> result = new HashMap<>(4);
        result.put("userInfo", buildFrontendUserInfo(user, loginUser.getAuthorities()));
        result.put("sysAllDictItems", Map.of());
        return result;
    }

    private Map<String, Object> buildTokenResponse(SysUser user) {
        List<String> permissions = sysUserMapper.selectPermissionsByUserId(user.getId());
        LoginUser loginUser = LoginUser.builder()
                .userId(user.getId())
                .tenantId(user.getTenantId())
                .username(user.getUsername())
                .authorities(permissions)
                .build();
        String accessToken = jwtTokenProvider.createToken(loginUser);
        Map<String, Object> userInfo = buildFrontendUserInfo(user, permissions);

        Map<String, Object> result = new LinkedHashMap<>(12);
        // 前端 Jeecg 风格字段
        result.put("token", accessToken);
        result.put("userInfo", userInfo);
        // OAuth2 / 标准字段
        result.put("access_token", accessToken);
        result.put("token_type", "Bearer");
        result.put("expires_in", jwtProperties.getExpireSeconds());
        result.put("user_id", user.getId());
        result.put("username", user.getUsername());
        result.put("tenant_id", user.getTenantId());
        result.put("authorities", permissions);
        return result;
    }

    private Map<String, Object> buildFrontendUserInfo(SysUser user, List<String> permissions) {
        Map<String, Object> userInfo = new LinkedHashMap<>(12);
        userInfo.put("id", user.getId());
        userInfo.put("userId", user.getId());
        userInfo.put("username", user.getUsername());
        userInfo.put("realname", StringUtils.hasText(user.getRealName()) ? user.getRealName() : user.getNickname());
        userInfo.put("avatar", user.getAvatar() == null ? "" : user.getAvatar());
        userInfo.put("loginTenantId", user.getTenantId());
        userInfo.put("tenantid", user.getTenantId());
        userInfo.put("roles", permissions == null ? List.of() : permissions.stream()
                .map(code -> Map.of("roleName", code, "value", code))
                .toList());
        return userInfo;
    }
}
