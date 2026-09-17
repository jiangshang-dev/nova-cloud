-- =========================================================
-- NovaCloud PostgreSQL 脚本（由 MySQL 版对照生成）
-- 源文件: sql/03_nova_file.sql
-- PostgreSQL 14+
-- 约定：
-- 1. 表名小写；必备 id / gmt_create / gmt_modified
-- 2. id 为 BIGINT，应用侧雪花 ID（不用 SERIAL）
-- 3. 原 TINYINT UNSIGNED → SMALLINT；BIGINT/INTEGER UNSIGNED → BIGINT/INTEGER
-- 4. DATETIME → TIMESTAMP；无 ON UPDATE（由应用更新 gmt_modified）
-- 5. 禁止外键；注释使用 COMMENT ON
-- =========================================================

-- 请先连接到 nova_cloud

-- =========================================================
-- nova-file：对象存储配置 / 文件元数据 / 分片上传
-- 规范：阿里巴巴 Java 开发手册 2.0 建表规约（无外键）
-- =========================================================
-- ----------------------------
-- 存储配置
-- ----------------------------

DROP TABLE IF EXISTS file_storage CASCADE;
CREATE TABLE file_storage (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  storage_code    VARCHAR(64)     NOT NULL,
  storage_name    VARCHAR(128)    NOT NULL,
  storage_type    VARCHAR(32)     NOT NULL,
  endpoint        VARCHAR(255)             DEFAULT NULL,
  region          VARCHAR(64)              DEFAULT NULL,
  access_key      VARCHAR(128)             DEFAULT NULL,
  secret_key      VARCHAR(256)             DEFAULT NULL,
  bucket_name     VARCHAR(128)             DEFAULT NULL,
  base_path       VARCHAR(255)             DEFAULT NULL,
  domain          VARCHAR(255)             DEFAULT NULL,
  is_default      SMALLINT NOT NULL DEFAULT 0,
  status          SMALLINT NOT NULL DEFAULT 1,
  ext_config      JSON                     DEFAULT NULL,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_file_storage PRIMARY KEY (id),
  CONSTRAINT uk_tenant_storage_code UNIQUE (tenant_id, storage_code)
);
COMMENT ON TABLE file_storage IS '文件存储配置表';
COMMENT ON COLUMN file_storage.id IS '主键';
COMMENT ON COLUMN file_storage.tenant_id IS '租户ID，0表示全局';
COMMENT ON COLUMN file_storage.storage_code IS '存储编码';
COMMENT ON COLUMN file_storage.storage_name IS '存储名称';
COMMENT ON COLUMN file_storage.storage_type IS '类型：local/minio/rustfs/oss/s3';
COMMENT ON COLUMN file_storage.endpoint IS '服务端点';
COMMENT ON COLUMN file_storage.region IS '区域';
COMMENT ON COLUMN file_storage.access_key IS '访问密钥，建议加密存储';
COMMENT ON COLUMN file_storage.secret_key IS '私有密钥，建议加密存储';
COMMENT ON COLUMN file_storage.bucket_name IS '桶名';
COMMENT ON COLUMN file_storage.base_path IS '基础路径前缀';
COMMENT ON COLUMN file_storage.domain IS '访问域名';
COMMENT ON COLUMN file_storage.is_default IS '是否默认：0否 1是';
COMMENT ON COLUMN file_storage.status IS '状态：0停用 1正常';
COMMENT ON COLUMN file_storage.ext_config IS '扩展配置JSON';
COMMENT ON COLUMN file_storage.create_by IS '创建人';
COMMENT ON COLUMN file_storage.update_by IS '修改人';
COMMENT ON COLUMN file_storage.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN file_storage.remark IS '备注';
COMMENT ON COLUMN file_storage.gmt_create IS '创建时间';
COMMENT ON COLUMN file_storage.gmt_modified IS '修改时间';

-- ----------------------------
-- 文件元数据
-- ----------------------------

DROP TABLE IF EXISTS file_info CASCADE;
CREATE TABLE file_info (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  storage_id      BIGINT          DEFAULT NULL,
  file_name       VARCHAR(255)    NOT NULL,
  file_suffix     VARCHAR(32)              DEFAULT NULL,
  content_type    VARCHAR(128)             DEFAULT NULL,
  file_size       BIGINT NOT NULL DEFAULT 0,
  file_md5        CHAR(32)                 DEFAULT NULL,
  file_sha256     CHAR(64)                 DEFAULT NULL,
  bucket_name     VARCHAR(128)             DEFAULT NULL,
  object_key      VARCHAR(512)    NOT NULL,
  access_url      VARCHAR(1000)            DEFAULT NULL,
  biz_type        VARCHAR(64)              DEFAULT NULL,
  biz_id          VARCHAR(64)              DEFAULT NULL,
  upload_id       VARCHAR(128)             DEFAULT NULL,
  upload_status   SMALLINT NOT NULL DEFAULT 1,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_file_info PRIMARY KEY (id)
);
COMMENT ON TABLE file_info IS '文件信息表';
COMMENT ON COLUMN file_info.id IS '主键';
COMMENT ON COLUMN file_info.tenant_id IS '租户ID';
COMMENT ON COLUMN file_info.storage_id IS '存储配置ID';
COMMENT ON COLUMN file_info.file_name IS '原始文件名';
COMMENT ON COLUMN file_info.file_suffix IS '文件后缀，如pdf';
COMMENT ON COLUMN file_info.content_type IS 'MIME类型';
COMMENT ON COLUMN file_info.file_size IS '文件大小，单位字节';
COMMENT ON COLUMN file_info.file_md5 IS '文件MD5，用于秒传';
COMMENT ON COLUMN file_info.file_sha256 IS '文件SHA256';
COMMENT ON COLUMN file_info.bucket_name IS '桶名';
COMMENT ON COLUMN file_info.object_key IS '对象键或相对路径';
COMMENT ON COLUMN file_info.access_url IS '访问URL';
COMMENT ON COLUMN file_info.biz_type IS '业务类型：avatar/knowledge/doc';
COMMENT ON COLUMN file_info.biz_id IS '业务ID';
COMMENT ON COLUMN file_info.upload_id IS '分片上传会话ID';
COMMENT ON COLUMN file_info.upload_status IS '上传状态：0上传中 1完成 2失败';
COMMENT ON COLUMN file_info.create_by IS '创建人';
COMMENT ON COLUMN file_info.update_by IS '修改人';
COMMENT ON COLUMN file_info.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN file_info.remark IS '备注';
COMMENT ON COLUMN file_info.gmt_create IS '创建时间';
COMMENT ON COLUMN file_info.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_tenant_md5 ON file_info (tenant_id, file_md5);
CREATE INDEX IF NOT EXISTS idx_tenant_biz ON file_info (tenant_id, biz_type, biz_id);
CREATE INDEX IF NOT EXISTS idx_object_key ON file_info (object_key);

-- ----------------------------
-- 分片上传明细
-- ----------------------------

DROP TABLE IF EXISTS file_chunk CASCADE;
CREATE TABLE file_chunk (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  upload_id       VARCHAR(128)    NOT NULL,
  file_md5        CHAR(32)        NOT NULL,
  chunk_index     INTEGER    NOT NULL,
  chunk_size      BIGINT NOT NULL DEFAULT 0,
  chunk_md5       CHAR(32)                 DEFAULT NULL,
  object_key      VARCHAR(512)             DEFAULT NULL,
  etag            VARCHAR(128)             DEFAULT NULL,
  status          SMALLINT NOT NULL DEFAULT 0,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_file_chunk PRIMARY KEY (id),
  CONSTRAINT uk_upload_chunk UNIQUE (upload_id, chunk_index)
);
COMMENT ON TABLE file_chunk IS '文件分片表';
COMMENT ON COLUMN file_chunk.id IS '主键';
COMMENT ON COLUMN file_chunk.tenant_id IS '租户ID';
COMMENT ON COLUMN file_chunk.upload_id IS '分片上传会话ID';
COMMENT ON COLUMN file_chunk.file_md5 IS '整体文件MD5';
COMMENT ON COLUMN file_chunk.chunk_index IS '分片序号，从0开始';
COMMENT ON COLUMN file_chunk.chunk_size IS '分片大小，单位字节';
COMMENT ON COLUMN file_chunk.chunk_md5 IS '分片MD5';
COMMENT ON COLUMN file_chunk.object_key IS '临时对象键';
COMMENT ON COLUMN file_chunk.etag IS '对象存储返回ETag';
COMMENT ON COLUMN file_chunk.status IS '状态：0待上传 1已上传';
COMMENT ON COLUMN file_chunk.gmt_create IS '创建时间';
COMMENT ON COLUMN file_chunk.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_file_md5 ON file_chunk (file_md5);
