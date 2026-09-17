package com.nova.security.properties;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Data
@ConfigurationProperties(prefix = "nova.security.jwt")
public class JwtProperties {

    /**
     * HMAC 密钥，长度建议 >= 32。
     */
    private String secret = "NovaCloudJwtSecretKeyChangeMePlease32";

    /**
     * access_token 有效期（秒）。
     */
    private long expireSeconds = 7200L;

    /**
     * 签发者。
     */
    private String issuer = "nova-cloud";
}
