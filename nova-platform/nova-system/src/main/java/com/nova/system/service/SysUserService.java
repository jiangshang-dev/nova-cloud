package com.nova.system.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.nova.core.exception.ServiceException;
import com.nova.core.utils.IdGeneratorUtil;
import com.nova.system.domain.entity.SysMenu;
import com.nova.system.domain.entity.SysRole;
import com.nova.system.domain.entity.SysUser;
import com.nova.system.domain.entity.SysUserRole;
import com.nova.system.mapper.SysMenuMapper;
import com.nova.system.mapper.SysRoleMapper;
import com.nova.system.mapper.SysUserMapper;
import com.nova.system.mapper.SysUserRoleMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class SysUserService {

    private static final String DEFAULT_PASSWORD = "admin123";

    private final SysUserMapper sysUserMapper;
    private final SysRoleMapper sysRoleMapper;
    private final SysMenuMapper sysMenuMapper;
    private final SysUserRoleMapper sysUserRoleMapper;
    private final PasswordEncoder passwordEncoder;

    public Page<SysUser> page(long current, long size, String username) {
        LambdaQueryWrapper<SysUser> wrapper = new LambdaQueryWrapper<>();
        wrapper.like(StringUtils.hasText(username), SysUser::getUsername, username)
                .orderByDesc(SysUser::getId);
        Page<SysUser> page = sysUserMapper.selectPage(new Page<>(current, size), wrapper);
        page.getRecords().forEach(u -> u.setPassword(null));
        return page;
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

    public Long create(SysUser user) {
        if (user.getTenantId() == null) {
            user.setTenantId(1L);
        }
        if (user.getStatus() == null) {
            user.setStatus(1);
        }
        if (user.getId() == null) {
            user.setId(IdGeneratorUtil.nextId());
        }
        if (!StringUtils.hasText(user.getPassword())) {
            user.setPassword(DEFAULT_PASSWORD);
        }
        user.setPassword(passwordEncoder.encode(user.getPassword()));

        Long count = sysUserMapper.selectCount(new LambdaQueryWrapper<SysUser>()
                .eq(SysUser::getTenantId, user.getTenantId())
                .eq(SysUser::getUsername, user.getUsername()));
        if (count != null && count > 0) {
            throw new ServiceException("用户名已存在");
        }
        sysUserMapper.insert(user);
        return user.getId();
    }

    public void update(SysUser user) {
        if (user.getId() == null) {
            throw new ServiceException("用户ID不能为空");
        }
        getById(user.getId());
        if (!StringUtils.hasText(user.getPassword())) {
            user.setPassword(null);
        } else {
            user.setPassword(passwordEncoder.encode(user.getPassword()));
        }
        sysUserMapper.updateById(user);
    }

    public void updatePassword(Long id, String password) {
        if (!StringUtils.hasText(password)) {
            throw new ServiceException("密码不能为空");
        }
        getById(id);
        sysUserMapper.update(null, new LambdaUpdateWrapper<SysUser>()
                .eq(SysUser::getId, id)
                .set(SysUser::getPassword, passwordEncoder.encode(password)));
    }

    public void delete(Long id) {
        sysUserMapper.deleteById(id);
        sysUserRoleMapper.deleteByUserId(id);
    }

    public List<SysRole> listRoles() {
        return sysRoleMapper.selectList(new LambdaQueryWrapper<SysRole>()
                .eq(SysRole::getStatus, 1)
                .orderByAsc(SysRole::getSort));
    }

    public List<Long> getRoleIds(Long userId) {
        getById(userId);
        return sysUserRoleMapper.selectRoleIdsByUserId(userId);
    }

    @Transactional(rollbackFor = Exception.class)
    public void replaceRoles(Long userId, List<Long> roleIds) {
        getById(userId);
        sysUserRoleMapper.deleteByUserId(userId);
        if (roleIds == null || roleIds.isEmpty()) {
            return;
        }
        for (Long roleId : roleIds) {
            SysUserRole ur = new SysUserRole();
            ur.setId(IdGeneratorUtil.nextId());
            ur.setUserId(userId);
            ur.setRoleId(roleId);
            sysUserRoleMapper.insert(ur);
        }
    }
}
