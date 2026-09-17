package com.nova.system.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.nova.core.exception.ServiceException;
import com.nova.system.domain.entity.SysMenu;
import com.nova.system.domain.entity.SysRole;
import com.nova.system.domain.entity.SysUser;
import com.nova.system.mapper.SysMenuMapper;
import com.nova.system.mapper.SysRoleMapper;
import com.nova.system.mapper.SysUserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class SysUserService {

    private final SysUserMapper sysUserMapper;
    private final SysRoleMapper sysRoleMapper;
    private final SysMenuMapper sysMenuMapper;

    public Page<SysUser> page(long current, long size, String username) {
        LambdaQueryWrapper<SysUser> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StringUtils.hasText(username), SysUser::getUsername, username)
                .orderByDesc(SysUser::getId);
        return sysUserMapper.selectPage(new Page<>(current, size), wrapper);
    }

    public SysUser getById(Long id) {
        SysUser user = sysUserMapper.selectById(id);
        if (user == null) {
            throw new ServiceException("用户不存在");
        }
        user.setPassword(null);
        return user;
    }

    public Map<String, Object> getUserInfo(Long userId) {
        SysUser user = getById(userId);
        List<SysRole> roles = sysUserMapper.selectRoles(userId);
        List<String> permissions = sysUserMapper.selectPermissions(userId);
        List<SysMenu> menus = sysMenuMapper.selectMenusByUserId(userId);
        Map<String, Object> result = new HashMap<>(8);
        result.put("user", user);
        result.put("roles", roles);
        result.put("permissions", permissions);
        result.put("menus", menus);
        return result;
    }

    public void create(SysUser user) {
        Long count = sysUserMapper.selectCount(new LambdaQueryWrapper<SysUser>()
                .eq(SysUser::getTenantId, user.getTenantId())
                .eq(SysUser::getUsername, user.getUsername()));
        if (count != null && count > 0) {
            throw new ServiceException("用户名已存在");
        }
        sysUserMapper.insert(user);
    }

    public void update(SysUser user) {
        sysUserMapper.updateById(user);
    }

    public void delete(Long id) {
        sysUserMapper.deleteById(id);
    }

    public List<SysRole> listRoles() {
        return sysRoleMapper.selectList(new LambdaQueryWrapper<SysRole>()
                .eq(SysRole::getStatus, 1)
                .orderByAsc(SysRole::getSort));
    }

    public List<SysMenu> listMenus() {
        return sysMenuMapper.selectList(new LambdaQueryWrapper<SysMenu>()
                .eq(SysMenu::getStatus, 1)
                .orderByAsc(SysMenu::getSort));
    }
}
