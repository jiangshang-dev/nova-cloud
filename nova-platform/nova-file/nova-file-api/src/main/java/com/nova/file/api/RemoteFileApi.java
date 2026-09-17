package com.nova.file.api;

import com.nova.core.result.R;
import com.nova.file.api.constant.FileServiceConstants;
import com.nova.file.api.dto.UploadInitRequest;
import com.nova.file.api.dto.UploadInitResponse;
import com.nova.file.api.dto.UploadMergeRequest;
import com.nova.file.api.vo.FileInfoVO;
import jakarta.validation.Valid;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;

/**
 * 文件服务远程 API（服务间调用，自动携带内部免登 Token）。
 * <p>
 * 调用方引入 {@code nova-file-api}，并 {@code @EnableFeignClients(basePackages = "com.nova.file.api")}。
 */
@FeignClient(contextId = "remoteFileApi", value = FileServiceConstants.SERVICE_NAME, path = FileServiceConstants.INNER_PATH)
public interface RemoteFileApi {

    @GetMapping("/info/{id}")
    R<FileInfoVO> getById(@PathVariable("id") Long id);

    @GetMapping("/info/md5/{fileMd5}")
    R<FileInfoVO> getByMd5(@PathVariable("fileMd5") String fileMd5);

    @PostMapping("/upload/init")
    R<UploadInitResponse> init(@Valid @RequestBody UploadInitRequest request);

    @PostMapping("/upload/merge")
    R<FileInfoVO> merge(@Valid @RequestBody UploadMergeRequest request);

    @DeleteMapping("/info/{id}")
    R<Void> delete(@PathVariable("id") Long id);

    @GetMapping("/upload/chunk-size")
    R<Long> chunkSize();

    @GetMapping("/info/exists")
    R<Boolean> existsByMd5(@RequestParam("fileMd5") String fileMd5);
}
