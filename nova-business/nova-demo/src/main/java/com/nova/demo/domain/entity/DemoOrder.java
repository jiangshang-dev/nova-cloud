package com.nova.demo.domain.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 演示订单（逻辑表 demo_order，物理表 demo_order_0 / demo_order_1）。
 * 分片键：userId。
 */
@Data
@TableName("demo_order")
public class DemoOrder {

    @TableId
    private Long id;
    private Long userId;
    private String orderNo;
    private BigDecimal amount;
    /** 0待支付 1已支付 2已取消 */
    private Integer status;
    private LocalDateTime gmtCreate;
    private LocalDateTime gmtModified;
}
