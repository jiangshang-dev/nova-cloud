package com.nova.demo.api.dto;

import lombok.Data;

import java.io.Serial;
import java.io.Serializable;

@Data
public class TodoUpdateRequest implements Serializable {

    @Serial
    private static final long serialVersionUID = 1L;

    private String title;
    private String content;
    /** 0 待办 1 完成 */
    private Integer status;
}
