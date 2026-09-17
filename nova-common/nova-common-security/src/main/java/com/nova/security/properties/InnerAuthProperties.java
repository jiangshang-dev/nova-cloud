package com.nova.security.properties;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * 服务间内部调用免登配置（prefix = nova.security.inner）。
 * <p>
 * Feign 调用方自动携带 Token；被调方校验通过后写入 ROLE_INNER，无需用户登录 JWT。
 */
@Data
@ConfigurationProperties(prefix = "nova.security.inner")
public class InnerAuthProperties {

    /** 是否启用内部调用鉴权 */
    private boolean enabled = true;

    /**
     * 内部共享 Token（所有微服务保持一致；生产务必修改）。
     */
    private String token = "NovaCloudInnerTokenChangeMe";

    /** 请求头名称，默认 X-Nova-Inner-Token */
    private String header = "X-Nova-Inner-Token";
}
