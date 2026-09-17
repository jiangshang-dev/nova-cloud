package com.nova.auth.controller;

import com.nova.auth.service.AuthLoginService;
import com.nova.auth.service.CaptchaService;
import com.nova.auth.service.EmailCodeService;
import com.nova.core.debounce.annotation.Debounce;
import com.nova.core.result.R;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.util.StringUtils;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@Tag(name = "认证中心")
@Validated
@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthLoginService authLoginService;
    private final EmailCodeService emailCodeService;
    private final CaptchaService captchaService;

    @Operation(summary = "获取图形验证码")
    @GetMapping("/captcha/{checkKey}")
    public R<String> captcha(@PathVariable("checkKey") String checkKey) {
        return R.ok(captchaService.createImage(checkKey));
    }

    @Debounce
    @Operation(summary = "发送邮箱验证码")
    @PostMapping("/code/email")
    public R<Void> sendEmailCode(@RequestBody @Validated EmailCodeRequest request) {
        emailCodeService.sendEmailCode(request.getEmail(), request.getScene());
        return R.ok();
    }

    @Debounce
    @Operation(summary = "账号密码登录")
    @PostMapping("/login/password")
    public R<Map<String, Object>> loginByPassword(@RequestBody @Validated PasswordLoginRequest request) {
        captchaService.validate(request.getCheckKey(), request.getCaptcha());
        return R.ok(authLoginService.loginByPassword(request.getUsername(), request.getPassword()));
    }

    @Debounce
    @Operation(summary = "邮箱验证码登录")
    @PostMapping("/login/email")
    public R<Map<String, Object>> loginByEmail(@RequestBody @Validated EmailLoginRequest request) {
        return R.ok(authLoginService.loginByEmail(request.getEmail(), request.getCode()));
    }

    @Operation(summary = "当前登录用户信息")
    @GetMapping("/user/info")
    public R<Map<String, Object>> userInfo(HttpServletRequest request) {
        return R.ok(authLoginService.currentUserInfo(resolveBearerToken(request)));
    }

    @Operation(summary = "退出登录")
    @PostMapping("/logout")
    public R<Void> logout() {
        return R.ok();
    }

    private static String resolveBearerToken(HttpServletRequest request) {
        String authorization = request.getHeader("Authorization");
        if (StringUtils.hasText(authorization) && authorization.startsWith("Bearer ")) {
            return authorization.substring(7).trim();
        }
        String accessToken = request.getHeader("X-Access-Token");
        if (StringUtils.hasText(accessToken)) {
            return accessToken.trim();
        }
        return null;
    }

    @Data
    public static class EmailCodeRequest {
        @NotBlank
        @Email
        private String email;
        /** login / register / reset */
        private String scene = "login";
    }

    @Data
    public static class PasswordLoginRequest {
        @NotBlank
        private String username;
        @NotBlank
        private String password;
        @NotBlank
        private String captcha;
        @NotBlank
        private String checkKey;
    }

    @Data
    public static class EmailLoginRequest {
        @NotBlank
        @Email
        private String email;
        @NotBlank
        private String code;
    }
}
