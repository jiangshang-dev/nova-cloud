package com.nova.demo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

/**
 * 业务服务示例启动类。
 * <p>
 * 新建业务服务时：复制本模块，修改 artifactId / 包名 / 端口 / 路由即可。
 */
@EnableDiscoveryClient
@SpringBootApplication(scanBasePackages = "com.nova")
public class DemoApplication {

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
}
