-- =========================================================
-- nova-auth：OAuth2.1 客户端 / 授权
-- 规范：阿里巴巴 Java 开发手册 2.0 建表规约（无外键）
-- =========================================================
USE `nova_cloud`;

-- ----------------------------
-- OAuth2 客户端
-- ----------------------------
DROP TABLE IF EXISTS `auth_client`;
CREATE TABLE `auth_client` (
  `id`                            BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`                     BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `client_id`                     VARCHAR(128)    NOT NULL COMMENT '客户端标识',
  `client_secret`                 VARCHAR(256)             DEFAULT NULL COMMENT '客户端密钥密文',
  `client_name`                   VARCHAR(128)    NOT NULL COMMENT '客户端名称',
  `client_authentication_methods` VARCHAR(256)    NOT NULL DEFAULT 'client_secret_basic' COMMENT '认证方式，逗号分隔',
  `authorization_grant_types`     VARCHAR(256)    NOT NULL COMMENT '授权类型，逗号分隔',
  `redirect_uris`                 VARCHAR(2000)            DEFAULT NULL COMMENT '回调地址，逗号分隔',
  `post_logout_redirect_uris`     VARCHAR(2000)            DEFAULT NULL COMMENT '登出回调地址，逗号分隔',
  `scopes`                        VARCHAR(512)    NOT NULL DEFAULT 'openid,profile' COMMENT '授权范围，逗号分隔',
  `is_require_consent`            TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否需要用户确认：0否 1是',
  `access_token_ttl`              INT UNSIGNED    NOT NULL DEFAULT 7200 COMMENT '访问令牌有效期，单位秒',
  `refresh_token_ttl`             INT UNSIGNED    NOT NULL DEFAULT 604800 COMMENT '刷新令牌有效期，单位秒',
  `status`                        TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0停用 1正常',
  `create_by`                     BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`                     BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`                    TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`                        VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`                    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`                  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_client_id` (`client_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='OAuth2客户端表';

-- ----------------------------
-- OAuth2 授权同意
-- ----------------------------
DROP TABLE IF EXISTS `auth_consent`;
CREATE TABLE `auth_consent` (
  `id`                   BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`            BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `registered_client_id` VARCHAR(128)    NOT NULL COMMENT '客户端标识',
  `principal_name`       VARCHAR(128)    NOT NULL COMMENT '主体名称，用户名或用户ID',
  `authorities`          VARCHAR(1000)   NOT NULL COMMENT '已授权范围',
  `gmt_create`           DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`         DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_client_principal` (`registered_client_id`, `principal_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='OAuth2授权同意表';

-- ----------------------------
-- OAuth2 授权记录（生产环境 access/refresh 建议落 Redis）
-- ----------------------------
DROP TABLE IF EXISTS `auth_authorization`;
CREATE TABLE `auth_authorization` (
  `id`                            BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `authorization_id`              VARCHAR(100)    NOT NULL COMMENT '授权业务ID',
  `registered_client_id`          VARCHAR(128)    NOT NULL COMMENT '客户端标识',
  `principal_name`                VARCHAR(200)    NOT NULL COMMENT '主体名称',
  `authorization_grant_type`      VARCHAR(100)    NOT NULL COMMENT '授权类型',
  `authorized_scopes`             VARCHAR(1000)            DEFAULT NULL COMMENT '授权范围',
  `attributes`                    TEXT                     COMMENT '属性JSON',
  `state`                         VARCHAR(500)             DEFAULT NULL COMMENT 'OAuth state',
  `authorization_code_value`      VARCHAR(4000)            DEFAULT NULL COMMENT '授权码值',
  `authorization_code_issued_at`  DATETIME                 DEFAULT NULL COMMENT '授权码签发时间',
  `authorization_code_expires_at` DATETIME                 DEFAULT NULL COMMENT '授权码过期时间',
  `authorization_code_metadata`   TEXT                     COMMENT '授权码元数据',
  `access_token_value`            VARCHAR(4000)            DEFAULT NULL COMMENT '访问令牌值',
  `access_token_issued_at`        DATETIME                 DEFAULT NULL COMMENT '访问令牌签发时间',
  `access_token_expires_at`       DATETIME                 DEFAULT NULL COMMENT '访问令牌过期时间',
  `access_token_metadata`         TEXT                     COMMENT '访问令牌元数据',
  `access_token_type`             VARCHAR(100)             DEFAULT NULL COMMENT '访问令牌类型',
  `access_token_scopes`           VARCHAR(1000)            DEFAULT NULL COMMENT '访问令牌范围',
  `refresh_token_value`           VARCHAR(4000)            DEFAULT NULL COMMENT '刷新令牌值',
  `refresh_token_issued_at`       DATETIME                 DEFAULT NULL COMMENT '刷新令牌签发时间',
  `refresh_token_expires_at`      DATETIME                 DEFAULT NULL COMMENT '刷新令牌过期时间',
  `refresh_token_metadata`        TEXT                     COMMENT '刷新令牌元数据',
  `oidc_id_token_value`           VARCHAR(4000)            DEFAULT NULL COMMENT 'OIDC ID Token值',
  `oidc_id_token_issued_at`       DATETIME                 DEFAULT NULL COMMENT 'OIDC ID Token签发时间',
  `oidc_id_token_expires_at`      DATETIME                 DEFAULT NULL COMMENT 'OIDC ID Token过期时间',
  `oidc_id_token_metadata`        TEXT                     COMMENT 'OIDC ID Token元数据',
  `user_code_value`               VARCHAR(4000)            DEFAULT NULL COMMENT '设备码用户码',
  `user_code_issued_at`           DATETIME                 DEFAULT NULL COMMENT '用户码签发时间',
  `user_code_expires_at`          DATETIME                 DEFAULT NULL COMMENT '用户码过期时间',
  `user_code_metadata`            TEXT                     COMMENT '用户码元数据',
  `device_code_value`             VARCHAR(4000)            DEFAULT NULL COMMENT '设备码值',
  `device_code_issued_at`         DATETIME                 DEFAULT NULL COMMENT '设备码签发时间',
  `device_code_expires_at`        DATETIME                 DEFAULT NULL COMMENT '设备码过期时间',
  `device_code_metadata`          TEXT                     COMMENT '设备码元数据',
  `gmt_create`                    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`                  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_authorization_id` (`authorization_id`),
  KEY `idx_principal_name` (`principal_name`),
  KEY `idx_registered_client_id` (`registered_client_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='OAuth2授权记录表';
