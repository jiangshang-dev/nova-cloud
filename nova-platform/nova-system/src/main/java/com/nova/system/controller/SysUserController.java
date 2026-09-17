package com.nova.system.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.nova.core.debounce.annotation.Debounce;
import com.nova.core.result.R;
import com.nova.log.annotation.AutoLog;
import com.nova.security.constants.SecurityConstants;
import com.nova.system.domain.entity.SysUser;
import com.nova.system.service.SysUserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Tag(name = "系统用户")
@RestController
@RequestMapping("/system/user")
@RequiredArgsConstructor
public class SysUserController {

    private final SysUserService sysUserService;

    @AutoLog("用户管理-当前用户信息")
    @Operation(summary = "当前登录用户信息")
    @GetMapping("/info")
    public R<Map<String, Object>> currentUser(@RequestHeader(SecurityConstants.USER_ID_HEADER) Long userId) {
        return R.ok(sysUserService.getUserInfo(userId));
    }

    @AutoLog("用户管理-分页查询")
    @Operation(summary = "用户分页")
    @GetMapping("/page")
    public R<Page<SysUser>> page(@RequestParam(defaultValue = "1") long current,
                                 @RequestParam(defaultValue = "10") long size,
                                 @RequestParam(required = false) String username) {
        return R.ok(sysUserService.page(current, size, username));
    }

    @AutoLog("用户管理-列表查询")
    @Operation(summary = "用户列表（下拉/穿梭）")
    @GetMapping("/list")
    public R<List<SysUser>> list() {
        return R.ok(sysUserService.listSimple());
    }

    @AutoLog("用户管理-详情")
    @Operation(summary = "用户详情")
    @GetMapping("/{id}")
    public R<SysUser> detail(@PathVariable Long id) {
        return R.ok(sysUserService.getById(id));
    }

    @Debounce
    @AutoLog(value = "用户管理-新增", businessType = 1)
    @Operation(summary = "新增用户")
    @PostMapping
    public R<Long> create(@RequestBody SysUser user) {
        return R.ok(sysUserService.create(user));
    }

    @Debounce
    @AutoLog(value = "用户管理-修改", businessType = 2)
    @Operation(summary = "修改用户")
    @PutMapping
    public R<Void> update(@RequestBody SysUser user) {
        sysUserService.update(user);
        return R.ok();
    }

    @Debounce
    @AutoLog(value = "用户管理-删除", businessType = 3)
    @Operation(summary = "删除用户")
    @DeleteMapping("/{id}")
    public R<Void> delete(@PathVariable Long id) {
        sysUserService.delete(id);
        return R.ok();
    }

    @Debounce
    @AutoLog(value = "用户管理-重置密码", businessType = 2)
    @Operation(summary = "修改密码")
    @PutMapping("/{id}/password")
    public R<Void> updatePassword(@PathVariable Long id, @RequestBody PasswordBody body) {
        sysUserService.updatePassword(id, body.getPassword());
        return R.ok();
    }

    @AutoLog("用户管理-查询角色ID")
    @Operation(summary = "用户角色ID列表")
    @GetMapping("/{id}/roleIds")
    public R<List<Long>> roleIds(@PathVariable Long id) {
        return R.ok(sysUserService.getRoleIds(id));
    }

    @Debounce
    @AutoLog(value = "用户管理-分配角色", businessType = 4)
    @Operation(summary = "分配用户角色")
    @PutMapping("/{id}/roles")
    public R<Void> assignRoles(@PathVariable Long id, @RequestBody List<Long> roleIds) {
        sysUserService.replaceRoles(id, roleIds);
        return R.ok();
    }

    @Data
    public static class PasswordBody {
        private String password;
    }
}
