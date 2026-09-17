package com.nova.system.domain.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("sys_role_menu")
public class SysRoleMenu {
    @TableId
    private Long id;
    private Long roleId;
    private Long menuId;
    private LocalDateTime gmtCreate;
    private LocalDateTime gmtModified;
}
