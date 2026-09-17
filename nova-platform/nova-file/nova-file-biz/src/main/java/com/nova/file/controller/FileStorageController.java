package com.nova.file.controller;

import com.nova.core.debounce.annotation.Debounce;
import com.nova.core.result.R;
import com.nova.file.domain.entity.FileStorage;
import com.nova.file.service.FileStorageService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.stream.Collectors;

@Tag(name = "文件存储配置")
@RestController
@RequestMapping("/file/storage")
@RequiredArgsConstructor
public class FileStorageController {

    private final FileStorageService fileStorageService;

    @Operation(summary = "存储配置列表")
    @GetMapping("/list")
    public R<List<FileStorage>> list() {
        List<FileStorage> list = fileStorageService.listAll().stream()
                .map(fileStorageService::maskSecret)
                .collect(Collectors.toList());
        return R.ok(list);
    }

    @Debounce
    @Operation(summary = "新增存储配置")
    @PostMapping
    public R<Long> create(@RequestBody FileStorage storage) {
        return R.ok(fileStorageService.create(storage));
    }

    @Debounce
    @Operation(summary = "更新存储配置")
    @PutMapping("/{id}")
    public R<Void> update(@PathVariable Long id, @RequestBody FileStorage storage) {
        storage.setId(id);
        FileStorage db = fileStorageService.getById(id);
        if (storage.getSecretKey() != null && storage.getSecretKey().contains("*")) {
            storage.setSecretKey(db.getSecretKey());
        }
        if (storage.getAccessKey() != null && storage.getAccessKey().contains("*")) {
            storage.setAccessKey(db.getAccessKey());
        }
        fileStorageService.update(storage);
        return R.ok();
    }

    @Debounce
    @Operation(summary = "删除存储配置")
    @DeleteMapping("/{id}")
    public R<Void> delete(@PathVariable Long id) {
        fileStorageService.delete(id);
        return R.ok();
    }

    @Debounce
    @Operation(summary = "启用（同时关闭其它）")
    @PostMapping("/{id}/enable")
    public R<Void> enable(@PathVariable Long id) {
        fileStorageService.enable(id);
        return R.ok();
    }

    @Debounce
    @Operation(summary = "关闭")
    @PostMapping("/{id}/disable")
    public R<Void> disable(@PathVariable Long id) {
        fileStorageService.disable(id);
        return R.ok();
    }

    @Operation(summary = "连通性测试")
    @PostMapping("/{id}/test")
    public R<Void> test(@PathVariable Long id) {
        fileStorageService.test(id);
        return R.ok();
    }
}
