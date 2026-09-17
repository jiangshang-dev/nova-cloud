package com.nova.file.domain.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("file_chunk")
public class FileChunk {
    @TableId
    private Long id;
    private Long tenantId;
    private String uploadId;
    private String fileMd5;
    private Integer chunkIndex;
    private Long chunkSize;
    private String chunkMd5;
    private String objectKey;
    private String etag;
    private Integer status;
    private LocalDateTime gmtCreate;
    private LocalDateTime gmtModified;
}
