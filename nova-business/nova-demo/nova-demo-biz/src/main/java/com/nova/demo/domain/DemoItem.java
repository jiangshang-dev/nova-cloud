package com.nova.demo.domain;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * 演示实体（内存存储，仅作脚手架示例）。
 */
@Data
public class DemoItem {
    private Long id;
    private String title;
    private String content;
    private LocalDateTime gmtCreate;
    private LocalDateTime gmtModified;
}
