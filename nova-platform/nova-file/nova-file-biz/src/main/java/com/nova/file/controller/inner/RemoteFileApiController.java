package com.nova.file.controller.inner;

import com.nova.core.result.R;
import com.nova.file.api.RemoteFileApi;
import com.nova.file.api.constant.FileServiceConstants;
import com.nova.file.api.dto.UploadInitRequest;
import com.nova.file.api.dto.UploadInitResponse;
import com.nova.file.api.dto.UploadMergeRequest;
import com.nova.file.api.vo.FileInfoVO;
import com.nova.file.domain.entity.FileInfo;
import com.nova.file.service.FileUploadService;
import io.swagger.v3.oas.annotations.Hidden;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * 内部 Feign 入口：实现 {@link RemoteFileApi}，仅接受携带内部 Token 的服务间调用。
 */
@Hidden
@RestController
@RequestMapping(FileServiceConstants.INNER_PATH)
@RequiredArgsConstructor
public class RemoteFileApiController implements RemoteFileApi {

    private final FileUploadService fileUploadService;

    @Override
    public R<FileInfoVO> getById(Long id) {
        return R.ok(toVo(fileUploadService.getById(id)));
    }

    @Override
    public R<FileInfoVO> getByMd5(String fileMd5) {
        FileInfo info = fileUploadService.getByMd5(fileMd5);
        return R.ok(info == null ? null : toVo(info));
    }

    @Override
    public R<UploadInitResponse> init(@Valid UploadInitRequest request) {
        return R.ok(fileUploadService.init(request));
    }

    @Override
    public R<FileInfoVO> merge(@Valid UploadMergeRequest request) {
        return R.ok(toVo(fileUploadService.merge(request.getUploadId())));
    }

    @Override
    public R<Void> delete(Long id) {
        fileUploadService.deleteFile(id);
        return R.ok();
    }

    @Override
    public R<Long> chunkSize() {
        return R.ok(FileUploadService.DEFAULT_CHUNK_SIZE);
    }

    @Override
    public R<Boolean> existsByMd5(String fileMd5) {
        return R.ok(fileUploadService.existsByMd5(fileMd5));
    }

    private static FileInfoVO toVo(FileInfo info) {
        FileInfoVO vo = new FileInfoVO();
        BeanUtils.copyProperties(info, vo);
        return vo;
    }
}
