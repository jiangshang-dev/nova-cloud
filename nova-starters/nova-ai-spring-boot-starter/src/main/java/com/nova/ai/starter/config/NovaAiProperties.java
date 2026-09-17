package com.nova.ai.starter.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Data
@ConfigurationProperties(prefix = "nova.ai")
public class NovaAiProperties {

    /** Harness 工作区根目录 */
    private String workspace = "./work/agentscope/workspace";

    /** 默认会话压缩：触发消息数 */
    private int compactionTriggerMessages = 30;

    /** 默认会话压缩：保留消息数 */
    private int compactionKeepMessages = 10;
}
