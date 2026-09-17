package com.nova.file.api.constant;

/**
 * 文件服务远程调用常量。
 */
public final class FileServiceConstants {

    private FileServiceConstants() {
    }

    /** Nacos / 注册中心服务名 */
    public static final String SERVICE_NAME = "nova-file";

    /** 内部 Feign 调用路径前缀（免登，需携带内部 Token） */
    public static final String INNER_PATH = "/inner/file";
}
