package com.nova.demo.controller;

import com.nova.core.debounce.annotation.Debounce;
import com.nova.core.result.R;
import com.nova.demo.domain.DemoItem;
import com.nova.demo.service.DemoItemService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Tag(name = "Demo 示例")
@RestController
@RequestMapping("/demo/item")
@RequiredArgsConstructor
public class DemoItemController {

    private final DemoItemService demoItemService;

    @Operation(summary = "列表示例")
    @GetMapping("/list")
    public R<List<DemoItem>> list(@RequestParam(required = false) String title) {
        return R.ok(demoItemService.list(title));
    }

    @Operation(summary = "详情示例")
    @GetMapping("/{id}")
    public R<DemoItem> detail(@PathVariable Long id) {
        return R.ok(demoItemService.getById(id));
    }

    @Debounce
    @Operation(summary = "新增示例")
    @PostMapping
    public R<DemoItem> create(@RequestBody DemoItem item) {
        return R.ok(demoItemService.create(item));
    }

    @Debounce
    @Operation(summary = "修改示例")
    @PutMapping("/{id}")
    public R<DemoItem> update(@PathVariable Long id, @RequestBody DemoItem item) {
        item.setId(id);
        return R.ok(demoItemService.update(item));
    }

    @Debounce
    @Operation(summary = "删除示例")
    @DeleteMapping("/{id}")
    public R<Void> delete(@PathVariable Long id) {
        demoItemService.delete(id);
        return R.ok();
    }
}
