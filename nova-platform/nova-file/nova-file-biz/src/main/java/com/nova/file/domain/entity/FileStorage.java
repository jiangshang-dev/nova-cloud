package com.nova.file.domain.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableLogic;
import com.baomidou.mybatisplus.annotation.TableName;
import com.fasterxml.jackson.databind.annotation.JsonSerialize;
import com.fasterxml.jackson.databind.ser.std.ToStringSerializer;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("file_storage")
public class FileStorage {
    @TableId
    @JsonSerialize(using = ToStringSerializer.class)
    private Long id;
    @JsonSerialize(using = ToStringSerializer.class)
    private Long tenantId;
    private String storageCode;
    private String storageName;
    private String storageType;
    private String endpoint;
    private String region;
    private String accessKey;
    private String secretKey;
    private String bucketName;
    private String basePath;
    private String domain;
    private Integer isDefault;
    private Integer status;
    private String extConfig;
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
