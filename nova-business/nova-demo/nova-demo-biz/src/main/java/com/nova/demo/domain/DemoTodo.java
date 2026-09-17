package com.nova.demo.domain;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * Todo 演示实体（内存存储，展示 Feign 服务间调用）。
 */
@Data
public class DemoTodo {
    private Long id;
    private String title;
    private String content;
    /** 0 待办 1 完成 */
    private Integer status;
    private LocalDateTime gmtCreate;
    private LocalDateTime gmtModified;
}
