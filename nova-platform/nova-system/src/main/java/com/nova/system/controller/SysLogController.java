package com.nova.system.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.nova.core.debounce.annotation.Debounce;
import com.nova.core.result.R;
import com.nova.log.annotation.AutoLog;
import com.nova.system.domain.entity.SysLoginLog;
import com.nova.system.domain.entity.SysOperLog;
import com.nova.system.service.SysLogService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@Tag(name = "系统日志")
@RestController
@RequestMapping("/system/log")
@RequiredArgsConstructor
public class SysLogController {

    private final SysLogService sysLogService;

    @AutoLog("日志管理-操作日志分页")
    @Operation(summary = "操作日志分页")
    @GetMapping("/oper/page")
    public R<Page<SysOperLog>> operPage(@RequestParam(defaultValue = "1") long current,
                                        @RequestParam(defaultValue = "10") long size,
                                        @RequestParam(required = false) String operName,
                                        @RequestParam(required = false) String title,
                                        @RequestParam(required = false) Integer status) {
        return R.ok(sysLogService.operPage(current, size, operName, title, status));
    }

    @Debounce
    @AutoLog(value = "日志管理-删除操作日志", businessType = 3)
    @Operation(summary = "删除操作日志")
    @DeleteMapping("/oper/{id}")
    public R<Void> deleteOper(@PathVariable Long id) {
        sysLogService.deleteOper(id);
        return R.ok();
    }

    @Debounce
    @AutoLog(value = "日志管理-清空操作日志", businessType = 3)
    @Operation(summary = "清空操作日志")
    @DeleteMapping("/oper/clear")
    public R<Void> clearOper() {
        sysLogService.clearOper();
        return R.ok();
    }

    @AutoLog("日志管理-登录日志分页")
    @Operation(summary = "登录日志分页")
    @GetMapping("/login/page")
    public R<Page<SysLoginLog>> loginPage(@RequestParam(defaultValue = "1") long current,
                                         @RequestParam(defaultValue = "10") long size,
                                         @RequestParam(required = false) String username,
                                         @RequestParam(required = false) Integer status) {
        return R.ok(sysLogService.loginPage(current, size, username, status));
    }

    @Debounce
    @AutoLog(value = "日志管理-删除登录日志", businessType = 3)
    @Operation(summary = "删除登录日志")
    @DeleteMapping("/login/{id}")
    public R<Void> deleteLogin(@PathVariable Long id) {
        sysLogService.deleteLogin(id);
        return R.ok();
    }

    @Debounce
    @AutoLog(value = "日志管理-清空登录日志", businessType = 3)
    @Operation(summary = "清空登录日志")
    @DeleteMapping("/login/clear")
    public R<Void> clearLogin() {
        sysLogService.clearLogin();
        return R.ok();
    }
}
