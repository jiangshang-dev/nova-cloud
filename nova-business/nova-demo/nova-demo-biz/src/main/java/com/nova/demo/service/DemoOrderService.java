package com.nova.demo.service;

import com.nova.demo.domain.entity.DemoOrder;

import java.math.BigDecimal;
import java.util.List;

/**
 * ShardingSphere 分表示例：按 userId 路由到 demo_order_0 / demo_order_1。
 */
public interface DemoOrderService {

    DemoOrder create(Long userId, BigDecimal amount);

    DemoOrder getById(Long id, Long userId);

    List<DemoOrder> listByUserId(Long userId);
}
