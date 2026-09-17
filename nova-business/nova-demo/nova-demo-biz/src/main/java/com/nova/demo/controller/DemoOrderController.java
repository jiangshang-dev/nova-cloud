package com.nova.demo.controller;

import com.nova.core.result.R;
import com.nova.demo.domain.entity.DemoOrder;
import com.nova.demo.service.DemoOrderService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.util.List;

/**
 * ShardingSphere 分表读写示例 API。
 */
@Tag(name = "Demo 分表示例")
@RestController
@RequestMapping("/demo/order")
@RequiredArgsConstructor
public class DemoOrderController {

    private final DemoOrderService demoOrderService;

    @Operation(summary = "创建订单（按 userId 分表）")
    @PostMapping
    public R<DemoOrder> create(@RequestBody CreateOrderReq req) {
        return R.ok(demoOrderService.create(req.getUserId(), req.getAmount()));
    }

    @Operation(summary = "按 id 查询（建议带 userId 避免广播）")
    @GetMapping("/{id}")
    public R<DemoOrder> detail(@PathVariable Long id,
                               @RequestParam(required = false) Long userId) {
        return R.ok(demoOrderService.getById(id, userId));
    }

    @Operation(summary = "按 userId 列表（精确路由单表）")
    @GetMapping("/list")
    public R<List<DemoOrder>> list(@RequestParam Long userId) {
        return R.ok(demoOrderService.listByUserId(userId));
    }

    @Data
    public static class CreateOrderReq {
        private Long userId;
        private BigDecimal amount;
    }
}
