package com.nova.auth.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nova.auth.domain.entity.SysLoginLog;
import com.nova.auth.domain.entity.SysUser;
import com.nova.auth.mapper.SysLoginLogMapper;
import com.nova.auth.mapper.SysUserMapper;
import com.nova.core.exception.ServiceException;
import com.nova.core.utils.IdGeneratorUtil;
import com.nova.security.jwt.JwtTokenProvider;
import com.nova.security.model.LoginUser;
import com.nova.security.properties.JwtProperties;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AuthLoginService {

    private final SysUserMapper sysUserMapper;
    private final SysLoginLogMapper sysLoginLogMapper;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final JwtProperties jwtProperties;
    private final EmailCodeService emailCodeService;

    public Map<String, Object> loginByPassword(String username, String password) {
        SysUser user = sysUserMapper.selectOne(new LambdaQueryWrapper<SysUser>()
                .eq(SysUser::getUsername, username)
                .last("limit 1"));
        if (user == null) {
            recordLogin(null, username, 0, "用户名或密码错误");
            throw new ServiceException("用户名或密码错误");
        }
        if (user.getStatus() != null && user.getStatus() == 0) {
            recordLogin(user, username, 0, "账号已停用");
            throw new ServiceException("账号已停用");
        }
        if (!passwordEncoder.matches(password, user.getPassword())) {
            recordLogin(user, username, 0, "用户名或密码错误");
            throw new ServiceException("用户名或密码错误");
        }
        Map<String, Object> result = buildTokenResponse(user);
        recordLogin(user, username, 1, "登录成功");
        return result;
    }

    public Map<String, Object> loginByEmail(String email, String code) {
        emailCodeService.validateCode(email, "login", code);
        SysUser user = sysUserMapper.selectOne(new LambdaQueryWrapper<SysUser>()
                .eq(SysUser::getEmail, email)
                .last("limit 1"));
        if (user == null) {
            recordLogin(null, email, 0, "邮箱未绑定账号");
            throw new ServiceException("邮箱未绑定账号");
        }
        if (user.getStatus() != null && user.getStatus() == 0) {
            recordLogin(user, email, 0, "账号已停用");
            throw new ServiceException("账号已停用");
        }
        Map<String, Object> result = buildTokenResponse(user);
        recordLogin(user, user.getUsername(), 1, "登录成功");
        return result;
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

    private void recordLogin(SysUser user, String username, int status, String msg) {
        try {
            SysLoginLog log = new SysLoginLog();
            log.setId(IdGeneratorUtil.nextId());
            log.setTenantId(user != null && user.getTenantId() != null ? user.getTenantId() : 0L);
            log.setUserId(user == null ? null : user.getId());
            log.setUsername(username);
            log.setStatus(status);
            log.setMsg(msg);
            log.setLoginTime(LocalDateTime.now());
            HttpServletRequest request = currentRequest();
            if (request != null) {
                log.setIp(clientIp(request));
                String ua = request.getHeader("User-Agent");
                log.setBrowser(parseBrowser(ua));
                log.setOs(parseOs(ua));
            }
            sysLoginLogMapper.insert(log);
        } catch (Exception ignored) {
            // 登录日志失败不影响主流程
        }
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
        result.put("token", accessToken);
        result.put("userInfo", userInfo);
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

    private static HttpServletRequest currentRequest() {
        ServletRequestAttributes attrs = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        return attrs == null ? null : attrs.getRequest();
    }

    private static String clientIp(HttpServletRequest request) {
        String ip = request.getHeader("X-Forwarded-For");
        if (StringUtils.hasText(ip) && !"unknown".equalsIgnoreCase(ip)) {
            int idx = ip.indexOf(',');
            return idx > 0 ? ip.substring(0, idx).trim() : ip.trim();
        }
        ip = request.getHeader("X-Real-IP");
        if (StringUtils.hasText(ip) && !"unknown".equalsIgnoreCase(ip)) {
            return ip;
        }
        return request.getRemoteAddr();
    }

    private static String parseBrowser(String ua) {
        if (!StringUtils.hasText(ua)) {
            return "";
        }
        if (ua.contains("Edg")) return "Edge";
        if (ua.contains("Chrome")) return "Chrome";
        if (ua.contains("Firefox")) return "Firefox";
        if (ua.contains("Safari")) return "Safari";
        return "Other";
    }

    private static String parseOs(String ua) {
        if (!StringUtils.hasText(ua)) {
            return "";
        }
        if (ua.contains("Windows")) return "Windows";
        if (ua.contains("Mac OS")) return "macOS";
        if (ua.contains("Android")) return "Android";
        if (ua.contains("iPhone") || ua.contains("iPad")) return "iOS";
        if (ua.contains("Linux")) return "Linux";
        return "Other";
    }
}
