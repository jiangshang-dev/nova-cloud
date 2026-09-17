package com.nova.system.controller;

import com.nova.core.debounce.annotation.Debounce;
import com.nova.core.result.R;
import com.nova.log.annotation.AutoLog;
import com.nova.security.constants.SecurityConstants;
import com.nova.system.domain.entity.SysMenu;
import com.nova.system.domain.vo.MenuTreeVo;
import com.nova.system.domain.vo.UserPermissionVo;
import com.nova.system.service.SysMenuService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "系统菜单")
@RestController
@RequestMapping("/system/menu")
@RequiredArgsConstructor
public class SysMenuController {

    private final SysMenuService sysMenuService;

    @AutoLog("菜单管理-用户权限菜单")
    @Operation(summary = "当前用户菜单与权限（Jeecg 兼容）")
    @GetMapping("/user")
    public R<UserPermissionVo> userMenus(@RequestHeader(SecurityConstants.USER_ID_HEADER) Long userId) {
        return R.ok(sysMenuService.getUserPermission(userId));
    }

    @AutoLog("菜单管理-菜单树")
    @Operation(summary = "菜单树")
    @GetMapping("/tree")
    public R<List<MenuTreeVo>> tree() {
        return R.ok(sysMenuService.tree());
    }

    @AutoLog("菜单管理-列表查询")
    @Operation(summary = "菜单列表")
    @GetMapping("/list")
    public R<List<SysMenu>> list() {
        return R.ok(sysMenuService.listMenus());
    }

    @AutoLog("菜单管理-详情")
    @Operation(summary = "菜单详情")
    @GetMapping("/{id}")
    public R<SysMenu> detail(@PathVariable Long id) {
        return R.ok(sysMenuService.getById(id));
    }

    @Debounce
    @AutoLog(value = "菜单管理-新增", businessType = 1)
    @Operation(summary = "新增菜单")
    @PostMapping
    public R<Void> create(@RequestBody SysMenu menu) {
        sysMenuService.create(menu);
        return R.ok();
    }

    @Debounce
    @AutoLog(value = "菜单管理-修改", businessType = 2)
    @Operation(summary = "修改菜单")
    @PutMapping
    public R<Void> update(@RequestBody SysMenu menu) {
        sysMenuService.update(menu);
        return R.ok();
    }

    @Debounce
    @AutoLog(value = "菜单管理-删除", businessType = 3)
    @Operation(summary = "删除菜单")
    @DeleteMapping("/{id}")
    public R<Void> delete(@PathVariable Long id) {
        sysMenuService.delete(id);
        return R.ok();
    }
}
