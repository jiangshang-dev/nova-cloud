package com.nova.system.controller;

import com.nova.core.debounce.annotation.Debounce;
import com.nova.core.result.R;
import com.nova.log.annotation.AutoLog;
import com.nova.system.domain.entity.SysDept;
import com.nova.system.domain.vo.DeptTreeVo;
import com.nova.system.service.SysDeptService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "系统部门")
@RestController
@RequestMapping("/system/dept")
@RequiredArgsConstructor
public class SysDeptController {

    private final SysDeptService sysDeptService;

    @AutoLog("部门管理-部门树")
    @Operation(summary = "部门树")
    @GetMapping("/tree")
    public R<List<DeptTreeVo>> tree(@RequestParam(required = false) String deptName) {
        return R.ok(sysDeptService.tree(deptName));
    }

    @AutoLog("部门管理-列表查询")
    @Operation(summary = "部门列表")
    @GetMapping("/list")
    public R<List<SysDept>> list(@RequestParam(required = false) String deptName) {
        return R.ok(sysDeptService.list(deptName));
    }

    @AutoLog("部门管理-详情")
    @Operation(summary = "部门详情")
    @GetMapping("/{id}")
    public R<SysDept> detail(@PathVariable Long id) {
        return R.ok(sysDeptService.getById(id));
    }

    @Debounce
    @AutoLog(value = "部门管理-新增", businessType = 1)
    @Operation(summary = "新增部门")
    @PostMapping
    public R<Long> create(@RequestBody SysDept dept) {
        return R.ok(sysDeptService.create(dept));
    }

    @Debounce
    @AutoLog(value = "部门管理-修改", businessType = 2)
    @Operation(summary = "修改部门")
    @PutMapping
    public R<Void> update(@RequestBody SysDept dept) {
        sysDeptService.update(dept);
        return R.ok();
    }

    @Debounce
    @AutoLog(value = "部门管理-删除", businessType = 3)
    @Operation(summary = "删除部门")
    @DeleteMapping("/{id}")
    public R<Void> delete(@PathVariable Long id) {
        sysDeptService.delete(id);
        return R.ok();
    }
}
