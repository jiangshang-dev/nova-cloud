package com.nova.system.domain.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("sys_dept")
public class SysDept {
    @TableId
    private Long id;
    private Long tenantId;
    private Long parentId;
    private String ancestors;
    private String deptName;
    private String deptCode;
    private Integer sort;
    private Long leaderId;
    private String phone;
    private String email;
    private Integer status;
    private Long createBy;
    private Long updateBy;
    @TableLogic
    private Integer isDeleted;
    private String remark;
    private LocalDateTime gmtCreate;
    private LocalDateTime gmtModified;
}
