package com.nova.system.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.nova.core.exception.ServiceException;
import com.nova.core.utils.IdGeneratorUtil;
import com.nova.system.domain.entity.SysMenu;
import com.nova.system.domain.entity.SysRole;
import com.nova.system.domain.vo.MenuTreeVo;
import com.nova.system.domain.vo.UserPermissionVo;
import com.nova.system.mapper.SysMenuMapper;
import com.nova.system.mapper.SysUserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SysMenuService {

    private static final String SUPER_ADMIN = "super_admin";

    private final SysMenuMapper sysMenuMapper;
    private final SysUserMapper sysUserMapper;
    private final MenuRouteBuilder menuRouteBuilder;

    public UserPermissionVo getUserPermission(Long userId) {
        List<SysMenu> menus = loadMenusForUser(userId);
        return menuRouteBuilder.build(menus);
    }

    public List<SysMenu> listMenus() {
        return sysMenuMapper.selectList(new LambdaQueryWrapper<SysMenu>()
                .eq(SysMenu::getStatus, 1)
                .orderByAsc(SysMenu::getSort));
    }

    public List<MenuTreeVo> tree() {
        List<SysMenu> all = sysMenuMapper.selectList(new LambdaQueryWrapper<SysMenu>()
                .orderByAsc(SysMenu::getSort));
        Map<Long, List<SysMenu>> grouped = all.stream()
                .collect(Collectors.groupingBy(m -> m.getParentId() == null ? 0L : m.getParentId()));
        return buildTree(grouped, 0L);
    }

    public SysMenu getById(Long id) {
        SysMenu menu = sysMenuMapper.selectById(id);
        if (menu == null) {
            throw new ServiceException("菜单不存在");
        }
        return menu;
    }

    public void create(SysMenu menu) {
        if (menu.getId() == null) {
            menu.setId(IdGeneratorUtil.nextId());
        }
        if (menu.getParentId() == null) {
            menu.setParentId(0L);
        }
        if (menu.getStatus() == null) {
            menu.setStatus(1);
        }
        if (menu.getIsVisible() == null) {
            menu.setIsVisible(1);
        }
        sysMenuMapper.insert(menu);
    }

    public void update(SysMenu menu) {
        if (menu.getId() == null) {
            throw new ServiceException("菜单ID不能为空");
        }
        getById(menu.getId());
        sysMenuMapper.updateById(menu);
    }

    public void delete(Long id) {
        Long childCount = sysMenuMapper.selectCount(new LambdaQueryWrapper<SysMenu>().eq(SysMenu::getParentId, id));
        if (childCount != null && childCount > 0) {
            throw new ServiceException("存在子菜单，无法删除");
        }
        sysMenuMapper.deleteById(id);
    }

    private List<SysMenu> loadMenusForUser(Long userId) {
        if (userId != null && userId == 1L) {
            return allActiveMenus();
        }
        List<SysRole> roles = sysUserMapper.selectRoles(userId);
        boolean superAdmin = roles.stream().anyMatch(r -> SUPER_ADMIN.equals(r.getRoleCode()));
        if (superAdmin) {
            return allActiveMenus();
        }
        return sysMenuMapper.selectMenusByUserId(userId);
    }

    private List<SysMenu> allActiveMenus() {
        return sysMenuMapper.selectList(new LambdaQueryWrapper<SysMenu>()
                .eq(SysMenu::getStatus, 1)
                .orderByAsc(SysMenu::getSort));
    }

    private List<MenuTreeVo> buildTree(Map<Long, List<SysMenu>> grouped, Long parentId) {
        List<SysMenu> nodes = grouped.getOrDefault(parentId, List.of()).stream()
                .sorted(Comparator.comparing(SysMenu::getSort, Comparator.nullsLast(Integer::compareTo)))
                .toList();
        List<MenuTreeVo> result = new ArrayList<>();
        for (SysMenu node : nodes) {
            MenuTreeVo vo = new MenuTreeVo();
            BeanUtils.copyProperties(node, vo);
            vo.setChildren(buildTree(grouped, node.getId()));
            result.add(vo);
        }
        return result;
    }
}
