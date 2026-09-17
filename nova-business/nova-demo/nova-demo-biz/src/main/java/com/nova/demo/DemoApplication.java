package com.nova.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.openfeign.EnableFeignClients;

/**
 * 业务服务示例启动类。
 * <p>
 * 新建业务服务时：复制本模块（api + biz），修改 artifactId / 包名 / 端口 / 路由即可。
 * <p>
 * OpenFeign 示例见 {@link com.nova.demo.api.RemoteTodoApi} 与 {@link com.nova.demo.controller.DemoFeignTodoController}。
 */
@EnableDiscoveryClient
@EnableFeignClients(basePackages = "com.nova")
@SpringBootApplication(scanBasePackages = "com.nova")
public class DemoApplication {

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
}
