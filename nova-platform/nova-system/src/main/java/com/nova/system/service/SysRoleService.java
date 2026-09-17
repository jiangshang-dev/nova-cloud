package com.nova.system.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.nova.core.exception.ServiceException;
import com.nova.core.utils.IdGeneratorUtil;
import com.nova.system.domain.entity.SysRole;
import com.nova.system.domain.entity.SysRoleMenu;
import com.nova.system.domain.entity.SysUser;
import com.nova.system.domain.entity.SysUserRole;
import com.nova.system.mapper.SysRoleMapper;
import com.nova.system.mapper.SysRoleMenuMapper;
import com.nova.system.mapper.SysUserMapper;
import com.nova.system.mapper.SysUserRoleMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.List;

@Service
@RequiredArgsConstructor
public class SysRoleService {

    private final SysRoleMapper sysRoleMapper;
    private final SysRoleMenuMapper sysRoleMenuMapper;
    private final SysUserRoleMapper sysUserRoleMapper;
    private final SysUserMapper sysUserMapper;

    public Page<SysRole> page(long current, long size, String roleName) {
        LambdaQueryWrapper<SysRole> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StringUtils.hasText(roleName), SysRole::getRoleName, roleName)
                .orderByAsc(SysRole::getSort)
                .orderByDesc(SysRole::getId);
        return sysRoleMapper.selectPage(new Page<>(current, size), wrapper);
    }

    public List<SysRole> list() {
        return sysRoleMapper.selectList(new LambdaQueryWrapper<SysRole>()
                .eq(SysRole::getStatus, 1)
                .orderByAsc(SysRole::getSort));
    }

    public SysRole getById(Long id) {
        SysRole role = sysRoleMapper.selectById(id);
        if (role == null) {
            throw new ServiceException("角色不存在");
        }
        return role;
    }

    public Long create(SysRole role) {
        if (role.getId() == null) {
            role.setId(IdGeneratorUtil.nextId());
        }
        if (role.getTenantId() == null) {
            role.setTenantId(1L);
        }
        if (role.getStatus() == null) {
            role.setStatus(1);
        }
        if (role.getSort() == null) {
            role.setSort(0);
        }
        if (role.getDataScope() == null) {
            role.setDataScope(1);
        }
        Long count = sysRoleMapper.selectCount(new LambdaQueryWrapper<SysRole>()
                .eq(SysRole::getTenantId, role.getTenantId())
                .eq(SysRole::getRoleCode, role.getRoleCode()));
        if (count != null && count > 0) {
            throw new ServiceException("角色编码已存在");
        }
        sysRoleMapper.insert(role);
        return role.getId();
    }

    public void update(SysRole role) {
        if (role.getId() == null) {
            throw new ServiceException("角色ID不能为空");
        }
        getById(role.getId());
        sysRoleMapper.updateById(role);
    }

    public void delete(Long id) {
        sysRoleMapper.deleteById(id);
        sysRoleMenuMapper.deleteByRoleId(id);
        sysUserRoleMapper.deleteByRoleId(id);
    }

    public List<Long> getMenuIds(Long roleId) {
        getById(roleId);
        return sysRoleMenuMapper.selectMenuIdsByRoleId(roleId);
    }

    @Transactional(rollbackFor = Exception.class)
    public void replaceMenus(Long roleId, List<Long> menuIds) {
        getById(roleId);
        sysRoleMenuMapper.deleteByRoleId(roleId);
        if (menuIds == null || menuIds.isEmpty()) {
            return;
        }
        for (Long menuId : menuIds) {
            SysRoleMenu rm = new SysRoleMenu();
            rm.setId(IdGeneratorUtil.nextId());
            rm.setRoleId(roleId);
            rm.setMenuId(menuId);
            sysRoleMenuMapper.insert(rm);
        }
    }

    public List<Long> getUserIds(Long roleId) {
        getById(roleId);
        return sysUserRoleMapper.selectUserIdsByRoleId(roleId);
    }

    public List<SysUser> listUsers(Long roleId) {
        getById(roleId);
        List<Long> userIds = sysUserRoleMapper.selectUserIdsByRoleId(roleId);
        if (userIds == null || userIds.isEmpty()) {
            return List.of();
        }
        List<SysUser> users = sysUserMapper.selectList(new LambdaQueryWrapper<SysUser>()
                .in(SysUser::getId, userIds)
                .orderByDesc(SysUser::getId));
        users.forEach(u -> u.setPassword(null));
        return users;
    }

    @Transactional(rollbackFor = Exception.class)
    public void replaceUsers(Long roleId, List<Long> userIds) {
        getById(roleId);
        sysUserRoleMapper.deleteByRoleId(roleId);
        if (userIds == null || userIds.isEmpty()) {
            return;
        }
        for (Long userId : userIds) {
            SysUserRole ur = new SysUserRole();
            ur.setId(IdGeneratorUtil.nextId());
            ur.setRoleId(roleId);
            ur.setUserId(userId);
            sysUserRoleMapper.insert(ur);
        }
    }
}
