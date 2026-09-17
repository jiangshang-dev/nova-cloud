package com.nova.log.model;

import lombok.Builder;
import lombok.Data;

import java.io.Serializable;
import java.time.LocalDateTime;

@Data
@Builder
public class OperLogInfo implements Serializable {
    private String title;
    private Integer businessType;
    private String method;
    private String requestMethod;
    private String operName;
    private String operUrl;
    private String operIp;
    private String operParam;
    private String jsonResult;
    /** 0失败 1成功 */
    private Integer status;
    private String errorMsg;
    private Long costTime;
    private LocalDateTime operTime;
    private Long tenantId;
    private Long userId;
}
