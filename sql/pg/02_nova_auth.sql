-- =========================================================
-- NovaCloud PostgreSQL 脚本（由 MySQL 版对照生成）
-- 源文件: sql/02_nova_auth.sql
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
-- nova-auth：OAuth2.1 客户端 / 授权
-- 规范：阿里巴巴 Java 开发手册 2.0 建表规约（无外键）
-- =========================================================
-- ----------------------------
-- OAuth2 客户端
-- ----------------------------

DROP TABLE IF EXISTS auth_client CASCADE;
CREATE TABLE auth_client (
  id                            BIGINT NOT NULL,
  tenant_id                     BIGINT NOT NULL DEFAULT 0,
  client_id                     VARCHAR(128)    NOT NULL,
  client_secret                 VARCHAR(256)             DEFAULT NULL,
  client_name                   VARCHAR(128)    NOT NULL,
  client_authentication_methods VARCHAR(256)    NOT NULL DEFAULT 'client_secret_basic',
  authorization_grant_types     VARCHAR(256)    NOT NULL,
  redirect_uris                 VARCHAR(2000)            DEFAULT NULL,
  post_logout_redirect_uris     VARCHAR(2000)            DEFAULT NULL,
  scopes                        VARCHAR(512)    NOT NULL DEFAULT 'openid,profile',
  is_require_consent            SMALLINT NOT NULL DEFAULT 0,
  access_token_ttl              INTEGER    NOT NULL DEFAULT 7200,
  refresh_token_ttl             INTEGER    NOT NULL DEFAULT 604800,
  status                        SMALLINT NOT NULL DEFAULT 1,
  create_by                     BIGINT          DEFAULT NULL,
  update_by                     BIGINT          DEFAULT NULL,
  is_deleted                    SMALLINT NOT NULL DEFAULT 0,
  remark                        VARCHAR(500)             DEFAULT NULL,
  gmt_create                    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified                  TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_auth_client PRIMARY KEY (id),
  CONSTRAINT uk_client_id UNIQUE (client_id)
);
COMMENT ON TABLE auth_client IS 'OAuth2客户端表';
COMMENT ON COLUMN auth_client.id IS '主键';
COMMENT ON COLUMN auth_client.tenant_id IS '租户ID';
COMMENT ON COLUMN auth_client.client_id IS '客户端标识';
COMMENT ON COLUMN auth_client.client_secret IS '客户端密钥密文';
COMMENT ON COLUMN auth_client.client_name IS '客户端名称';
COMMENT ON COLUMN auth_client.client_authentication_methods IS '认证方式，逗号分隔';
COMMENT ON COLUMN auth_client.authorization_grant_types IS '授权类型，逗号分隔';
COMMENT ON COLUMN auth_client.redirect_uris IS '回调地址，逗号分隔';
COMMENT ON COLUMN auth_client.post_logout_redirect_uris IS '登出回调地址，逗号分隔';
COMMENT ON COLUMN auth_client.scopes IS '授权范围，逗号分隔';
COMMENT ON COLUMN auth_client.is_require_consent IS '是否需要用户确认：0否 1是';
COMMENT ON COLUMN auth_client.access_token_ttl IS '访问令牌有效期，单位秒';
COMMENT ON COLUMN auth_client.refresh_token_ttl IS '刷新令牌有效期，单位秒';
COMMENT ON COLUMN auth_client.status IS '状态：0停用 1正常';
COMMENT ON COLUMN auth_client.create_by IS '创建人';
COMMENT ON COLUMN auth_client.update_by IS '修改人';
COMMENT ON COLUMN auth_client.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN auth_client.remark IS '备注';
COMMENT ON COLUMN auth_client.gmt_create IS '创建时间';
COMMENT ON COLUMN auth_client.gmt_modified IS '修改时间';

-- ----------------------------
-- OAuth2 授权同意
-- ----------------------------

DROP TABLE IF EXISTS auth_consent CASCADE;
CREATE TABLE auth_consent (
  id                   BIGINT NOT NULL,
  tenant_id            BIGINT NOT NULL DEFAULT 0,
  registered_client_id VARCHAR(128)    NOT NULL,
  principal_name       VARCHAR(128)    NOT NULL,
  authorities          VARCHAR(1000)   NOT NULL,
  gmt_create           TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified         TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_auth_consent PRIMARY KEY (id),
  CONSTRAINT uk_client_principal UNIQUE (registered_client_id, principal_name)
);
COMMENT ON TABLE auth_consent IS 'OAuth2授权同意表';
COMMENT ON COLUMN auth_consent.id IS '主键';
COMMENT ON COLUMN auth_consent.tenant_id IS '租户ID';
COMMENT ON COLUMN auth_consent.registered_client_id IS '客户端标识';
COMMENT ON COLUMN auth_consent.principal_name IS '主体名称，用户名或用户ID';
COMMENT ON COLUMN auth_consent.authorities IS '已授权范围';
COMMENT ON COLUMN auth_consent.gmt_create IS '创建时间';
COMMENT ON COLUMN auth_consent.gmt_modified IS '修改时间';

-- ----------------------------
-- OAuth2 授权记录（生产环境 access/refresh 建议落 Redis）
-- ----------------------------

DROP TABLE IF EXISTS auth_authorization CASCADE;
CREATE TABLE auth_authorization (
  id                            BIGINT NOT NULL,
  authorization_id              VARCHAR(100)    NOT NULL,
  registered_client_id          VARCHAR(128)    NOT NULL,
  principal_name                VARCHAR(200)    NOT NULL,
  authorization_grant_type      VARCHAR(100)    NOT NULL,
  authorized_scopes             VARCHAR(1000)            DEFAULT NULL,
  attributes                    TEXT,
  state                         VARCHAR(500)             DEFAULT NULL,
  authorization_code_value      VARCHAR(4000)            DEFAULT NULL,
  authorization_code_issued_at  TIMESTAMP                 DEFAULT NULL,
  authorization_code_expires_at TIMESTAMP                 DEFAULT NULL,
  authorization_code_metadata   TEXT,
  access_token_value            VARCHAR(4000)            DEFAULT NULL,
  access_token_issued_at        TIMESTAMP                 DEFAULT NULL,
  access_token_expires_at       TIMESTAMP                 DEFAULT NULL,
  access_token_metadata         TEXT,
  access_token_type             VARCHAR(100)             DEFAULT NULL,
  access_token_scopes           VARCHAR(1000)            DEFAULT NULL,
  refresh_token_value           VARCHAR(4000)            DEFAULT NULL,
  refresh_token_issued_at       TIMESTAMP                 DEFAULT NULL,
  refresh_token_expires_at      TIMESTAMP                 DEFAULT NULL,
  refresh_token_metadata        TEXT,
  oidc_id_token_value           VARCHAR(4000)            DEFAULT NULL,
  oidc_id_token_issued_at       TIMESTAMP                 DEFAULT NULL,
  oidc_id_token_expires_at      TIMESTAMP                 DEFAULT NULL,
  oidc_id_token_metadata        TEXT,
  user_code_value               VARCHAR(4000)            DEFAULT NULL,
  user_code_issued_at           TIMESTAMP                 DEFAULT NULL,
  user_code_expires_at          TIMESTAMP                 DEFAULT NULL,
  user_code_metadata            TEXT,
  device_code_value             VARCHAR(4000)            DEFAULT NULL,
  device_code_issued_at         TIMESTAMP                 DEFAULT NULL,
  device_code_expires_at        TIMESTAMP                 DEFAULT NULL,
  device_code_metadata          TEXT,
  gmt_create                    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified                  TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_auth_authorization PRIMARY KEY (id),
  CONSTRAINT uk_authorization_id UNIQUE (authorization_id)
);
COMMENT ON TABLE auth_authorization IS 'OAuth2授权记录表';
COMMENT ON COLUMN auth_authorization.id IS '主键';
COMMENT ON COLUMN auth_authorization.authorization_id IS '授权业务ID';
COMMENT ON COLUMN auth_authorization.registered_client_id IS '客户端标识';
COMMENT ON COLUMN auth_authorization.principal_name IS '主体名称';
COMMENT ON COLUMN auth_authorization.authorization_grant_type IS '授权类型';
COMMENT ON COLUMN auth_authorization.authorized_scopes IS '授权范围';
COMMENT ON COLUMN auth_authorization.attributes IS '属性JSON';
COMMENT ON COLUMN auth_authorization.state IS 'OAuth state';
COMMENT ON COLUMN auth_authorization.authorization_code_value IS '授权码值';
COMMENT ON COLUMN auth_authorization.authorization_code_issued_at IS '授权码签发时间';
COMMENT ON COLUMN auth_authorization.authorization_code_expires_at IS '授权码过期时间';
COMMENT ON COLUMN auth_authorization.authorization_code_metadata IS '授权码元数据';
COMMENT ON COLUMN auth_authorization.access_token_value IS '访问令牌值';
COMMENT ON COLUMN auth_authorization.access_token_issued_at IS '访问令牌签发时间';
COMMENT ON COLUMN auth_authorization.access_token_expires_at IS '访问令牌过期时间';
COMMENT ON COLUMN auth_authorization.access_token_metadata IS '访问令牌元数据';
COMMENT ON COLUMN auth_authorization.access_token_type IS '访问令牌类型';
COMMENT ON COLUMN auth_authorization.access_token_scopes IS '访问令牌范围';
COMMENT ON COLUMN auth_authorization.refresh_token_value IS '刷新令牌值';
COMMENT ON COLUMN auth_authorization.refresh_token_issued_at IS '刷新令牌签发时间';
COMMENT ON COLUMN auth_authorization.refresh_token_expires_at IS '刷新令牌过期时间';
COMMENT ON COLUMN auth_authorization.refresh_token_metadata IS '刷新令牌元数据';
COMMENT ON COLUMN auth_authorization.oidc_id_token_value IS 'OIDC ID Token值';
COMMENT ON COLUMN auth_authorization.oidc_id_token_issued_at IS 'OIDC ID Token签发时间';
COMMENT ON COLUMN auth_authorization.oidc_id_token_expires_at IS 'OIDC ID Token过期时间';
COMMENT ON COLUMN auth_authorization.oidc_id_token_metadata IS 'OIDC ID Token元数据';
COMMENT ON COLUMN auth_authorization.user_code_value IS '设备码用户码';
COMMENT ON COLUMN auth_authorization.user_code_issued_at IS '用户码签发时间';
COMMENT ON COLUMN auth_authorization.user_code_expires_at IS '用户码过期时间';
COMMENT ON COLUMN auth_authorization.user_code_metadata IS '用户码元数据';
COMMENT ON COLUMN auth_authorization.device_code_value IS '设备码值';
COMMENT ON COLUMN auth_authorization.device_code_issued_at IS '设备码签发时间';
COMMENT ON COLUMN auth_authorization.device_code_expires_at IS '设备码过期时间';
COMMENT ON COLUMN auth_authorization.device_code_metadata IS '设备码元数据';
COMMENT ON COLUMN auth_authorization.gmt_create IS '创建时间';
COMMENT ON COLUMN auth_authorization.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_principal_name ON auth_authorization (principal_name);
CREATE INDEX IF NOT EXISTS idx_registered_client_id ON auth_authorization (registered_client_id);
