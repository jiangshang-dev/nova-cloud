package com.nova.system.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.nova.core.debounce.annotation.Debounce;
import com.nova.core.result.R;
import com.nova.log.annotation.AutoLog;
import com.nova.system.domain.entity.SysRole;
import com.nova.system.service.SysRoleService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "系统角色")
@RestController
@RequestMapping("/system/role")
@RequiredArgsConstructor
public class SysRoleController {

    private final SysRoleService sysRoleService;

    @Operation(summary = "角色分页")
    @GetMapping("/page")
    public R<Page<SysRole>> page(@RequestParam(defaultValue = "1") long current,
                                 @RequestParam(defaultValue = "10") long size,
                                 @RequestParam(required = false) String roleName) {
        return R.ok(sysRoleService.page(current, size, roleName));
    }

    @Operation(summary = "角色列表")
    @GetMapping("/list")
    public R<List<SysRole>> list() {
        return R.ok(sysRoleService.list());
    }

    @Operation(summary = "角色详情")
    @GetMapping("/{id}")
    public R<SysRole> detail(@PathVariable Long id) {
        return R.ok(sysRoleService.getById(id));
    }

    @Debounce
    @AutoLog("角色管理-新增")
    @Operation(summary = "新增角色")
    @PostMapping
    public R<Long> create(@RequestBody SysRole role) {
        return R.ok(sysRoleService.create(role));
    }

    @Debounce
    @AutoLog("角色管理-修改")
    @Operation(summary = "修改角色")
    @PutMapping
    public R<Void> update(@RequestBody SysRole role) {
        sysRoleService.update(role);
        return R.ok();
    }

    @Debounce
    @AutoLog(value = "角色管理-删除", businessType = 3)
    @Operation(summary = "删除角色")
    @DeleteMapping("/{id}")
    public R<Void> delete(@PathVariable Long id) {
        sysRoleService.delete(id);
        return R.ok();
    }

    @Operation(summary = "角色菜单ID列表")
    @GetMapping("/{id}/menuIds")
    public R<List<Long>> menuIds(@PathVariable Long id) {
        return R.ok(sysRoleService.getMenuIds(id));
    }

    @Debounce
    @AutoLog(value = "角色管理-授权菜单", businessType = 4)
    @Operation(summary = "分配角色菜单（含按钮权限）")
    @PutMapping("/{id}/menus")
    public R<Void> assignMenus(@PathVariable Long id, @RequestBody List<Long> menuIds) {
        sysRoleService.replaceMenus(id, menuIds);
        return R.ok();
    }

    @Operation(summary = "角色下用户ID列表")
    @GetMapping("/{id}/userIds")
    public R<List<Long>> userIds(@PathVariable Long id) {
        return R.ok(sysRoleService.getUserIds(id));
    }

    @Operation(summary = "角色下用户列表")
    @GetMapping("/{id}/users")
    public R<List<com.nova.system.domain.entity.SysUser>> users(@PathVariable Long id) {
        return R.ok(sysRoleService.listUsers(id));
    }

    @Debounce
    @AutoLog(value = "角色管理-分配用户", businessType = 4)
    @Operation(summary = "分配角色用户")
    @PutMapping("/{id}/users")
    public R<Void> assignUsers(@PathVariable Long id, @RequestBody List<Long> userIds) {
        sysRoleService.replaceUsers(id, userIds);
        return R.ok();
    }
}
