package com.nova.crypto.properties;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * 国密加解密配置。
 */
@Data
@ConfigurationProperties(prefix = "nova.crypto")
public class CryptoProperties {

    /**
     * 总开关：关闭后请求/响应按明文透传。
     */
    private boolean enabled = false;

    /**
     * SM4 密钥（16字节，建议配置 Base64 或 32位 Hex）。
     */
    private String sm4Key = "NovaCloudSm4Key!";

    /**
     * SM3 签名盐值。
     */
    private String sm3Salt = "NovaCloudSm3Salt";

    /**
     * 请求头：加密开关透传标记。
     */
    private String encryptHeader = "X-Nova-Encrypt";

    /**
     * 请求头：SM3 签名。
     */
    private String signHeader = "X-Nova-Sign";

    /**
     * 请求头：时间戳。
     */
    private String timestampHeader = "X-Nova-Timestamp";
}
