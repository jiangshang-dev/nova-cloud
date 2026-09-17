package com.nova.file.controller;

import com.nova.core.result.R;
import com.nova.file.starter.model.FileObjectInfo;
import com.nova.file.starter.service.NovaFileService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

/**
 * 基于管理后台启用存储的对象读写（{@link NovaFileService}）。
 * 后台启用一套存储后，全局上传/下载均走此通道。
 */
@Tag(name = "文件对象读写")
@RestController
@RequestMapping("/file/object")
@RequiredArgsConstructor
public class FileObjectController {

    private final NovaFileService novaFileService;

    @Operation(summary = "上传（Multipart）")
    @PostMapping("/upload")
    public R<FileObjectInfo> upload(@RequestParam("file") MultipartFile file) {
        return R.ok(novaFileService.upload(file));
    }

    @Operation(summary = "批量上传")
    @PostMapping("/upload/batch")
    public R<List<FileObjectInfo>> uploadBatch(@RequestParam("files") MultipartFile[] files) {
        return R.ok(novaFileService.upload(files));
    }

    @Operation(summary = "是否存在")
    @GetMapping("/exist")
    public R<Boolean> exist(@RequestParam String path) {
        return R.ok(novaFileService.exist(path));
    }

    @Operation(summary = "访问地址")
    @GetMapping("/access-url")
    public R<String> accessUrl(@RequestParam String path) {
        return R.ok(novaFileService.getAccessUrl(path));
    }

    @Operation(summary = "读取 Base64")
    @GetMapping("/base64")
    public R<Map<String, String>> base64(@RequestParam String path) {
        return R.ok(Map.of("base64", novaFileService.readBase64(path)));
    }

    @Operation(summary = "下载")
    @GetMapping("/download")
    public ResponseEntity<byte[]> download(@RequestParam String path) {
        return novaFileService.download(path);
    }

    @Operation(summary = "预览")
    @GetMapping("/preview")
    public ResponseEntity<byte[]> preview(@RequestParam String path) {
        return novaFileService.preview(path);
    }

    @Operation(summary = "删除")
    @DeleteMapping
    public R<Void> delete(@RequestParam String path) {
        novaFileService.delete(path);
        return R.ok();
    }
}
