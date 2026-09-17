package com.nova.file.service;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.nova.file.api.dto.UploadInitRequest;
import com.nova.file.api.dto.UploadInitResponse;
import com.nova.file.domain.entity.FileInfo;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

/**
 * 文件上传服务。
 */
public interface FileUploadService {

    long DEFAULT_CHUNK_SIZE = 5L * 1024 * 1024;

    UploadInitResponse init(UploadInitRequest request);

    void uploadChunk(String uploadId, int chunkIndex, String chunkMd5, MultipartFile file);

    FileInfo merge(String uploadId);

    List<Integer> progress(String uploadId);

    FileInfo simpleUpload(MultipartFile file, String bizType, String bizId);

    Page<FileInfo> page(long pageNo, long pageSize, String fileName);

    void deleteFile(Long id);

    FileInfo getById(Long id);

    FileInfo getByMd5(String fileMd5);

    boolean existsByMd5(String fileMd5);
}
