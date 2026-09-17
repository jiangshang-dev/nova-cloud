package com.nova.security.inner;

import com.nova.security.constants.SecurityConstants;
import com.nova.security.properties.InnerAuthProperties;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.util.StringUtils;

/**
 * 内部调用鉴权工具。
 */
public final class InnerAuthSupport {

    private InnerAuthSupport() {
    }

    /**
     * 是否为合法的服务间内部请求。
     */
    public static boolean isInnerRequest(HttpServletRequest request, InnerAuthProperties properties) {
        if (properties == null || !properties.isEnabled() || !StringUtils.hasText(properties.getToken())) {
            return false;
        }
        String from = request.getHeader(SecurityConstants.FROM_SOURCE_HEADER);
        if (!SecurityConstants.FROM_INNER.equalsIgnoreCase(from)) {
            return false;
        }
        String headerName = StringUtils.hasText(properties.getHeader())
                ? properties.getHeader()
                : SecurityConstants.INNER_TOKEN_HEADER;
        String token = request.getHeader(headerName);
        return properties.getToken().equals(token);
    }
}
