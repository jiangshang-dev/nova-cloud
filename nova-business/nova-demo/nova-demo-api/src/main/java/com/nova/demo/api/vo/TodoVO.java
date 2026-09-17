package com.nova.demo.api.vo;

import lombok.Data;

import java.io.Serial;
import java.io.Serializable;
import java.time.LocalDateTime;

@Data
public class TodoVO implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    private Long id;
    private String title;
    private String content;
    /** 0 待办 1 完成 */
    private Integer status;
    private LocalDateTime gmtCreate;
    private LocalDateTime gmtModified;
}
