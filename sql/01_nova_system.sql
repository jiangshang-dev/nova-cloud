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
  PRIMARY KEY (`id`),
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
  PRIMARY KEY (`id`),
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
  PRIMARY KEY (`id`),
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
  PRIMARY KEY (`id`),
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
  PRIMARY KEY (`id`),
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
  PRIMARY KEY (`id`),
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
  PRIMARY KEY (`id`),
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
  PRIMARY KEY (`id`),
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
  PRIMARY KEY (`id`),
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
  PRIMARY KEY (`id`),
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
  PRIMARY KEY (`id`),
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
  PRIMARY KEY (`id`),
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
  PRIMARY KEY (`id`),
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
  PRIMARY KEY (`id`),
  KEY `idx_tenant_id` (`tenant_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='通知公告表';
