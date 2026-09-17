package com.nova.demo.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nova.core.utils.AssertUtil;
import com.nova.core.utils.IdGeneratorUtil;
import com.nova.demo.domain.entity.DemoOrder;
import com.nova.demo.mapper.DemoOrderMapper;
import com.nova.demo.service.DemoOrderService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class DemoOrderServiceImpl implements DemoOrderService {

    private final DemoOrderMapper demoOrderMapper;

    @Override
    public DemoOrder create(Long userId, BigDecimal amount) {
        AssertUtil.notNull(userId, "userId 不能为空");
        AssertUtil.notNull(amount, "amount 不能为空");

        DemoOrder order = new DemoOrder();
        order.setId(IdGeneratorUtil.nextId());
        order.setUserId(userId);
        order.setOrderNo("DO" + UUID.randomUUID().toString().replace("-", "").substring(0, 16));
        order.setAmount(amount);
        order.setStatus(0);
        LocalDateTime now = LocalDateTime.now();
        order.setGmtCreate(now);
        order.setGmtModified(now);
        demoOrderMapper.insert(order);
        log.info("创建演示订单 id={}, userId={}, 预期分表=demo_order_{}",
                order.getId(), userId, userId % 2);
        return order;
    }

    @Override
    public DemoOrder getById(Long id, Long userId) {
        AssertUtil.notNull(id, "id 不能为空");
        LambdaQueryWrapper<DemoOrder> qw = new LambdaQueryWrapper<DemoOrder>()
                .eq(DemoOrder::getId, id);
        if (userId != null) {
            qw.eq(DemoOrder::getUserId, userId);
        }
        DemoOrder order = demoOrderMapper.selectOne(qw);
        AssertUtil.notNull(order, "订单不存在");
        return order;
    }

    @Override
    public List<DemoOrder> listByUserId(Long userId) {
        AssertUtil.notNull(userId, "userId 不能为空");
        return demoOrderMapper.selectList(new LambdaQueryWrapper<DemoOrder>()
                .eq(DemoOrder::getUserId, userId)
                .orderByDesc(DemoOrder::getGmtCreate));
    }
}
