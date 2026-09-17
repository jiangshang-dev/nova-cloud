package com.nova.file.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.nova.core.debounce.annotation.Debounce;
import com.nova.core.result.R;
import com.nova.file.api.dto.UploadInitRequest;
import com.nova.file.api.dto.UploadInitResponse;
import com.nova.file.api.dto.UploadMergeRequest;
import com.nova.file.domain.entity.FileInfo;
import com.nova.file.service.FileUploadService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@Tag(name = "文件上传")
@RestController
@RequestMapping("/file")
@RequiredArgsConstructor
public class FileUploadController {

    private final FileUploadService fileUploadService;

    @Operation(summary = "初始化分片上传 / 秒传 / 断点查询")
    @PostMapping("/upload/init")
    public R<UploadInitResponse> init(@Valid @RequestBody UploadInitRequest request) {
        return R.ok(fileUploadService.init(request));
    }

    @Operation(summary = "上传分片")
    @PostMapping("/upload/chunk")
    public R<Void> chunk(@RequestParam String uploadId,
                         @RequestParam Integer chunkIndex,
                         @RequestParam(required = false) String chunkMd5,
                         @RequestParam("file") MultipartFile file) {
        fileUploadService.uploadChunk(uploadId, chunkIndex, chunkMd5, file);
        return R.ok();
    }

    @Operation(summary = "查询已上传分片")
    @GetMapping("/upload/progress/{uploadId}")
    public R<List<Integer>> progress(@PathVariable String uploadId) {
        return R.ok(fileUploadService.progress(uploadId));
    }

    @Debounce
    @Operation(summary = "合并分片")
    @PostMapping("/upload/merge")
    public R<FileInfo> merge(@Valid @RequestBody UploadMergeRequest request) {
        return R.ok(fileUploadService.merge(request.getUploadId()));
    }

    @Debounce
    @Operation(summary = "小文件直接上传")
    @PostMapping("/upload")
    public R<FileInfo> upload(@RequestParam("file") MultipartFile file,
                              @RequestParam(required = false) String bizType,
                              @RequestParam(required = false) String bizId) {
        return R.ok(fileUploadService.simpleUpload(file, bizType, bizId));
    }

    @Operation(summary = "文件分页")
    @GetMapping("/info/page")
    public R<Page<FileInfo>> page(@RequestParam(defaultValue = "1") long pageNo,
                                  @RequestParam(defaultValue = "10") long pageSize,
                                  @RequestParam(required = false) String fileName) {
        return R.ok(fileUploadService.page(pageNo, pageSize, fileName));
    }

    @Debounce
    @Operation(summary = "删除文件")
    @DeleteMapping("/info/{id}")
    public R<Void> delete(@PathVariable Long id) {
        fileUploadService.deleteFile(id);
        return R.ok();
    }

    @Operation(summary = "默认分片大小")
    @GetMapping("/upload/chunk-size")
    public R<Map<String, Long>> chunkSize() {
        return R.ok(Map.of("chunkSize", FileUploadService.DEFAULT_CHUNK_SIZE));
    }
}
