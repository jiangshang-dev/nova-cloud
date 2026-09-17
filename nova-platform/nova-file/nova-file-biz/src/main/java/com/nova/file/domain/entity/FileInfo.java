package com.nova.file.domain.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("file_info")
public class FileInfo {
    @TableId
    @JsonSerialize(using = ToStringSerializer.class)
    private Long id;
    @JsonSerialize(using = ToStringSerializer.class)
    private Long tenantId;
    @JsonSerialize(using = ToStringSerializer.class)
    private Long storageId;
    private String fileName;
    private String fileSuffix;
    private String contentType;
    private Long fileSize;
    private String fileMd5;
    private String fileSha256;
    private String bucketName;
    private String objectKey;
    private String accessUrl;
    private String bizType;
    private String bizId;
    private String uploadId;
    private Integer uploadStatus;
    @JsonSerialize(using = ToStringSerializer.class)
    private Long createBy;
    @JsonSerialize(using = ToStringSerializer.class)
    private Long updateBy;
    @TableLogic
    private Integer isDeleted;
    private String remark;
    private LocalDateTime gmtCreate;
    private LocalDateTime gmtModified;
}
