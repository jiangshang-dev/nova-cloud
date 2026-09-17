package com.nova.system.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.nova.core.debounce.annotation.Debounce;
import com.nova.core.result.R;
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
    @Operation(summary = "新增角色")
    @PostMapping
    public R<Long> create(@RequestBody SysRole role) {
        return R.ok(sysRoleService.create(role));
    }

    @Debounce
    @Operation(summary = "修改角色")
    @PutMapping
    public R<Void> update(@RequestBody SysRole role) {
        sysRoleService.update(role);
        return R.ok();
    }

    @Debounce
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
    @Operation(summary = "分配角色菜单")
    @PutMapping("/{id}/menus")
    public R<Void> assignMenus(@PathVariable Long id, @RequestBody List<Long> menuIds) {
        sysRoleService.replaceMenus(id, menuIds);
        return R.ok();
    }
}
