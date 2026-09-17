-- =========================================================
-- nova-file：对象存储配置 / 文件元数据 / 分片上传
-- 规范：阿里巴巴 Java 开发手册 2.0 建表规约（无外键）
-- =========================================================
USE `nova_cloud`;

-- ----------------------------
-- 存储配置
-- ----------------------------
DROP TABLE IF EXISTS `file_storage`;
CREATE TABLE `file_storage` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID，0表示全局',
  `storage_code`    VARCHAR(64)     NOT NULL COMMENT '存储编码',
  `storage_name`    VARCHAR(128)    NOT NULL COMMENT '存储名称',
  `storage_type`    VARCHAR(32)     NOT NULL COMMENT '类型：local/minio/oss/cos/s3',
  `endpoint`        VARCHAR(255)             DEFAULT NULL COMMENT '服务端点',
  `region`          VARCHAR(64)              DEFAULT NULL COMMENT '区域',
  `access_key`      VARCHAR(128)             DEFAULT NULL COMMENT '访问密钥，建议加密存储',
  `secret_key`      VARCHAR(256)             DEFAULT NULL COMMENT '私有密钥，建议加密存储',
  `bucket_name`     VARCHAR(128)             DEFAULT NULL COMMENT '桶名',
  `base_path`       VARCHAR(255)             DEFAULT NULL COMMENT '基础路径前缀',
  `domain`          VARCHAR(255)             DEFAULT NULL COMMENT '访问域名',
  `is_default`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否默认：0否 1是',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0停用 1正常',
  `ext_config`      JSON                     DEFAULT NULL COMMENT '扩展配置JSON',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_storage_code` (`tenant_id`, `storage_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='文件存储配置表';

-- ----------------------------
-- 文件元数据
-- ----------------------------
DROP TABLE IF EXISTS `file_info`;
CREATE TABLE `file_info` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `storage_id`      BIGINT UNSIGNED          DEFAULT NULL COMMENT '存储配置ID',
  `file_name`       VARCHAR(255)    NOT NULL COMMENT '原始文件名',
  `file_suffix`     VARCHAR(32)              DEFAULT NULL COMMENT '文件后缀，如pdf',
  `content_type`    VARCHAR(128)             DEFAULT NULL COMMENT 'MIME类型',
  `file_size`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '文件大小，单位字节',
  `file_md5`        CHAR(32)                 DEFAULT NULL COMMENT '文件MD5，用于秒传',
  `file_sha256`     CHAR(64)                 DEFAULT NULL COMMENT '文件SHA256',
  `bucket_name`     VARCHAR(128)             DEFAULT NULL COMMENT '桶名',
  `object_key`      VARCHAR(512)    NOT NULL COMMENT '对象键或相对路径',
  `access_url`      VARCHAR(1000)            DEFAULT NULL COMMENT '访问URL',
  `biz_type`        VARCHAR(64)              DEFAULT NULL COMMENT '业务类型：avatar/knowledge/doc',
  `biz_id`          VARCHAR(64)              DEFAULT NULL COMMENT '业务ID',
  `upload_id`       VARCHAR(128)             DEFAULT NULL COMMENT '分片上传会话ID',
  `upload_status`   TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '上传状态：0上传中 1完成 2失败',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  KEY `idx_tenant_md5` (`tenant_id`, `file_md5`),
  KEY `idx_tenant_biz` (`tenant_id`, `biz_type`, `biz_id`),
  KEY `idx_object_key` (`object_key`(191))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='文件信息表';

-- ----------------------------
-- 分片上传明细
-- ----------------------------
DROP TABLE IF EXISTS `file_chunk`;
CREATE TABLE `file_chunk` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `upload_id`       VARCHAR(128)    NOT NULL COMMENT '分片上传会话ID',
  `file_md5`        CHAR(32)        NOT NULL COMMENT '整体文件MD5',
  `chunk_index`     INT UNSIGNED    NOT NULL COMMENT '分片序号，从0开始',
  `chunk_size`      BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '分片大小，单位字节',
  `chunk_md5`       CHAR(32)                 DEFAULT NULL COMMENT '分片MD5',
  `object_key`      VARCHAR(512)             DEFAULT NULL COMMENT '临时对象键',
  `etag`            VARCHAR(128)             DEFAULT NULL COMMENT '对象存储返回ETag',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0待上传 1已上传',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_upload_chunk` (`upload_id`, `chunk_index`),
  KEY `idx_file_md5` (`file_md5`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='文件分片表';
