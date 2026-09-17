package com.nova.demo.domain;

import lombok.Data;

import java.time.LocalDateTime;

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
