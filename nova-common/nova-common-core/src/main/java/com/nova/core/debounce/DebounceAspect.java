package com.nova.core.debounce;

import cn.hutool.core.util.StrUtil;
import cn.hutool.crypto.digest.DigestUtil;
import com.nova.core.debounce.annotation.Debounce;
import com.nova.core.exception.ServiceException;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.springframework.boot.autoconfigure.condition.ConditionalOnWebApplication;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import java.util.StringJoiner;

/**
 * Controller 防重复提交切面（由 {@link com.nova.core.config.NovaCoreAutoConfiguration} 导入）。
 */
@Aspect
@RequiredArgsConstructor
@ConditionalOnWebApplication(type = ConditionalOnWebApplication.Type.SERVLET)
public class DebounceAspect {

    private static final String USER_ID_HEADER = "X-User-Id";
    private static final String USERNAME_HEADER = "X-Username";

    private final DebounceCache debounceCache;

    @Before("@annotation(anno)")
    public void before(Debounce anno) {
        long now = System.currentTimeMillis();
        String submitKey = genSubmitKey();

        Long expireTime = debounceCache.get(submitKey);
        if (expireTime != null) {
            if (now < expireTime) {
                throw new ServiceException("请勿重复提交，请稍后再试");
            }
            debounceCache.remove(submitKey);
        }
        debounceCache.put(submitKey, now + anno.expire());
    }

    private String genSubmitKey() {
        HttpServletRequest request = currentRequest();
        StringJoiner raw = new StringJoiner("|");

        String user = "anonymous";
        String userId = request.getHeader(USER_ID_HEADER);
        if (StrUtil.isNotBlank(userId)) {
            user = userId;
        } else if (StrUtil.isNotBlank(request.getHeader(USERNAME_HEADER))) {
            user = request.getHeader(USERNAME_HEADER);
        }
        raw.add(user);
        raw.add(StrUtil.blankToDefault(request.getRemoteAddr(), "unknown"));
        raw.add(request.getRequestURI());
        if (StrUtil.isNotBlank(request.getQueryString())) {
            raw.add(request.getQueryString());
        }
        return "nova:debounce:" + DigestUtil.md5Hex(raw.toString());
    }

    private static HttpServletRequest currentRequest() {
        ServletRequestAttributes attrs = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attrs == null || attrs.getRequest() == null) {
            throw new ServiceException("无法获取当前请求上下文");
        }
        return attrs.getRequest();
    }
}
