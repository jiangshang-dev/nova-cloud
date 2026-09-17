package com.nova.demo.api.constant;

/**
 * Demo 服务远程调用常量。
 */
public final class DemoServiceConstants {

    private DemoServiceConstants() {
    }

    /** Nacos / 注册中心服务名 */
    public static final String SERVICE_NAME = "nova-demo";

    /** 内部 Feign 调用路径前缀（免登，需携带内部 Token） */
    public static final String INNER_TODO_PATH = "/inner/demo/todo";
}
