package com.nova.system.controller;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@Tag(name = "健康检查")
@RestController
@RequestMapping("/api/system")
public class HealthController {

    @Operation(summary = "服务探活")
    @GetMapping("/health")
    public Map<String, Object> health() {
        return Map.of(
                "service", "nova-system",
                "status", "UP"
        );
    }
}
