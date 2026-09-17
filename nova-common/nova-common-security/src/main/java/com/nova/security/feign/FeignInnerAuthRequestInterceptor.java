package com.nova.security.feign;

import com.nova.security.constants.SecurityConstants;
import com.nova.security.properties.InnerAuthProperties;
import feign.RequestInterceptor;
import feign.RequestTemplate;
import lombok.RequiredArgsConstructor;
import org.springframework.util.StringUtils;

/**
 * Feign 请求拦截器：为服务间调用附加内部免登 Token。
 */
@RequiredArgsConstructor
public class FeignInnerAuthRequestInterceptor implements RequestInterceptor {

    private final InnerAuthProperties properties;

    @Override
    public void apply(RequestTemplate template) {
        if (properties == null || !properties.isEnabled() || !StringUtils.hasText(properties.getToken())) {
            return;
        }
        String headerName = StringUtils.hasText(properties.getHeader())
                ? properties.getHeader()
                : SecurityConstants.INNER_TOKEN_HEADER;
        template.header(headerName, properties.getToken());
        template.header(SecurityConstants.FROM_SOURCE_HEADER, SecurityConstants.FROM_INNER);
    }
}
