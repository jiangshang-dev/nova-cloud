package com.nova.file.starter.model;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 文件对象信息（本地 / S3 统一返回）。
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FileObjectInfo {

    /** 原始文件名 */
    private String fileName;
    /** 存储相对路径 / objectKey（后续 exist / read 用此 path） */
    private String filePath;
    /** 字节大小 */
    private Long fileSize;
    /** 访问 URL */
    private String accessUrl;
    /** Content-Type */
    private String contentType;
}
