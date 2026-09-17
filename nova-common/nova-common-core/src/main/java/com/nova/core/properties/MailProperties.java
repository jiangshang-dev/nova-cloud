package com.nova.core.properties;

import cn.hutool.extra.mail.MailAccount;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

/**
 * 邮件配置。
 */
@Data
@ConfigurationProperties(prefix = "nova.mail")
public class MailProperties {

    /**
     * 是否启用邮件能力。
     */
    private boolean enabled = false;

    /**
     * Hutool MailAccount。
     */
    private MailAccount account = new MailAccount();
}
