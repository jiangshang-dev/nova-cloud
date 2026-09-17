package com.alibaba.csp.sentinel.dashboard;

import com.alibaba.csp.sentinel.init.InitExecutor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.core.env.Environment;

/**
 * NovaCloud Sentinel 控制台（参考 Jeecg jeecg-cloud-sentinel）。
 */
@Slf4j
@SpringBootApplication
public class NovaSentinelApplication {

    public static void main(String[] args) {
        System.setProperty("csp.sentinel.app.type", "1");
        triggerSentinelInit();
        ConfigurableApplicationContext application = SpringApplication.run(NovaSentinelApplication.class, args);
        Environment env = application.getEnvironment();
        System.getProperties().setProperty("sentinel.dashboard.auth.username",
                env.getProperty("sentinel.dashboard.auth.username", "sentinel"));
        System.getProperties().setProperty("sentinel.dashboard.auth.password",
                env.getProperty("sentinel.dashboard.auth.password", "sentinel"));
        String port = env.getProperty("server.port", "8718");
        log.info("\n----------------------------------------------------------\n\t"
                + "Nova Sentinel Dashboard is running!\n\t"
                + "Local: \thttp://localhost:" + port + "/\n\t"
                + "----------------------------------------------------------");
    }

    private static void triggerSentinelInit() {
        new Thread(InitExecutor::doInit).start();
    }
}
