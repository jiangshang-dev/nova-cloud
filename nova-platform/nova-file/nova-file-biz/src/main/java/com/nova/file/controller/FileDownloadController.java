package com.nova.file.controller;

import com.nova.file.domain.entity.FileInfo;
import com.nova.file.service.FileUploadService;
import com.nova.file.starter.service.NovaFileService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.io.InputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * 按文件库记录 id 下载 / 预览（走后台启用的存储）。
 */
@Tag(name = "文件下载预览")
@RestController
@RequestMapping("/file")
@RequiredArgsConstructor
public class FileDownloadController {

    private final FileUploadService fileUploadService;
    private final NovaFileService novaFileService;

    @Operation(summary = "文件下载（attachment）")
    @GetMapping("/download/{id}")
    public ResponseEntity<InputStreamResource> download(@PathVariable Long id) {
        return buildResponse(id, true);
    }

    @Operation(summary = "文件预览（inline）")
    @GetMapping("/preview/{id}")
    public ResponseEntity<InputStreamResource> preview(@PathVariable Long id) {
        return buildResponse(id, false);
    }

    private ResponseEntity<InputStreamResource> buildResponse(Long id, boolean attachment) {
        FileInfo info = fileUploadService.getById(id);
        InputStream in = novaFileService.getInputStream(info.getObjectKey());
        if (in == null) {
            return ResponseEntity.notFound().build();
        }
        String filename = StringUtils.hasText(info.getFileName()) ? info.getFileName() : String.valueOf(info.getId());
        String encoded = URLEncoder.encode(filename, StandardCharsets.UTF_8).replace("+", "%20");
        String disposition = (attachment ? "attachment" : "inline")
                + "; filename=\"" + filename.replace("\"", "") + "\"; filename*=UTF-8''" + encoded;

        MediaType mediaType = MediaType.APPLICATION_OCTET_STREAM;
        if (StringUtils.hasText(info.getContentType())) {
            try {
                mediaType = MediaType.parseMediaType(info.getContentType());
            } catch (Exception ignored) {
                // keep default
            }
        }

        ResponseEntity.BodyBuilder builder = ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, disposition)
                .contentType(mediaType);
        if (info.getFileSize() != null && info.getFileSize() > 0) {
            builder.contentLength(info.getFileSize());
        }
        return builder.body(new InputStreamResource(in));
    }
}
