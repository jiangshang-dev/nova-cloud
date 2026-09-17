-- ==================== 00_init_database.sql ====================
-- =========================================================
-- NovaCloud 框架库初始化
-- MySQL 8.0+ / InnoDB / utf8mb4
-- 建表规范：阿里巴巴 Java 开发手册（华山版/2.0）MySQL 规约
-- =========================================================
-- 强制约定：
-- 1. 表名小写 + 下划线，禁止复数；业务前缀_作用（如 sys_user）
-- 2. 表必备三字段：id / gmt_create / gmt_modified
-- 3. id：BIGINT UNSIGNED；分布式场景由应用生成雪花 ID（不使用库自增）
-- 4. 是/否字段：is_xxx + TINYINT UNSIGNED（1是 0否）
-- 5. 非负数字段使用 UNSIGNED
-- 6. 索引：主键默认；唯一 uk_；普通 idx_
-- 7. 禁止外键；字符集 utf8mb4；引擎 InnoDB
-- 8. 表与字段必须有 COMMENT；varchar 不超过 5000，超长独立 TEXT 表或 MEDIUMTEXT
-- =========================================================

CREATE DATABASE IF NOT EXISTS `nova_cloud`
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_general_ci;

USE `nova_cloud`;

-- ==================== 01_nova_system.sql ====================
-- =========================================================
-- nova-system：租户 / 组织 / 用户 / RBAC / 字典 / 参数 / 通知
-- 规范：阿里巴巴 Java 开发手册 2.0 建表规约（无外键）
-- =========================================================
USE `nova_cloud`;

-- ----------------------------
-- 租户
-- ----------------------------
DROP TABLE IF EXISTS `sys_tenant`;
CREATE TABLE `sys_tenant` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_code`     VARCHAR(64)     NOT NULL COMMENT '租户编码',
  `tenant_name`     VARCHAR(128)    NOT NULL COMMENT '租户名称',
  `contact_name`    VARCHAR(64)              DEFAULT NULL COMMENT '联系人',
  `contact_phone`   VARCHAR(32)              DEFAULT NULL COMMENT '联系电话',
  `contact_email`   VARCHAR(128)             DEFAULT NULL COMMENT '联系邮箱',
  `expire_time`     DATETIME                 DEFAULT NULL COMMENT '到期时间，空表示永久',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0停用 1正常',
  `package_id`      BIGINT UNSIGNED          DEFAULT NULL COMMENT '套餐ID，预留',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_code` (`tenant_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='租户表';

-- ----------------------------
-- 部门
-- ----------------------------
DROP TABLE IF EXISTS `sys_dept`;
CREATE TABLE `sys_dept` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID，0表示平台',
  `parent_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '父部门ID，0表示根',
  `ancestors`       VARCHAR(512)    NOT NULL DEFAULT '' COMMENT '祖级列表，如0,100,101',
  `dept_name`       VARCHAR(64)     NOT NULL COMMENT '部门名称',
  `dept_code`       VARCHAR(64)              DEFAULT NULL COMMENT '部门编码',
  `sort`            INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT '显示顺序',
  `leader_id`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '负责人用户ID',
  `phone`           VARCHAR(32)              DEFAULT NULL COMMENT '联系电话',
  `email`           VARCHAR(128)             DEFAULT NULL COMMENT '邮箱',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0停用 1正常',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  KEY `idx_tenant_parent` (`tenant_id`, `parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='部门表';

-- ----------------------------
-- 岗位
-- ----------------------------
DROP TABLE IF EXISTS `sys_post`;
CREATE TABLE `sys_post` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `post_code`       VARCHAR(64)     NOT NULL COMMENT '岗位编码',
  `post_name`       VARCHAR(64)     NOT NULL COMMENT '岗位名称',
  `sort`            INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT '显示顺序',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0停用 1正常',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_post_code` (`tenant_id`, `post_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='岗位表';

-- ----------------------------
-- 用户
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `dept_id`         BIGINT UNSIGNED          DEFAULT NULL COMMENT '主部门ID',
  `username`        VARCHAR(64)     NOT NULL COMMENT '登录账号',
  `password`        VARCHAR(128)    NOT NULL COMMENT '密码密文',
  `nickname`        VARCHAR(64)              DEFAULT NULL COMMENT '昵称',
  `real_name`       VARCHAR(64)              DEFAULT NULL COMMENT '真实姓名',
  `email`           VARCHAR(128)             DEFAULT NULL COMMENT '邮箱',
  `phone`           VARCHAR(32)              DEFAULT NULL COMMENT '手机号',
  `sex`             TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '性别：0未知 1男 2女',
  `avatar`          VARCHAR(512)             DEFAULT NULL COMMENT '头像URL',
  `user_type`       TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '用户类型：1普通 2管理员 9超级管理员',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0停用 1正常',
  `login_ip`        VARCHAR(64)              DEFAULT NULL COMMENT '最后登录IP',
  `login_time`      DATETIME                 DEFAULT NULL COMMENT '最后登录时间',
  `pwd_update_time` DATETIME                 DEFAULT NULL COMMENT '密码最后修改时间',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_username` (`tenant_id`, `username`),
  KEY `idx_phone` (`phone`),
  KEY `idx_dept_id` (`dept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户表';

-- ----------------------------
-- 角色
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `role_code`       VARCHAR(64)     NOT NULL COMMENT '角色编码',
  `role_name`       VARCHAR(64)     NOT NULL COMMENT '角色名称',
  `data_scope`      TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '数据范围：1全部 2自定义 3本部门 4本部门及以下 5仅本人',
  `sort`            INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT '显示顺序',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0停用 1正常',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_role_code` (`tenant_id`, `role_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='角色表';

-- ----------------------------
-- 菜单权限
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `parent_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '父菜单ID，0表示根',
  `menu_name`       VARCHAR(64)     NOT NULL COMMENT '菜单名称',
  `menu_type`       CHAR(1)         NOT NULL COMMENT '类型：M目录 C菜单 F按钮',
  `path`            VARCHAR(255)             DEFAULT NULL COMMENT '路由地址',
  `component`       VARCHAR(255)             DEFAULT NULL COMMENT '组件路径',
  `permission`      VARCHAR(128)             DEFAULT NULL COMMENT '权限标识，如system:user:list',
  `icon`            VARCHAR(128)             DEFAULT NULL COMMENT '菜单图标',
  `sort`            INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT '显示顺序',
  `is_visible`      TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '是否可见：0否 1是',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0停用 1正常',
  `is_frame`        TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否外链：0否 1是',
  `is_cache`        TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否缓存：0否 1是',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  KEY `idx_parent_id` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='菜单权限表';

-- ----------------------------
-- 用户角色关联
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `user_id`         BIGINT UNSIGNED NOT NULL COMMENT '用户ID',
  `role_id`         BIGINT UNSIGNED NOT NULL COMMENT '角色ID',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_role` (`user_id`, `role_id`),
  KEY `idx_role_id` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户角色关联表';

-- ----------------------------
-- 角色菜单关联
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_menu`;
CREATE TABLE `sys_role_menu` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `role_id`         BIGINT UNSIGNED NOT NULL COMMENT '角色ID',
  `menu_id`         BIGINT UNSIGNED NOT NULL COMMENT '菜单ID',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_menu` (`role_id`, `menu_id`),
  KEY `idx_menu_id` (`menu_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='角色菜单关联表';

-- ----------------------------
-- 用户岗位关联
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_post`;
CREATE TABLE `sys_user_post` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `user_id`         BIGINT UNSIGNED NOT NULL COMMENT '用户ID',
  `post_id`         BIGINT UNSIGNED NOT NULL COMMENT '岗位ID',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_post` (`user_id`, `post_id`),
  KEY `idx_post_id` (`post_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='用户岗位关联表';

-- ----------------------------
-- 角色部门关联（自定义数据权限）
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_dept`;
CREATE TABLE `sys_role_dept` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `role_id`         BIGINT UNSIGNED NOT NULL COMMENT '角色ID',
  `dept_id`         BIGINT UNSIGNED NOT NULL COMMENT '部门ID',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_role_dept` (`role_id`, `dept_id`),
  KEY `idx_dept_id` (`dept_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='角色部门关联表';

-- ----------------------------
-- 字典类型
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_type`;
CREATE TABLE `sys_dict_type` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID，0表示全局',
  `dict_name`       VARCHAR(100)    NOT NULL COMMENT '字典名称',
  `dict_type`       VARCHAR(100)    NOT NULL COMMENT '字典类型',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0停用 1正常',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_dict_type` (`tenant_id`, `dict_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='字典类型表';

-- ----------------------------
-- 字典数据
-- ----------------------------
DROP TABLE IF EXISTS `sys_dict_data`;
CREATE TABLE `sys_dict_data` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID，0表示全局',
  `dict_type`       VARCHAR(100)    NOT NULL COMMENT '字典类型',
  `dict_label`      VARCHAR(100)    NOT NULL COMMENT '字典标签',
  `dict_value`      VARCHAR(100)    NOT NULL COMMENT '字典键值',
  `css_class`       VARCHAR(100)             DEFAULT NULL COMMENT '样式属性',
  `list_class`      VARCHAR(100)             DEFAULT NULL COMMENT '表格回显样式',
  `sort`            INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT '显示顺序',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0停用 1正常',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  KEY `idx_tenant_dict_type` (`tenant_id`, `dict_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='字典数据表';

-- ----------------------------
-- 参数配置
-- ----------------------------
DROP TABLE IF EXISTS `sys_config`;
CREATE TABLE `sys_config` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID，0表示全局',
  `config_name`     VARCHAR(100)    NOT NULL COMMENT '参数名称',
  `config_key`      VARCHAR(100)    NOT NULL COMMENT '参数键名',
  `config_value`    VARCHAR(2000)            DEFAULT NULL COMMENT '参数键值',
  `is_system`       TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否系统内置：0否 1是',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_config_key` (`tenant_id`, `config_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='参数配置表';

-- ----------------------------
-- 通知公告
-- ----------------------------
DROP TABLE IF EXISTS `sys_notice`;
CREATE TABLE `sys_notice` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `notice_title`    VARCHAR(128)    NOT NULL COMMENT '公告标题',
  `notice_type`     TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '类型：1通知 2公告',
  `notice_content`  MEDIUMTEXT               COMMENT '公告内容',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0关闭 1正常',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  KEY `idx_tenant_id` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='通知公告表';

-- ==================== 02_nova_auth.sql ====================
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
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
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
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
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
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_authorization_id` (`authorization_id`),
  KEY `idx_principal_name` (`principal_name`),
  KEY `idx_registered_client_id` (`registered_client_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='OAuth2授权记录表';

-- ==================== 03_nova_file.sql ====================
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
  `storage_type`    VARCHAR(32)     NOT NULL COMMENT '类型：local/minio/rustfs/oss/s3',
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
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
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
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
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
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_upload_chunk` (`upload_id`, `chunk_index`),
  KEY `idx_file_md5` (`file_md5`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='文件分片表';

-- ==================== 04_nova_log.sql ====================
-- =========================================================
-- nova-common-log：登录 / 操作 / 审计日志
-- 规范：阿里巴巴 Java 开发手册 2.0 建表规约（无外键）
-- =========================================================
USE `nova_cloud`;

-- ----------------------------
-- 登录日志
-- ----------------------------
DROP TABLE IF EXISTS `log_login`;
CREATE TABLE `log_login` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `user_id`         BIGINT UNSIGNED          DEFAULT NULL COMMENT '用户ID',
  `username`        VARCHAR(64)              DEFAULT NULL COMMENT '用户账号',
  `login_type`      VARCHAR(32)     NOT NULL DEFAULT 'password' COMMENT '登录方式：password/sms/oauth2',
  `client_id`       VARCHAR(128)             DEFAULT NULL COMMENT '客户端标识',
  `ip`              VARCHAR(64)              DEFAULT NULL COMMENT '登录IP',
  `location`        VARCHAR(255)             DEFAULT NULL COMMENT '登录地点',
  `browser`         VARCHAR(128)             DEFAULT NULL COMMENT '浏览器',
  `os`              VARCHAR(128)             DEFAULT NULL COMMENT '操作系统',
  `user_agent`      VARCHAR(512)             DEFAULT NULL COMMENT 'User-Agent',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0失败 1成功',
  `msg`             VARCHAR(500)             DEFAULT NULL COMMENT '提示消息',
  `login_time`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '登录时间',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  KEY `idx_tenant_username` (`tenant_id`, `username`),
  KEY `idx_login_time` (`login_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='登录日志表';

-- ----------------------------
-- 操作日志
-- ----------------------------
DROP TABLE IF EXISTS `log_operation`;
CREATE TABLE `log_operation` (
  `id`               BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`        BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `trace_id`         VARCHAR(64)              DEFAULT NULL COMMENT '链路追踪ID',
  `user_id`          BIGINT UNSIGNED          DEFAULT NULL COMMENT '操作用户ID',
  `username`         VARCHAR(64)              DEFAULT NULL COMMENT '操作用户名',
  `module`           VARCHAR(64)              DEFAULT NULL COMMENT '模块名',
  `business_type`    TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '业务类型：0其它 1新增 2修改 3删除 4授权 5导出 6导入',
  `method`           VARCHAR(255)             DEFAULT NULL COMMENT '方法名',
  `request_method`   VARCHAR(16)              DEFAULT NULL COMMENT '请求方式',
  `operator_type`    TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '操作类别：1后台用户 2手机端 3其它',
  `request_url`      VARCHAR(512)             DEFAULT NULL COMMENT '请求URL',
  `request_ip`       VARCHAR(64)              DEFAULT NULL COMMENT '主机地址',
  `request_location` VARCHAR(255)             DEFAULT NULL COMMENT '操作地点',
  `request_param`    TEXT                     COMMENT '请求参数',
  `response_result`  TEXT                     COMMENT '返回结果',
  `status`           TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0异常 1正常',
  `error_msg`        TEXT                     COMMENT '错误消息',
  `cost_time`        BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '耗时，单位毫秒',
  `operate_time`     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '操作时间',
  `gmt_create`       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  KEY `idx_tenant_user` (`tenant_id`, `user_id`),
  KEY `idx_operate_time` (`operate_time`),
  KEY `idx_trace_id` (`trace_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='操作日志表';

-- ----------------------------
-- 审计日志
-- ----------------------------
DROP TABLE IF EXISTS `log_audit`;
CREATE TABLE `log_audit` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `user_id`         BIGINT UNSIGNED          DEFAULT NULL COMMENT '操作人ID',
  `username`        VARCHAR(64)              DEFAULT NULL COMMENT '操作人账号',
  `audit_type`      VARCHAR(64)     NOT NULL COMMENT '审计类型：role_change/perm_change/crypto/config',
  `biz_type`        VARCHAR(64)              DEFAULT NULL COMMENT '业务对象类型',
  `biz_id`          VARCHAR(64)              DEFAULT NULL COMMENT '业务对象ID',
  `action`          VARCHAR(64)     NOT NULL COMMENT '动作',
  `before_data`     JSON                     DEFAULT NULL COMMENT '变更前数据',
  `after_data`      JSON                     DEFAULT NULL COMMENT '变更后数据',
  `ip`              VARCHAR(64)              DEFAULT NULL COMMENT 'IP地址',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  KEY `idx_tenant_biz` (`tenant_id`, `biz_type`, `biz_id`),
  KEY `idx_gmt_create` (`gmt_create`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='审计日志表';

-- ==================== 05_nova_ai.sql ====================
-- =========================================================
-- AI 平台：模型 / Agent / 知识库 / RAG / 工作流 / 媒体任务
-- 规范：阿里巴巴 Java 开发手册 2.0 建表规约（无外键）
-- =========================================================
USE `nova_cloud`;

-- ----------------------------
-- 模型提供商
-- ----------------------------
DROP TABLE IF EXISTS `ai_model_provider`;
CREATE TABLE `ai_model_provider` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID，0表示平台',
  `provider_code`   VARCHAR(64)     NOT NULL COMMENT '提供商编码：dashscope/openai/anthropic/ollama',
  `provider_name`   VARCHAR(128)    NOT NULL COMMENT '提供商名称',
  `base_url`        VARCHAR(255)             DEFAULT NULL COMMENT '自定义Endpoint',
  `api_key_cipher`  VARCHAR(512)             DEFAULT NULL COMMENT 'API Key密文',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0停用 1正常',
  `ext_config`      JSON                     DEFAULT NULL COMMENT '扩展配置JSON',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_provider_code` (`tenant_id`, `provider_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='AI模型提供商表';

-- ----------------------------
-- 模型定义
-- ----------------------------
DROP TABLE IF EXISTS `ai_model`;
CREATE TABLE `ai_model` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `provider_id`     BIGINT UNSIGNED NOT NULL COMMENT '提供商ID',
  `model_code`      VARCHAR(128)    NOT NULL COMMENT '模型编码，如dashscope:qwen-plus',
  `model_name`      VARCHAR(128)    NOT NULL COMMENT '模型显示名',
  `model_type`      VARCHAR(32)     NOT NULL DEFAULT 'chat' COMMENT '类型：chat/embedding/image/video/rerank',
  `context_window`  INT UNSIGNED             DEFAULT NULL COMMENT '上下文窗口',
  `max_tokens`      INT UNSIGNED             DEFAULT NULL COMMENT '默认最大输出token',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0停用 1正常',
  `ext_config`      JSON                     DEFAULT NULL COMMENT '默认参数JSON',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_model_code` (`tenant_id`, `model_code`),
  KEY `idx_provider_id` (`provider_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='AI模型定义表';

-- ----------------------------
-- Agent 定义
-- ----------------------------
DROP TABLE IF EXISTS `ai_agent`;
CREATE TABLE `ai_agent` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `agent_code`      VARCHAR(64)     NOT NULL COMMENT 'Agent编码',
  `agent_name`      VARCHAR(128)    NOT NULL COMMENT 'Agent名称',
  `model_id`        BIGINT UNSIGNED          DEFAULT NULL COMMENT '默认模型ID',
  `sys_prompt`      MEDIUMTEXT               COMMENT '系统提示词',
  `workspace_path`  VARCHAR(512)             DEFAULT NULL COMMENT '工作区路径',
  `compaction_json` JSON                     DEFAULT NULL COMMENT '压缩策略配置JSON',
  `tools_json`      JSON                     DEFAULT NULL COMMENT '工具声明JSON',
  `skills_json`     JSON                     DEFAULT NULL COMMENT '技能配置JSON',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0停用 1正常',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_agent_code` (`tenant_id`, `agent_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='AI Agent定义表';

-- ----------------------------
-- Agent 会话
-- ----------------------------
DROP TABLE IF EXISTS `ai_agent_session`;
CREATE TABLE `ai_agent_session` (
  `id`                BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`         BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `agent_id`          BIGINT UNSIGNED NOT NULL COMMENT 'AgentID',
  `session_id`        VARCHAR(128)    NOT NULL COMMENT '会话业务ID',
  `user_id`           BIGINT UNSIGNED          DEFAULT NULL COMMENT '业务用户ID',
  `title`             VARCHAR(255)             DEFAULT NULL COMMENT '会话标题',
  `status`            TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0关闭 1进行中',
  `last_message_time` DATETIME                 DEFAULT NULL COMMENT '最后消息时间',
  `ext_json`          JSON                     DEFAULT NULL COMMENT '扩展信息JSON',
  `create_by`         BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`         BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`        TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `gmt_create`        DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_agent_session` (`tenant_id`, `agent_id`, `session_id`),
  KEY `idx_tenant_user` (`tenant_id`, `user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='AI Agent会话表';

-- ----------------------------
-- Agent 消息
-- ----------------------------
DROP TABLE IF EXISTS `ai_agent_message`;
CREATE TABLE `ai_agent_message` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `session_pk`      BIGINT UNSIGNED NOT NULL COMMENT '会话表主键',
  `role`            VARCHAR(32)     NOT NULL COMMENT '角色：user/assistant/system/tool',
  `content`         MEDIUMTEXT               COMMENT '消息内容',
  `content_blocks`  JSON                     DEFAULT NULL COMMENT '多模态或工具调用块JSON',
  `token_usage`     JSON                     DEFAULT NULL COMMENT 'token统计JSON',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  KEY `idx_session_create` (`session_pk`, `gmt_create`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='AI Agent消息表';

-- ----------------------------
-- 知识库
-- ----------------------------
DROP TABLE IF EXISTS `ai_knowledge_base`;
CREATE TABLE `ai_knowledge_base` (
  `id`                 BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`          BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `kb_code`            VARCHAR(64)     NOT NULL COMMENT '知识库编码',
  `kb_name`            VARCHAR(128)    NOT NULL COMMENT '知识库名称',
  `embedding_model_id` BIGINT UNSIGNED          DEFAULT NULL COMMENT '向量模型ID',
  `index_name`         VARCHAR(128)             DEFAULT NULL COMMENT '检索索引名',
  `chunk_size`         INT UNSIGNED    NOT NULL DEFAULT 500 COMMENT '默认分片大小',
  `chunk_overlap`      INT UNSIGNED    NOT NULL DEFAULT 50 COMMENT '分片重叠长度',
  `status`             TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0停用 1正常',
  `create_by`          BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`          BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`         TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`             VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`         DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_kb_code` (`tenant_id`, `kb_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='知识库表';

-- ----------------------------
-- 知识库文档
-- ----------------------------
DROP TABLE IF EXISTS `ai_knowledge_doc`;
CREATE TABLE `ai_knowledge_doc` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `kb_id`           BIGINT UNSIGNED NOT NULL COMMENT '知识库ID',
  `file_id`         BIGINT UNSIGNED          DEFAULT NULL COMMENT '文件ID',
  `doc_name`        VARCHAR(255)    NOT NULL COMMENT '文档名',
  `doc_type`        VARCHAR(32)              DEFAULT NULL COMMENT '类型：pdf/md/docx/html/url',
  `source_url`      VARCHAR(1000)            DEFAULT NULL COMMENT '来源URL',
  `parse_status`    TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '解析状态：0待处理 1处理中 2成功 3失败',
  `chunk_count`     INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT '分片数',
  `error_msg`       VARCHAR(1000)            DEFAULT NULL COMMENT '失败原因',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  KEY `idx_kb_id` (`kb_id`),
  KEY `idx_parse_status` (`parse_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='知识库文档表';

-- ----------------------------
-- 知识库分片
-- ----------------------------
DROP TABLE IF EXISTS `ai_knowledge_chunk`;
CREATE TABLE `ai_knowledge_chunk` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `kb_id`           BIGINT UNSIGNED NOT NULL COMMENT '知识库ID',
  `doc_id`          BIGINT UNSIGNED NOT NULL COMMENT '文档ID',
  `chunk_index`     INT UNSIGNED    NOT NULL DEFAULT 0 COMMENT '分片序号',
  `content`         MEDIUMTEXT      NOT NULL COMMENT '分片文本',
  `token_count`     INT UNSIGNED             DEFAULT NULL COMMENT 'token数',
  `vector_id`       VARCHAR(128)             DEFAULT NULL COMMENT '向量库文档ID',
  `metadata_json`   JSON                     DEFAULT NULL COMMENT '元数据JSON',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  KEY `idx_doc_chunk` (`doc_id`, `chunk_index`),
  KEY `idx_kb_id` (`kb_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='知识库分片表';

-- ----------------------------
-- RAG 问答日志
-- ----------------------------
DROP TABLE IF EXISTS `ai_rag_query_log`;
CREATE TABLE `ai_rag_query_log` (
  `id`               BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`        BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `kb_id`            BIGINT UNSIGNED          DEFAULT NULL COMMENT '知识库ID',
  `user_id`          BIGINT UNSIGNED          DEFAULT NULL COMMENT '用户ID',
  `question`         TEXT            NOT NULL COMMENT '问题',
  `answer`           MEDIUMTEXT               COMMENT '回答',
  `retrieved_chunks` JSON                     DEFAULT NULL COMMENT '召回分片JSON',
  `model_code`       VARCHAR(128)             DEFAULT NULL COMMENT '使用模型编码',
  `latency_ms`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '耗时，单位毫秒',
  `gmt_create`       DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`     DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  KEY `idx_kb_create` (`kb_id`, `gmt_create`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='RAG问答日志表';

-- ----------------------------
-- 工作流定义
-- ----------------------------
DROP TABLE IF EXISTS `ai_workflow`;
CREATE TABLE `ai_workflow` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `workflow_code`   VARCHAR(64)     NOT NULL COMMENT '工作流编码',
  `workflow_name`   VARCHAR(128)    NOT NULL COMMENT '工作流名称',
  `version`         INT UNSIGNED    NOT NULL DEFAULT 1 COMMENT '版本号',
  `graph_json`      JSON                     DEFAULT NULL COMMENT '画布完整JSON',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0草稿 1已发布 2停用',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_workflow_ver` (`tenant_id`, `workflow_code`, `version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='AI工作流定义表';

-- ----------------------------
-- 工作流节点
-- ----------------------------
DROP TABLE IF EXISTS `ai_workflow_node`;
CREATE TABLE `ai_workflow_node` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `workflow_id`     BIGINT UNSIGNED NOT NULL COMMENT '工作流ID',
  `node_key`        VARCHAR(64)     NOT NULL COMMENT '节点唯一键',
  `node_type`       VARCHAR(64)     NOT NULL COMMENT '类型：start/llm/agent/rag/tool/condition/end',
  `node_name`       VARCHAR(128)             DEFAULT NULL COMMENT '节点名称',
  `config_json`     JSON                     DEFAULT NULL COMMENT '节点配置JSON',
  `position_x`      INT                      DEFAULT NULL COMMENT '画布X坐标',
  `position_y`      INT                      DEFAULT NULL COMMENT '画布Y坐标',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_workflow_node` (`workflow_id`, `node_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='AI工作流节点表';

-- ----------------------------
-- 工作流连线
-- ----------------------------
DROP TABLE IF EXISTS `ai_workflow_edge`;
CREATE TABLE `ai_workflow_edge` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `workflow_id`     BIGINT UNSIGNED NOT NULL COMMENT '工作流ID',
  `edge_key`        VARCHAR(64)     NOT NULL COMMENT '边唯一键',
  `source_node_key` VARCHAR(64)     NOT NULL COMMENT '源节点键',
  `target_node_key` VARCHAR(64)     NOT NULL COMMENT '目标节点键',
  `condition_expr`  VARCHAR(512)             DEFAULT NULL COMMENT '条件表达式',
  `config_json`     JSON                     DEFAULT NULL COMMENT '扩展配置JSON',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_workflow_edge` (`workflow_id`, `edge_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='AI工作流连线表';

-- ----------------------------
-- 工作流运行记录
-- ----------------------------
DROP TABLE IF EXISTS `ai_workflow_run`;
CREATE TABLE `ai_workflow_run` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `workflow_id`     BIGINT UNSIGNED NOT NULL COMMENT '工作流ID',
  `run_no`          VARCHAR(64)     NOT NULL COMMENT '运行编号',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0排队 1运行中 2成功 3失败 4取消',
  `input_json`      JSON                     DEFAULT NULL COMMENT '输入JSON',
  `output_json`     JSON                     DEFAULT NULL COMMENT '输出JSON',
  `error_msg`       VARCHAR(2000)            DEFAULT NULL COMMENT '错误信息',
  `start_time`      DATETIME                 DEFAULT NULL COMMENT '开始时间',
  `end_time`        DATETIME                 DEFAULT NULL COMMENT '结束时间',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_run_no` (`run_no`),
  KEY `idx_workflow_create` (`workflow_id`, `gmt_create`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='AI工作流运行记录表';

-- ----------------------------
-- 媒体生成任务
-- ----------------------------
DROP TABLE IF EXISTS `ai_media_task`;
CREATE TABLE `ai_media_task` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `task_no`         VARCHAR(64)     NOT NULL COMMENT '任务编号',
  `media_type`      VARCHAR(32)     NOT NULL COMMENT '类型：image/video/doc',
  `model_code`      VARCHAR(128)             DEFAULT NULL COMMENT '模型编码',
  `prompt`          TEXT                     COMMENT '提示词',
  `params_json`     JSON                     DEFAULT NULL COMMENT '生成参数JSON',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0排队 1处理中 2成功 3失败',
  `result_file_ids` VARCHAR(1000)            DEFAULT NULL COMMENT '结果文件ID，逗号分隔',
  `result_urls`     TEXT                     COMMENT '结果URL',
  `error_msg`       VARCHAR(2000)            DEFAULT NULL COMMENT '错误信息',
  `mq_msg_id`       VARCHAR(128)             DEFAULT NULL COMMENT 'MQ消息ID',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_task_no` (`task_no`),
  KEY `idx_tenant_status_create` (`tenant_id`, `status`, `gmt_create`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='AI媒体生成任务表';

-- ==================== 06_nova_platform.sql ====================
-- =========================================================
-- nova-search / nova-job / nova-monitor 业务辅助表
-- 说明：XXL-JOB / Nacos / SkyWalking 自带库表不在此重复
-- 规范：阿里巴巴 Java 开发手册 2.0 建表规约（无外键）
-- =========================================================
USE `nova_cloud`;

-- ----------------------------
-- 搜索索引元数据
-- ----------------------------
DROP TABLE IF EXISTS `search_index_meta`;
CREATE TABLE `search_index_meta` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `index_code`      VARCHAR(64)     NOT NULL COMMENT '业务索引编码',
  `index_name`      VARCHAR(128)    NOT NULL COMMENT 'ES索引名',
  `index_alias`     VARCHAR(128)             DEFAULT NULL COMMENT '索引别名',
  `mapping_json`    JSON                     DEFAULT NULL COMMENT 'mapping定义JSON',
  `settings_json`   JSON                     DEFAULT NULL COMMENT 'settings定义JSON',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0停用 1正常',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_index_code` (`tenant_id`, `index_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='搜索索引元数据表';

-- ----------------------------
-- 搜索同步任务
-- ----------------------------
DROP TABLE IF EXISTS `search_sync_task`;
CREATE TABLE `search_sync_task` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `index_id`        BIGINT UNSIGNED NOT NULL COMMENT '索引元数据ID',
  `task_no`         VARCHAR(64)     NOT NULL COMMENT '任务编号',
  `sync_type`       VARCHAR(32)     NOT NULL DEFAULT 'full' COMMENT '类型：full/incr',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0待执行 1执行中 2成功 3失败',
  `total_count`     BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '总条数',
  `success_count`   BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '成功条数',
  `fail_count`      BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '失败条数',
  `error_msg`       VARCHAR(2000)            DEFAULT NULL COMMENT '错误信息',
  `start_time`      DATETIME                 DEFAULT NULL COMMENT '开始时间',
  `end_time`        DATETIME                 DEFAULT NULL COMMENT '结束时间',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_task_no` (`task_no`),
  KEY `idx_index_create` (`index_id`, `gmt_create`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='搜索同步任务表';

-- ----------------------------
-- 业务任务定义
-- ----------------------------
DROP TABLE IF EXISTS `job_definition`;
CREATE TABLE `job_definition` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `job_code`        VARCHAR(64)     NOT NULL COMMENT '任务编码',
  `job_name`        VARCHAR(128)    NOT NULL COMMENT '任务名称',
  `xxl_job_id`      INT UNSIGNED             DEFAULT NULL COMMENT 'XXL-JOB任务ID',
  `cron_expr`       VARCHAR(128)             DEFAULT NULL COMMENT 'Cron表达式',
  `handler`         VARCHAR(128)    NOT NULL COMMENT '执行器Handler',
  `param_json`      JSON                     DEFAULT NULL COMMENT '默认参数JSON',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0停用 1正常',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_job_code` (`tenant_id`, `job_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='业务任务定义表';

-- ----------------------------
-- 业务任务执行日志
-- ----------------------------
DROP TABLE IF EXISTS `job_exec_log`;
CREATE TABLE `job_exec_log` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `job_id`          BIGINT UNSIGNED NOT NULL COMMENT '任务定义ID',
  `xxl_log_id`      BIGINT UNSIGNED          DEFAULT NULL COMMENT 'XXL-JOB日志ID',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0执行中 1成功 2失败',
  `trigger_time`    DATETIME                 DEFAULT NULL COMMENT '触发时间',
  `finish_time`     DATETIME                 DEFAULT NULL COMMENT '完成时间',
  `cost_ms`         BIGINT UNSIGNED          DEFAULT NULL COMMENT '耗时，单位毫秒',
  `result_msg`      VARCHAR(2000)            DEFAULT NULL COMMENT '结果摘要',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  KEY `idx_job_create` (`job_id`, `gmt_create`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='业务任务执行日志表';

-- ----------------------------
-- 监控告警规则
-- ----------------------------
DROP TABLE IF EXISTS `monitor_alert_rule`;
CREATE TABLE `monitor_alert_rule` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `rule_code`       VARCHAR(64)     NOT NULL COMMENT '规则编码',
  `rule_name`       VARCHAR(128)    NOT NULL COMMENT '规则名称',
  `metric_expr`     VARCHAR(1000)   NOT NULL COMMENT '指标表达式或PromQL',
  `severity`        VARCHAR(16)     NOT NULL DEFAULT 'critical' COMMENT '级别：info/warn/critical',
  `notify_channel`  VARCHAR(255)             DEFAULT NULL COMMENT '通知渠道：mail,dingtalk,webhook',
  `notify_targets`  VARCHAR(1000)            DEFAULT NULL COMMENT '通知目标',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 1 COMMENT '状态：0停用 1正常',
  `create_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '创建人',
  `update_by`       BIGINT UNSIGNED          DEFAULT NULL COMMENT '修改人',
  `is_deleted`      TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '是否删除：0否 1是',
  `remark`          VARCHAR(500)             DEFAULT NULL COMMENT '备注',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  UNIQUE KEY `uk_tenant_rule_code` (`tenant_id`, `rule_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='监控告警规则表';

-- ----------------------------
-- 监控告警记录
-- ----------------------------
DROP TABLE IF EXISTS `monitor_alert_record`;
CREATE TABLE `monitor_alert_record` (
  `id`              BIGINT UNSIGNED NOT NULL COMMENT '主键',
  `tenant_id`       BIGINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '租户ID',
  `rule_id`         BIGINT UNSIGNED NOT NULL COMMENT '规则ID',
  `alert_title`     VARCHAR(255)    NOT NULL COMMENT '告警标题',
  `alert_content`   TEXT                     COMMENT '告警内容',
  `severity`        VARCHAR(16)     NOT NULL DEFAULT 'critical' COMMENT '级别：info/warn/critical',
  `status`          TINYINT UNSIGNED NOT NULL DEFAULT 0 COMMENT '状态：0待处理 1已确认 2已关闭',
  `fired_time`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '触发时间',
  `resolved_time`   DATETIME                 DEFAULT NULL COMMENT '恢复时间',
  `gmt_create`      DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `gmt_modified`    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改时间',
  CONSTRAINT `pk_id` PRIMARY KEY (`id`),
  KEY `idx_rule_fired` (`rule_id`, `fired_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='监控告警记录表';

-- ==================== 99_init_data.sql ====================
-- =========================================================
-- NovaCloud 初始化数据（开发环境）
-- 默认账号：admin / admin123
-- =========================================================
USE `nova_cloud`;

-- 平台租户
INSERT INTO `sys_tenant`
(`id`, `tenant_code`, `tenant_name`, `contact_name`, `status`, `is_deleted`, `remark`)
VALUES
(1, 'platform', '平台租户', 'admin', 1, 0, '系统默认租户');

-- 根部门
INSERT INTO `sys_dept`
(`id`, `tenant_id`, `parent_id`, `ancestors`, `dept_name`, `dept_code`, `sort`, `status`, `is_deleted`)
VALUES
(100, 1, 0, '0', 'NovaCloud', 'NOVA', 0, 1, 0),
(101, 1, 100, '0,100', '研发中心', 'RD', 1, 1, 0),
(102, 1, 100, '0,100', '运营中心', 'OPS', 2, 1, 0);

-- 岗位
INSERT INTO `sys_post`
(`id`, `tenant_id`, `post_code`, `post_name`, `sort`, `status`, `is_deleted`)
VALUES
(1, 1, 'ceo', '董事长', 1, 1, 0),
(2, 1, 'se', '项目经理', 2, 1, 0),
(3, 1, 'dev', '开发工程师', 3, 1, 0);

-- 超级管理员（密码 admin123，BCrypt）
INSERT INTO `sys_user`
(`id`, `tenant_id`, `dept_id`, `username`, `password`, `nickname`, `real_name`, `email`, `user_type`, `status`, `is_deleted`, `remark`)
VALUES
(1, 1, 100, 'admin',
 '$2a$10$jzJqz6b8fJ.4GHPlybfgx.J3p1/7PsbBwA71JFoi08buJnOD5OXMu',
 '超级管理员', '管理员', 'admin@nova.local', 9, 1, 0, '默认超管，请尽快修改密码');

-- 角色
INSERT INTO `sys_role`
(`id`, `tenant_id`, `role_code`, `role_name`, `data_scope`, `sort`, `status`, `is_deleted`, `remark`)
VALUES
(1, 1, 'super_admin', '超级管理员', 1, 1, 1, 0, '拥有所有权限'),
(2, 1, 'tenant_admin', '租户管理员', 1, 2, 1, 0, '租户内管理员'),
(3, 1, 'common', '普通用户', 5, 3, 1, 0, '默认普通角色');

INSERT INTO `sys_user_role` (`id`, `user_id`, `role_id`) VALUES (1, 1, 1);
INSERT INTO `sys_user_post` (`id`, `user_id`, `post_id`) VALUES (1, 1, 1);

-- 基础菜单
INSERT INTO `sys_menu`
(`id`, `parent_id`, `menu_name`, `menu_type`, `path`, `component`, `permission`, `icon`, `sort`, `is_visible`, `status`, `is_frame`, `is_cache`, `is_deleted`)
VALUES
(1, 0, '系统管理', 'M', '/system', NULL, NULL, 'setting', 1, 1, 1, 0, 0, 0),
(2, 1, '用户管理', 'C', 'user', 'system/user/index', 'system:user:list', 'user', 1, 1, 1, 0, 0, 0),
(3, 1, '角色管理', 'C', 'role', 'system/role/index', 'system:role:list', 'peoples', 2, 1, 1, 0, 0, 0),
(4, 1, '菜单管理', 'C', 'menu', 'system/menu/index', 'system:menu:list', 'tree-table', 3, 1, 1, 0, 0, 0),
(5, 1, '部门管理', 'C', 'dept', 'system/dept/index', 'system:dept:list', 'tree', 4, 1, 1, 0, 0, 0),
(6, 1, '字典管理', 'C', 'dict', 'system/dict/index', 'system:dict:list', 'dict', 5, 1, 1, 0, 0, 0),
(7, 1, '参数设置', 'C', 'config', 'system/config/index', 'system:config:list', 'edit', 6, 1, 1, 0, 0, 0),
(8, 0, 'AI平台', 'M', '/ai', NULL, NULL, 'robot', 2, 1, 1, 0, 0, 0),
(9, 8, '模型管理', 'C', 'model', 'ai/model/index', 'ai:model:list', 'component', 1, 1, 1, 0, 0, 0),
(10, 8, 'Agent管理', 'C', 'agent', 'ai/agent/index', 'ai:agent:list', 'guide', 2, 1, 1, 0, 0, 0),
(11, 8, '知识库', 'C', 'knowledge', 'ai/knowledge/index', 'ai:knowledge:list', 'documentation', 3, 1, 1, 0, 0, 0),
(12, 8, '工作流', 'C', 'workflow', 'ai/workflow/index', 'ai:workflow:list', 'tree', 4, 1, 1, 0, 0, 0),
(13, 0, '文件中心', 'M', '/file', NULL, NULL, 'upload', 3, 1, 1, 0, 0, 0),
(14, 13, '文件管理', 'C', 'list', 'file/list/index', 'file:info:list', 'list', 1, 1, 1, 0, 0, 0),
(18, 13, '存储配置', 'C', 'storage', 'file/storage/index', 'file:storage:list', 'server', 2, 1, 1, 0, 0, 0),
(15, 0, '监控中心', 'M', '/monitor', NULL, NULL, 'monitor', 4, 1, 1, 0, 0, 0),
(16, 15, '操作日志', 'C', 'operlog', 'monitor/operlog/index', 'monitor:operlog:list', 'form', 1, 1, 1, 0, 0, 0),
(17, 15, '登录日志', 'C', 'loginlog', 'monitor/loginlog/index', 'monitor:loginlog:list', 'logininfor', 2, 1, 1, 0, 0, 0);

INSERT INTO `sys_role_menu` (`id`, `role_id`, `menu_id`)
SELECT `id`, 1, `id` FROM `sys_menu`;

INSERT INTO `sys_dict_type`
(`id`, `tenant_id`, `dict_name`, `dict_type`, `status`, `is_deleted`, `remark`)
VALUES
(1, 0, '用户性别', 'sys_user_sex', 1, 0, NULL),
(2, 0, '系统状态', 'sys_common_status', 1, 0, NULL),
(3, 0, '文件上传状态', 'file_upload_status', 1, 0, NULL),
(4, 0, 'AI任务状态', 'ai_task_status', 1, 0, NULL);

INSERT INTO `sys_dict_data`
(`id`, `tenant_id`, `dict_type`, `dict_label`, `dict_value`, `sort`, `status`, `is_deleted`)
VALUES
(1, 0, 'sys_user_sex', '未知', '0', 1, 1, 0),
(2, 0, 'sys_user_sex', '男', '1', 2, 1, 0),
(3, 0, 'sys_user_sex', '女', '2', 3, 1, 0),
(4, 0, 'sys_common_status', '停用', '0', 1, 1, 0),
(5, 0, 'sys_common_status', '正常', '1', 2, 1, 0),
(6, 0, 'file_upload_status', '上传中', '0', 1, 1, 0),
(7, 0, 'file_upload_status', '完成', '1', 2, 1, 0),
(8, 0, 'file_upload_status', '失败', '2', 3, 1, 0),
(9, 0, 'ai_task_status', '排队', '0', 1, 1, 0),
(10, 0, 'ai_task_status', '处理中', '1', 2, 1, 0),
(11, 0, 'ai_task_status', '成功', '2', 3, 1, 0),
(12, 0, 'ai_task_status', '失败', '3', 4, 1, 0);

INSERT INTO `sys_config`
(`id`, `tenant_id`, `config_name`, `config_key`, `config_value`, `is_system`, `is_deleted`, `remark`)
VALUES
(1, 0, '账号初始密码', 'sys.user.initPassword', 'admin123', 1, 0, '用户管理-账号初始密码'),
(2, 0, '用户注册开关', 'sys.account.registerEnabled', 'false', 1, 0, '是否开放注册'),
(3, 0, '验证码开关', 'sys.account.captchaEnabled', 'true', 1, 0, '登录是否校验验证码');

-- 默认本地存储
INSERT INTO `file_storage`
(`id`, `tenant_id`, `storage_code`, `storage_name`, `storage_type`, `base_path`, `is_default`, `status`, `is_deleted`, `remark`)
VALUES
(1, 0, 'local', '本地存储', 'local', '/data/nova/files', 1, 1, 0, '开发默认本地磁盘');

-- AI 模型提供商 / 模型 / 默认 Agent（API Key 请在后台填写，或设置环境变量 DASHSCOPE_API_KEY）
INSERT INTO `ai_model_provider`
(`id`, `tenant_id`, `provider_code`, `provider_name`, `base_url`, `api_key_cipher`, `status`, `is_deleted`, `remark`)
VALUES
(1, 0, 'dashscope', '阿里云百炼 DashScope', NULL, NULL, 1, 0, 'API Key 优先读库，为空则读环境变量 DASHSCOPE_API_KEY'),
(2, 0, 'openai', 'OpenAI 兼容', 'https://api.openai.com/v1', NULL, 1, 0, '可用于 OpenAI / DeepSeek 等兼容端点'),
(3, 0, 'ollama', 'Ollama 本地', 'http://127.0.0.1:11434', NULL, 1, 0, '本地模型');

INSERT INTO `ai_model`
(`id`, `tenant_id`, `provider_id`, `model_code`, `model_name`, `model_type`, `max_tokens`, `status`, `is_deleted`, `remark`)
VALUES
(1, 0, 1, 'dashscope:qwen-plus', '通义千问 Plus', 'chat', 2048, 1, 0, '默认对话模型'),
(2, 0, 1, 'dashscope:qwen-turbo', '通义千问 Turbo', 'chat', 2048, 1, 0, NULL),
(3, 0, 3, 'ollama:llama3', 'Llama3 本地', 'chat', 2048, 1, 0, NULL);

INSERT INTO `ai_agent`
(`id`, `tenant_id`, `agent_code`, `agent_name`, `model_id`, `sys_prompt`, `workspace_path`, `status`, `is_deleted`, `remark`)
VALUES
(1, 0, 'default', '默认助手', 1,
 '你是 NovaCloud 平台助手，回答简洁准确，使用中文。',
 './work/agentscope/workspace', 1, 0, 'Harness 多轮会话默认 Agent');

-- 默认 OAuth2 客户端（密钥请在生产环境重新生成）
INSERT INTO `auth_client`
(`id`, `tenant_id`, `client_id`, `client_secret`, `client_name`, `authorization_grant_types`,
 `redirect_uris`, `scopes`, `is_require_consent`, `access_token_ttl`, `refresh_token_ttl`, `status`, `is_deleted`, `remark`)
VALUES
(1, 0, 'nova-web',
 '$2a$10$jzJqz6b8fJ.4GHPlybfgx.J3p1/7PsbBwA71JFoi08buJnOD5OXMu',
 'NovaCloud Web',
 'authorization_code,refresh_token,client_credentials',
 'http://127.0.0.1:5173/callback',
 'openid,profile,api',
 0, 7200, 604800, 1, 0, '前端开发客户端');

