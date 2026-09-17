package com.nova.system.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.nova.core.debounce.annotation.Debounce;
import com.nova.core.result.R;
import com.nova.log.annotation.AutoLog;
import com.nova.system.domain.entity.SysDictData;
import com.nova.system.domain.entity.SysDictType;
import com.nova.system.service.SysDictService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Tag(name = "系统字典")
@RestController
@RequestMapping("/system/dict")
@RequiredArgsConstructor
public class SysDictController {

    private final SysDictService sysDictService;

    @AutoLog("字典管理-类型分页")
    @Operation(summary = "字典类型分页")
    @GetMapping("/type/page")
    public R<Page<SysDictType>> typePage(@RequestParam(defaultValue = "1") long current,
                                         @RequestParam(defaultValue = "10") long size,
                                         @RequestParam(required = false) String dictName,
                                         @RequestParam(required = false) String dictType) {
        return R.ok(sysDictService.typePage(current, size, dictName, dictType));
    }

    @AutoLog("字典管理-类型列表")
    @Operation(summary = "字典类型列表")
    @GetMapping("/type/list")
    public R<List<SysDictType>> typeList() {
        return R.ok(sysDictService.typeList());
    }

    @Debounce
    @AutoLog(value = "字典管理-新增类型", businessType = 1)
    @Operation(summary = "新增字典类型")
    @PostMapping("/type")
    public R<Long> createType(@RequestBody SysDictType type) {
        return R.ok(sysDictService.createType(type));
    }

    @Debounce
    @AutoLog(value = "字典管理-修改类型", businessType = 2)
    @Operation(summary = "修改字典类型")
    @PutMapping("/type")
    public R<Void> updateType(@RequestBody SysDictType type) {
        sysDictService.updateType(type);
        return R.ok();
    }

    @Debounce
    @AutoLog(value = "字典管理-删除类型", businessType = 3)
    @Operation(summary = "删除字典类型")
    @DeleteMapping("/type/{id}")
    public R<Void> deleteType(@PathVariable Long id) {
        sysDictService.deleteType(id);
        return R.ok();
    }

    @AutoLog("字典管理-数据分页")
    @Operation(summary = "字典数据分页")
    @GetMapping("/data/page")
    public R<Page<SysDictData>> dataPage(@RequestParam(defaultValue = "1") long current,
                                         @RequestParam(defaultValue = "10") long size,
                                         @RequestParam String dictType,
                                         @RequestParam(required = false) String dictLabel) {
        return R.ok(sysDictService.dataPage(current, size, dictType, dictLabel));
    }

    @AutoLog("字典管理-数据列表")
    @Operation(summary = "按类型查询字典数据")
    @GetMapping("/data/list")
    public R<List<SysDictData>> dataList(@RequestParam(required = false) String dictType) {
        return R.ok(sysDictService.dataList(dictType));
    }

    @Debounce
    @AutoLog(value = "字典管理-新增数据", businessType = 1)
    @Operation(summary = "新增字典数据")
    @PostMapping("/data")
    public R<Long> createData(@RequestBody SysDictData data) {
        return R.ok(sysDictService.createData(data));
    }

    @Debounce
    @AutoLog(value = "字典管理-修改数据", businessType = 2)
    @Operation(summary = "修改字典数据")
    @PutMapping("/data")
    public R<Void> updateData(@RequestBody SysDictData data) {
        sysDictService.updateData(data);
        return R.ok();
    }

    @Debounce
    @AutoLog(value = "字典管理-删除数据", businessType = 3)
    @Operation(summary = "删除字典数据")
    @DeleteMapping("/data/{id}")
    public R<Void> deleteData(@PathVariable Long id) {
        sysDictService.deleteData(id);
        return R.ok();
    }

    @AutoLog("字典管理-全部字典项")
    @Operation(summary = "全部字典项（前端缓存）")
    @GetMapping("/all")
    public R<Map<String, List<Map<String, Object>>>> allItems() {
        return R.ok(sysDictService.allItems());
    }
}
