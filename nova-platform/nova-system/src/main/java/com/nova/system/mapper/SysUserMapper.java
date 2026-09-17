package com.nova.system.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.nova.system.domain.entity.SysUser;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface SysUserMapper extends BaseMapper<SysUser> {

    @Select("""
            SELECT m.permission
            FROM sys_menu m
            INNER JOIN sys_role_menu rm ON m.id = rm.menu_id
            INNER JOIN sys_user_role ur ON rm.role_id = ur.role_id
            WHERE ur.user_id = #{userId}
              AND m.is_deleted = 0
              AND m.status = 1
              AND m.permission IS NOT NULL
              AND m.permission <> ''
            """)
    List<String> selectPermissions(@Param("userId") Long userId);

    @Select("""
            SELECT r.*
            FROM sys_role r
            INNER JOIN sys_user_role ur ON r.id = ur.role_id
            WHERE ur.user_id = #{userId}
              AND r.is_deleted = 0
              AND r.status = 1
            """)
    List<com.nova.system.domain.entity.SysRole> selectRoles(@Param("userId") Long userId);
}
