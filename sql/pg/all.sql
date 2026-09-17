-- =========================================================
-- NovaCloud PostgreSQL 一键脚本
-- 用法（在 postgres 库下执行，脚本内会 \c 切库）：
--   psql -U postgres -f all.sql
-- =========================================================

\echo === 00_init_database ===
-- =========================================================
-- NovaCloud PostgreSQL 建库
-- PostgreSQL 14+
-- =========================================================
-- 需具备创建库权限。若库已存在请跳过本文件。
-- 用法示例：
--   psql -U postgres -f 00_init_database.sql
--   psql -U postgres -d nova_cloud -f 01_nova_system.sql
-- =========================================================

CREATE DATABASE nova_cloud WITH ENCODING = 'UTF8';

-- 可选：指定排序规则（按操作系统 locale 调整，失败时可仅保留上一行）
-- CREATE DATABASE nova_cloud
--   WITH ENCODING = 'UTF8'
--        LC_COLLATE = 'en_US.UTF-8'
--        LC_CTYPE = 'en_US.UTF-8'
--        TEMPLATE = template0;

\c nova_cloud

\echo === 01_nova_system.sql ===
-- =========================================================
-- NovaCloud PostgreSQL 脚本（由 MySQL 版对照生成）
-- 源文件: sql/01_nova_system.sql
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
-- nova-system：租户 / 组织 / 用户 / RBAC / 字典 / 参数 / 通知
-- 规范：阿里巴巴 Java 开发手册 2.0 建表规约（无外键）
-- =========================================================
-- ----------------------------
-- 租户
-- ----------------------------

DROP TABLE IF EXISTS sys_tenant CASCADE;
CREATE TABLE sys_tenant (
  id              BIGINT NOT NULL,
  tenant_code     VARCHAR(64)     NOT NULL,
  tenant_name     VARCHAR(128)    NOT NULL,
  contact_name    VARCHAR(64)              DEFAULT NULL,
  contact_phone   VARCHAR(32)              DEFAULT NULL,
  contact_email   VARCHAR(128)             DEFAULT NULL,
  expire_time     TIMESTAMP                 DEFAULT NULL,
  status          SMALLINT NOT NULL DEFAULT 1,
  package_id      BIGINT          DEFAULT NULL,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_sys_tenant PRIMARY KEY (id),
  CONSTRAINT uk_tenant_code UNIQUE (tenant_code)
);
COMMENT ON TABLE sys_tenant IS '租户表';
COMMENT ON COLUMN sys_tenant.id IS '主键';
COMMENT ON COLUMN sys_tenant.tenant_code IS '租户编码';
COMMENT ON COLUMN sys_tenant.tenant_name IS '租户名称';
COMMENT ON COLUMN sys_tenant.contact_name IS '联系人';
COMMENT ON COLUMN sys_tenant.contact_phone IS '联系电话';
COMMENT ON COLUMN sys_tenant.contact_email IS '联系邮箱';
COMMENT ON COLUMN sys_tenant.expire_time IS '到期时间，空表示永久';
COMMENT ON COLUMN sys_tenant.status IS '状态：0停用 1正常';
COMMENT ON COLUMN sys_tenant.package_id IS '套餐ID，预留';
COMMENT ON COLUMN sys_tenant.create_by IS '创建人';
COMMENT ON COLUMN sys_tenant.update_by IS '修改人';
COMMENT ON COLUMN sys_tenant.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN sys_tenant.remark IS '备注';
COMMENT ON COLUMN sys_tenant.gmt_create IS '创建时间';
COMMENT ON COLUMN sys_tenant.gmt_modified IS '修改时间';

-- ----------------------------
-- 部门
-- ----------------------------

DROP TABLE IF EXISTS sys_dept CASCADE;
CREATE TABLE sys_dept (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  parent_id       BIGINT NOT NULL DEFAULT 0,
  ancestors       VARCHAR(512)    NOT NULL DEFAULT '',
  dept_name       VARCHAR(64)     NOT NULL,
  dept_code       VARCHAR(64)              DEFAULT NULL,
  sort            INTEGER    NOT NULL DEFAULT 0,
  leader_id       BIGINT          DEFAULT NULL,
  phone           VARCHAR(32)              DEFAULT NULL,
  email           VARCHAR(128)             DEFAULT NULL,
  status          SMALLINT NOT NULL DEFAULT 1,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_sys_dept PRIMARY KEY (id)
);
COMMENT ON TABLE sys_dept IS '部门表';
COMMENT ON COLUMN sys_dept.id IS '主键';
COMMENT ON COLUMN sys_dept.tenant_id IS '租户ID，0表示平台';
COMMENT ON COLUMN sys_dept.parent_id IS '父部门ID，0表示根';
COMMENT ON COLUMN sys_dept.ancestors IS '祖级列表，如0,100,101';
COMMENT ON COLUMN sys_dept.dept_name IS '部门名称';
COMMENT ON COLUMN sys_dept.dept_code IS '部门编码';
COMMENT ON COLUMN sys_dept.sort IS '显示顺序';
COMMENT ON COLUMN sys_dept.leader_id IS '负责人用户ID';
COMMENT ON COLUMN sys_dept.phone IS '联系电话';
COMMENT ON COLUMN sys_dept.email IS '邮箱';
COMMENT ON COLUMN sys_dept.status IS '状态：0停用 1正常';
COMMENT ON COLUMN sys_dept.create_by IS '创建人';
COMMENT ON COLUMN sys_dept.update_by IS '修改人';
COMMENT ON COLUMN sys_dept.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN sys_dept.remark IS '备注';
COMMENT ON COLUMN sys_dept.gmt_create IS '创建时间';
COMMENT ON COLUMN sys_dept.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_tenant_parent ON sys_dept (tenant_id, parent_id);

-- ----------------------------
-- 岗位
-- ----------------------------

DROP TABLE IF EXISTS sys_post CASCADE;
CREATE TABLE sys_post (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  post_code       VARCHAR(64)     NOT NULL,
  post_name       VARCHAR(64)     NOT NULL,
  sort            INTEGER    NOT NULL DEFAULT 0,
  status          SMALLINT NOT NULL DEFAULT 1,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_sys_post PRIMARY KEY (id),
  CONSTRAINT uk_tenant_post_code UNIQUE (tenant_id, post_code)
);
COMMENT ON TABLE sys_post IS '岗位表';
COMMENT ON COLUMN sys_post.id IS '主键';
COMMENT ON COLUMN sys_post.tenant_id IS '租户ID';
COMMENT ON COLUMN sys_post.post_code IS '岗位编码';
COMMENT ON COLUMN sys_post.post_name IS '岗位名称';
COMMENT ON COLUMN sys_post.sort IS '显示顺序';
COMMENT ON COLUMN sys_post.status IS '状态：0停用 1正常';
COMMENT ON COLUMN sys_post.create_by IS '创建人';
COMMENT ON COLUMN sys_post.update_by IS '修改人';
COMMENT ON COLUMN sys_post.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN sys_post.remark IS '备注';
COMMENT ON COLUMN sys_post.gmt_create IS '创建时间';
COMMENT ON COLUMN sys_post.gmt_modified IS '修改时间';

-- ----------------------------
-- 用户
-- ----------------------------

DROP TABLE IF EXISTS sys_user CASCADE;
CREATE TABLE sys_user (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  dept_id         BIGINT          DEFAULT NULL,
  username        VARCHAR(64)     NOT NULL,
  password        VARCHAR(128)    NOT NULL,
  nickname        VARCHAR(64)              DEFAULT NULL,
  real_name       VARCHAR(64)              DEFAULT NULL,
  email           VARCHAR(128)             DEFAULT NULL,
  phone           VARCHAR(32)              DEFAULT NULL,
  sex             SMALLINT NOT NULL DEFAULT 0,
  avatar          VARCHAR(512)             DEFAULT NULL,
  user_type       SMALLINT NOT NULL DEFAULT 1,
  status          SMALLINT NOT NULL DEFAULT 1,
  login_ip        VARCHAR(64)              DEFAULT NULL,
  login_time      TIMESTAMP                 DEFAULT NULL,
  pwd_update_time TIMESTAMP                 DEFAULT NULL,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_sys_user PRIMARY KEY (id),
  CONSTRAINT uk_tenant_username UNIQUE (tenant_id, username)
);
COMMENT ON TABLE sys_user IS '用户表';
COMMENT ON COLUMN sys_user.id IS '主键';
COMMENT ON COLUMN sys_user.tenant_id IS '租户ID';
COMMENT ON COLUMN sys_user.dept_id IS '主部门ID';
COMMENT ON COLUMN sys_user.username IS '登录账号';
COMMENT ON COLUMN sys_user.password IS '密码密文';
COMMENT ON COLUMN sys_user.nickname IS '昵称';
COMMENT ON COLUMN sys_user.real_name IS '真实姓名';
COMMENT ON COLUMN sys_user.email IS '邮箱';
COMMENT ON COLUMN sys_user.phone IS '手机号';
COMMENT ON COLUMN sys_user.sex IS '性别：0未知 1男 2女';
COMMENT ON COLUMN sys_user.avatar IS '头像URL';
COMMENT ON COLUMN sys_user.user_type IS '用户类型：1普通 2管理员 9超级管理员';
COMMENT ON COLUMN sys_user.status IS '状态：0停用 1正常';
COMMENT ON COLUMN sys_user.login_ip IS '最后登录IP';
COMMENT ON COLUMN sys_user.login_time IS '最后登录时间';
COMMENT ON COLUMN sys_user.pwd_update_time IS '密码最后修改时间';
COMMENT ON COLUMN sys_user.create_by IS '创建人';
COMMENT ON COLUMN sys_user.update_by IS '修改人';
COMMENT ON COLUMN sys_user.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN sys_user.remark IS '备注';
COMMENT ON COLUMN sys_user.gmt_create IS '创建时间';
COMMENT ON COLUMN sys_user.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_phone ON sys_user (phone);
CREATE INDEX IF NOT EXISTS idx_dept_id ON sys_user (dept_id);

-- ----------------------------
-- 角色
-- ----------------------------

DROP TABLE IF EXISTS sys_role CASCADE;
CREATE TABLE sys_role (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  role_code       VARCHAR(64)     NOT NULL,
  role_name       VARCHAR(64)     NOT NULL,
  data_scope      SMALLINT NOT NULL DEFAULT 1,
  sort            INTEGER    NOT NULL DEFAULT 0,
  status          SMALLINT NOT NULL DEFAULT 1,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_sys_role PRIMARY KEY (id),
  CONSTRAINT uk_tenant_role_code UNIQUE (tenant_id, role_code)
);
COMMENT ON TABLE sys_role IS '角色表';
COMMENT ON COLUMN sys_role.id IS '主键';
COMMENT ON COLUMN sys_role.tenant_id IS '租户ID';
COMMENT ON COLUMN sys_role.role_code IS '角色编码';
COMMENT ON COLUMN sys_role.role_name IS '角色名称';
COMMENT ON COLUMN sys_role.data_scope IS '数据范围：1全部 2自定义 3本部门 4本部门及以下 5仅本人';
COMMENT ON COLUMN sys_role.sort IS '显示顺序';
COMMENT ON COLUMN sys_role.status IS '状态：0停用 1正常';
COMMENT ON COLUMN sys_role.create_by IS '创建人';
COMMENT ON COLUMN sys_role.update_by IS '修改人';
COMMENT ON COLUMN sys_role.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN sys_role.remark IS '备注';
COMMENT ON COLUMN sys_role.gmt_create IS '创建时间';
COMMENT ON COLUMN sys_role.gmt_modified IS '修改时间';

-- ----------------------------
-- 菜单权限
-- ----------------------------

DROP TABLE IF EXISTS sys_menu CASCADE;
CREATE TABLE sys_menu (
  id              BIGINT NOT NULL,
  parent_id       BIGINT NOT NULL DEFAULT 0,
  menu_name       VARCHAR(64)     NOT NULL,
  menu_type       CHAR(1)         NOT NULL,
  path            VARCHAR(255)             DEFAULT NULL,
  component       VARCHAR(255)             DEFAULT NULL,
  permission      VARCHAR(128)             DEFAULT NULL,
  icon            VARCHAR(128)             DEFAULT NULL,
  sort            INTEGER    NOT NULL DEFAULT 0,
  is_visible      SMALLINT NOT NULL DEFAULT 1,
  status          SMALLINT NOT NULL DEFAULT 1,
  is_frame        SMALLINT NOT NULL DEFAULT 0,
  is_cache        SMALLINT NOT NULL DEFAULT 0,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_sys_menu PRIMARY KEY (id)
);
COMMENT ON TABLE sys_menu IS '菜单权限表';
COMMENT ON COLUMN sys_menu.id IS '主键';
COMMENT ON COLUMN sys_menu.parent_id IS '父菜单ID，0表示根';
COMMENT ON COLUMN sys_menu.menu_name IS '菜单名称';
COMMENT ON COLUMN sys_menu.menu_type IS '类型：M目录 C菜单 F按钮';
COMMENT ON COLUMN sys_menu.path IS '路由地址';
COMMENT ON COLUMN sys_menu.component IS '组件路径';
COMMENT ON COLUMN sys_menu.permission IS '权限标识，如system:user:list';
COMMENT ON COLUMN sys_menu.icon IS '菜单图标';
COMMENT ON COLUMN sys_menu.sort IS '显示顺序';
COMMENT ON COLUMN sys_menu.is_visible IS '是否可见：0否 1是';
COMMENT ON COLUMN sys_menu.status IS '状态：0停用 1正常';
COMMENT ON COLUMN sys_menu.is_frame IS '是否外链：0否 1是';
COMMENT ON COLUMN sys_menu.is_cache IS '是否缓存：0否 1是';
COMMENT ON COLUMN sys_menu.create_by IS '创建人';
COMMENT ON COLUMN sys_menu.update_by IS '修改人';
COMMENT ON COLUMN sys_menu.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN sys_menu.remark IS '备注';
COMMENT ON COLUMN sys_menu.gmt_create IS '创建时间';
COMMENT ON COLUMN sys_menu.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_parent_id ON sys_menu (parent_id);

-- ----------------------------
-- 用户角色关联
-- ----------------------------

DROP TABLE IF EXISTS sys_user_role CASCADE;
CREATE TABLE sys_user_role (
  id              BIGINT NOT NULL,
  user_id         BIGINT NOT NULL,
  role_id         BIGINT NOT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_sys_user_role PRIMARY KEY (id),
  CONSTRAINT uk_user_role UNIQUE (user_id, role_id)
);
COMMENT ON TABLE sys_user_role IS '用户角色关联表';
COMMENT ON COLUMN sys_user_role.id IS '主键';
COMMENT ON COLUMN sys_user_role.user_id IS '用户ID';
COMMENT ON COLUMN sys_user_role.role_id IS '角色ID';
COMMENT ON COLUMN sys_user_role.gmt_create IS '创建时间';
COMMENT ON COLUMN sys_user_role.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_role_id ON sys_user_role (role_id);

-- ----------------------------
-- 角色菜单关联
-- ----------------------------

DROP TABLE IF EXISTS sys_role_menu CASCADE;
CREATE TABLE sys_role_menu (
  id              BIGINT NOT NULL,
  role_id         BIGINT NOT NULL,
  menu_id         BIGINT NOT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_sys_role_menu PRIMARY KEY (id),
  CONSTRAINT uk_role_menu UNIQUE (role_id, menu_id)
);
COMMENT ON TABLE sys_role_menu IS '角色菜单关联表';
COMMENT ON COLUMN sys_role_menu.id IS '主键';
COMMENT ON COLUMN sys_role_menu.role_id IS '角色ID';
COMMENT ON COLUMN sys_role_menu.menu_id IS '菜单ID';
COMMENT ON COLUMN sys_role_menu.gmt_create IS '创建时间';
COMMENT ON COLUMN sys_role_menu.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_menu_id ON sys_role_menu (menu_id);

-- ----------------------------
-- 用户岗位关联
-- ----------------------------

DROP TABLE IF EXISTS sys_user_post CASCADE;
CREATE TABLE sys_user_post (
  id              BIGINT NOT NULL,
  user_id         BIGINT NOT NULL,
  post_id         BIGINT NOT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_sys_user_post PRIMARY KEY (id),
  CONSTRAINT uk_user_post UNIQUE (user_id, post_id)
);
COMMENT ON TABLE sys_user_post IS '用户岗位关联表';
COMMENT ON COLUMN sys_user_post.id IS '主键';
COMMENT ON COLUMN sys_user_post.user_id IS '用户ID';
COMMENT ON COLUMN sys_user_post.post_id IS '岗位ID';
COMMENT ON COLUMN sys_user_post.gmt_create IS '创建时间';
COMMENT ON COLUMN sys_user_post.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_post_id ON sys_user_post (post_id);

-- ----------------------------
-- 角色部门关联（自定义数据权限）
-- ----------------------------

DROP TABLE IF EXISTS sys_role_dept CASCADE;
CREATE TABLE sys_role_dept (
  id              BIGINT NOT NULL,
  role_id         BIGINT NOT NULL,
  dept_id         BIGINT NOT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_sys_role_dept PRIMARY KEY (id),
  CONSTRAINT uk_role_dept UNIQUE (role_id, dept_id)
);
COMMENT ON TABLE sys_role_dept IS '角色部门关联表';
COMMENT ON COLUMN sys_role_dept.id IS '主键';
COMMENT ON COLUMN sys_role_dept.role_id IS '角色ID';
COMMENT ON COLUMN sys_role_dept.dept_id IS '部门ID';
COMMENT ON COLUMN sys_role_dept.gmt_create IS '创建时间';
COMMENT ON COLUMN sys_role_dept.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_dept_id ON sys_role_dept (dept_id);

-- ----------------------------
-- 字典类型
-- ----------------------------

DROP TABLE IF EXISTS sys_dict_type CASCADE;
CREATE TABLE sys_dict_type (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  dict_name       VARCHAR(100)    NOT NULL,
  dict_type       VARCHAR(100)    NOT NULL,
  status          SMALLINT NOT NULL DEFAULT 1,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_sys_dict_type PRIMARY KEY (id),
  CONSTRAINT uk_tenant_dict_type UNIQUE (tenant_id, dict_type)
);
COMMENT ON TABLE sys_dict_type IS '字典类型表';
COMMENT ON COLUMN sys_dict_type.id IS '主键';
COMMENT ON COLUMN sys_dict_type.tenant_id IS '租户ID，0表示全局';
COMMENT ON COLUMN sys_dict_type.dict_name IS '字典名称';
COMMENT ON COLUMN sys_dict_type.dict_type IS '字典类型';
COMMENT ON COLUMN sys_dict_type.status IS '状态：0停用 1正常';
COMMENT ON COLUMN sys_dict_type.create_by IS '创建人';
COMMENT ON COLUMN sys_dict_type.update_by IS '修改人';
COMMENT ON COLUMN sys_dict_type.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN sys_dict_type.remark IS '备注';
COMMENT ON COLUMN sys_dict_type.gmt_create IS '创建时间';
COMMENT ON COLUMN sys_dict_type.gmt_modified IS '修改时间';

-- ----------------------------
-- 字典数据
-- ----------------------------

DROP TABLE IF EXISTS sys_dict_data CASCADE;
CREATE TABLE sys_dict_data (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  dict_type       VARCHAR(100)    NOT NULL,
  dict_label      VARCHAR(100)    NOT NULL,
  dict_value      VARCHAR(100)    NOT NULL,
  css_class       VARCHAR(100)             DEFAULT NULL,
  list_class      VARCHAR(100)             DEFAULT NULL,
  sort            INTEGER    NOT NULL DEFAULT 0,
  status          SMALLINT NOT NULL DEFAULT 1,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_sys_dict_data PRIMARY KEY (id)
);
COMMENT ON TABLE sys_dict_data IS '字典数据表';
COMMENT ON COLUMN sys_dict_data.id IS '主键';
COMMENT ON COLUMN sys_dict_data.tenant_id IS '租户ID，0表示全局';
COMMENT ON COLUMN sys_dict_data.dict_type IS '字典类型';
COMMENT ON COLUMN sys_dict_data.dict_label IS '字典标签';
COMMENT ON COLUMN sys_dict_data.dict_value IS '字典键值';
COMMENT ON COLUMN sys_dict_data.css_class IS '样式属性';
COMMENT ON COLUMN sys_dict_data.list_class IS '表格回显样式';
COMMENT ON COLUMN sys_dict_data.sort IS '显示顺序';
COMMENT ON COLUMN sys_dict_data.status IS '状态：0停用 1正常';
COMMENT ON COLUMN sys_dict_data.create_by IS '创建人';
COMMENT ON COLUMN sys_dict_data.update_by IS '修改人';
COMMENT ON COLUMN sys_dict_data.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN sys_dict_data.remark IS '备注';
COMMENT ON COLUMN sys_dict_data.gmt_create IS '创建时间';
COMMENT ON COLUMN sys_dict_data.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_tenant_dict_type ON sys_dict_data (tenant_id, dict_type);

-- ----------------------------
-- 参数配置
-- ----------------------------

DROP TABLE IF EXISTS sys_config CASCADE;
CREATE TABLE sys_config (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  config_name     VARCHAR(100)    NOT NULL,
  config_key      VARCHAR(100)    NOT NULL,
  config_value    VARCHAR(2000)            DEFAULT NULL,
  is_system       SMALLINT NOT NULL DEFAULT 0,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_sys_config PRIMARY KEY (id),
  CONSTRAINT uk_tenant_config_key UNIQUE (tenant_id, config_key)
);
COMMENT ON TABLE sys_config IS '参数配置表';
COMMENT ON COLUMN sys_config.id IS '主键';
COMMENT ON COLUMN sys_config.tenant_id IS '租户ID，0表示全局';
COMMENT ON COLUMN sys_config.config_name IS '参数名称';
COMMENT ON COLUMN sys_config.config_key IS '参数键名';
COMMENT ON COLUMN sys_config.config_value IS '参数键值';
COMMENT ON COLUMN sys_config.is_system IS '是否系统内置：0否 1是';
COMMENT ON COLUMN sys_config.create_by IS '创建人';
COMMENT ON COLUMN sys_config.update_by IS '修改人';
COMMENT ON COLUMN sys_config.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN sys_config.remark IS '备注';
COMMENT ON COLUMN sys_config.gmt_create IS '创建时间';
COMMENT ON COLUMN sys_config.gmt_modified IS '修改时间';

-- ----------------------------
-- 通知公告
-- ----------------------------

DROP TABLE IF EXISTS sys_notice CASCADE;
CREATE TABLE sys_notice (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  notice_title    VARCHAR(128)    NOT NULL,
  notice_type     SMALLINT NOT NULL DEFAULT 1,
  notice_content  TEXT,
  status          SMALLINT NOT NULL DEFAULT 1,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_sys_notice PRIMARY KEY (id)
);
COMMENT ON TABLE sys_notice IS '通知公告表';
COMMENT ON COLUMN sys_notice.id IS '主键';
COMMENT ON COLUMN sys_notice.tenant_id IS '租户ID';
COMMENT ON COLUMN sys_notice.notice_title IS '公告标题';
COMMENT ON COLUMN sys_notice.notice_type IS '类型：1通知 2公告';
COMMENT ON COLUMN sys_notice.notice_content IS '公告内容';
COMMENT ON COLUMN sys_notice.status IS '状态：0关闭 1正常';
COMMENT ON COLUMN sys_notice.create_by IS '创建人';
COMMENT ON COLUMN sys_notice.update_by IS '修改人';
COMMENT ON COLUMN sys_notice.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN sys_notice.remark IS '备注';
COMMENT ON COLUMN sys_notice.gmt_create IS '创建时间';
COMMENT ON COLUMN sys_notice.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_tenant_id ON sys_notice (tenant_id);

\echo === 02_nova_auth.sql ===
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

\echo === 03_nova_file.sql ===
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

\echo === 04_nova_log.sql ===
-- =========================================================
-- NovaCloud PostgreSQL 脚本（由 MySQL 版对照生成）
-- 源文件: sql/04_nova_log.sql
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
-- nova-common-log：登录 / 操作 / 审计日志
-- 规范：阿里巴巴 Java 开发手册 2.0 建表规约（无外键）
-- =========================================================
-- ----------------------------
-- 登录日志
-- ----------------------------

DROP TABLE IF EXISTS log_login CASCADE;
CREATE TABLE log_login (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  user_id         BIGINT          DEFAULT NULL,
  username        VARCHAR(64)              DEFAULT NULL,
  login_type      VARCHAR(32)     NOT NULL DEFAULT 'password',
  client_id       VARCHAR(128)             DEFAULT NULL,
  ip              VARCHAR(64)              DEFAULT NULL,
  location        VARCHAR(255)             DEFAULT NULL,
  browser         VARCHAR(128)             DEFAULT NULL,
  os              VARCHAR(128)             DEFAULT NULL,
  user_agent      VARCHAR(512)             DEFAULT NULL,
  status          SMALLINT NOT NULL DEFAULT 1,
  msg             VARCHAR(500)             DEFAULT NULL,
  login_time      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_log_login PRIMARY KEY (id)
);
COMMENT ON TABLE log_login IS '登录日志表';
COMMENT ON COLUMN log_login.id IS '主键';
COMMENT ON COLUMN log_login.tenant_id IS '租户ID';
COMMENT ON COLUMN log_login.user_id IS '用户ID';
COMMENT ON COLUMN log_login.username IS '用户账号';
COMMENT ON COLUMN log_login.login_type IS '登录方式：password/sms/oauth2';
COMMENT ON COLUMN log_login.client_id IS '客户端标识';
COMMENT ON COLUMN log_login.ip IS '登录IP';
COMMENT ON COLUMN log_login.location IS '登录地点';
COMMENT ON COLUMN log_login.browser IS '浏览器';
COMMENT ON COLUMN log_login.os IS '操作系统';
COMMENT ON COLUMN log_login.user_agent IS 'User-Agent';
COMMENT ON COLUMN log_login.status IS '状态：0失败 1成功';
COMMENT ON COLUMN log_login.msg IS '提示消息';
COMMENT ON COLUMN log_login.login_time IS '登录时间';
COMMENT ON COLUMN log_login.gmt_create IS '创建时间';
COMMENT ON COLUMN log_login.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_tenant_username ON log_login (tenant_id, username);
CREATE INDEX IF NOT EXISTS idx_login_time ON log_login (login_time);

-- ----------------------------
-- 操作日志
-- ----------------------------

DROP TABLE IF EXISTS log_operation CASCADE;
CREATE TABLE log_operation (
  id               BIGINT NOT NULL,
  tenant_id        BIGINT NOT NULL DEFAULT 0,
  trace_id         VARCHAR(64)              DEFAULT NULL,
  user_id          BIGINT          DEFAULT NULL,
  username         VARCHAR(64)              DEFAULT NULL,
  module           VARCHAR(64)              DEFAULT NULL,
  business_type    SMALLINT NOT NULL DEFAULT 0,
  method           VARCHAR(255)             DEFAULT NULL,
  request_method   VARCHAR(16)              DEFAULT NULL,
  operator_type    SMALLINT NOT NULL DEFAULT 1,
  request_url      VARCHAR(512)             DEFAULT NULL,
  request_ip       VARCHAR(64)              DEFAULT NULL,
  request_location VARCHAR(255)             DEFAULT NULL,
  request_param    TEXT,
  response_result  TEXT,
  status           SMALLINT NOT NULL DEFAULT 1,
  error_msg        TEXT,
  cost_time        BIGINT NOT NULL DEFAULT 0,
  operate_time     TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_create       TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified     TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_log_operation PRIMARY KEY (id)
);
COMMENT ON TABLE log_operation IS '操作日志表';
COMMENT ON COLUMN log_operation.id IS '主键';
COMMENT ON COLUMN log_operation.tenant_id IS '租户ID';
COMMENT ON COLUMN log_operation.trace_id IS '链路追踪ID';
COMMENT ON COLUMN log_operation.user_id IS '操作用户ID';
COMMENT ON COLUMN log_operation.username IS '操作用户名';
COMMENT ON COLUMN log_operation.module IS '模块名';
COMMENT ON COLUMN log_operation.business_type IS '业务类型：0其它 1新增 2修改 3删除 4授权 5导出 6导入';
COMMENT ON COLUMN log_operation.method IS '方法名';
COMMENT ON COLUMN log_operation.request_method IS '请求方式';
COMMENT ON COLUMN log_operation.operator_type IS '操作类别：1后台用户 2手机端 3其它';
COMMENT ON COLUMN log_operation.request_url IS '请求URL';
COMMENT ON COLUMN log_operation.request_ip IS '主机地址';
COMMENT ON COLUMN log_operation.request_location IS '操作地点';
COMMENT ON COLUMN log_operation.request_param IS '请求参数';
COMMENT ON COLUMN log_operation.response_result IS '返回结果';
COMMENT ON COLUMN log_operation.status IS '状态：0异常 1正常';
COMMENT ON COLUMN log_operation.error_msg IS '错误消息';
COMMENT ON COLUMN log_operation.cost_time IS '耗时，单位毫秒';
COMMENT ON COLUMN log_operation.operate_time IS '操作时间';
COMMENT ON COLUMN log_operation.gmt_create IS '创建时间';
COMMENT ON COLUMN log_operation.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_tenant_user ON log_operation (tenant_id, user_id);
CREATE INDEX IF NOT EXISTS idx_operate_time ON log_operation (operate_time);
CREATE INDEX IF NOT EXISTS idx_trace_id ON log_operation (trace_id);

-- ----------------------------
-- 审计日志
-- ----------------------------

DROP TABLE IF EXISTS log_audit CASCADE;
CREATE TABLE log_audit (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  user_id         BIGINT          DEFAULT NULL,
  username        VARCHAR(64)              DEFAULT NULL,
  audit_type      VARCHAR(64)     NOT NULL,
  biz_type        VARCHAR(64)              DEFAULT NULL,
  biz_id          VARCHAR(64)              DEFAULT NULL,
  action          VARCHAR(64)     NOT NULL,
  before_data     JSON                     DEFAULT NULL,
  after_data      JSON                     DEFAULT NULL,
  ip              VARCHAR(64)              DEFAULT NULL,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_log_audit PRIMARY KEY (id)
);
COMMENT ON TABLE log_audit IS '审计日志表';
COMMENT ON COLUMN log_audit.id IS '主键';
COMMENT ON COLUMN log_audit.tenant_id IS '租户ID';
COMMENT ON COLUMN log_audit.user_id IS '操作人ID';
COMMENT ON COLUMN log_audit.username IS '操作人账号';
COMMENT ON COLUMN log_audit.audit_type IS '审计类型：role_change/perm_change/crypto/config';
COMMENT ON COLUMN log_audit.biz_type IS '业务对象类型';
COMMENT ON COLUMN log_audit.biz_id IS '业务对象ID';
COMMENT ON COLUMN log_audit.action IS '动作';
COMMENT ON COLUMN log_audit.before_data IS '变更前数据';
COMMENT ON COLUMN log_audit.after_data IS '变更后数据';
COMMENT ON COLUMN log_audit.ip IS 'IP地址';
COMMENT ON COLUMN log_audit.remark IS '备注';
COMMENT ON COLUMN log_audit.gmt_create IS '创建时间';
COMMENT ON COLUMN log_audit.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_tenant_biz ON log_audit (tenant_id, biz_type, biz_id);
CREATE INDEX IF NOT EXISTS idx_gmt_create ON log_audit (gmt_create);

\echo === 05_nova_ai.sql ===
-- =========================================================
-- NovaCloud PostgreSQL 脚本（由 MySQL 版对照生成）
-- 源文件: sql/05_nova_ai.sql
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
-- AI 平台：模型 / Agent / 知识库 / RAG / 工作流 / 媒体任务
-- 规范：阿里巴巴 Java 开发手册 2.0 建表规约（无外键）
-- =========================================================
-- ----------------------------
-- 模型提供商
-- ----------------------------

DROP TABLE IF EXISTS ai_model_provider CASCADE;
CREATE TABLE ai_model_provider (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  provider_code   VARCHAR(64)     NOT NULL,
  provider_name   VARCHAR(128)    NOT NULL,
  base_url        VARCHAR(255)             DEFAULT NULL,
  api_key_cipher  VARCHAR(512)             DEFAULT NULL,
  status          SMALLINT NOT NULL DEFAULT 1,
  ext_config      JSON                     DEFAULT NULL,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_model_provider PRIMARY KEY (id),
  CONSTRAINT uk_tenant_provider_code UNIQUE (tenant_id, provider_code)
);
COMMENT ON TABLE ai_model_provider IS 'AI模型提供商表';
COMMENT ON COLUMN ai_model_provider.id IS '主键';
COMMENT ON COLUMN ai_model_provider.tenant_id IS '租户ID，0表示平台';
COMMENT ON COLUMN ai_model_provider.provider_code IS '提供商编码：dashscope/openai/anthropic/ollama';
COMMENT ON COLUMN ai_model_provider.provider_name IS '提供商名称';
COMMENT ON COLUMN ai_model_provider.base_url IS '自定义Endpoint';
COMMENT ON COLUMN ai_model_provider.api_key_cipher IS 'API Key密文';
COMMENT ON COLUMN ai_model_provider.status IS '状态：0停用 1正常';
COMMENT ON COLUMN ai_model_provider.ext_config IS '扩展配置JSON';
COMMENT ON COLUMN ai_model_provider.create_by IS '创建人';
COMMENT ON COLUMN ai_model_provider.update_by IS '修改人';
COMMENT ON COLUMN ai_model_provider.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN ai_model_provider.remark IS '备注';
COMMENT ON COLUMN ai_model_provider.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_model_provider.gmt_modified IS '修改时间';

-- ----------------------------
-- 模型定义
-- ----------------------------

DROP TABLE IF EXISTS ai_model CASCADE;
CREATE TABLE ai_model (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  provider_id     BIGINT NOT NULL,
  model_code      VARCHAR(128)    NOT NULL,
  model_name      VARCHAR(128)    NOT NULL,
  model_type      VARCHAR(32)     NOT NULL DEFAULT 'chat',
  context_window  INTEGER             DEFAULT NULL,
  max_tokens      INTEGER             DEFAULT NULL,
  status          SMALLINT NOT NULL DEFAULT 1,
  ext_config      JSON                     DEFAULT NULL,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_model PRIMARY KEY (id),
  CONSTRAINT uk_tenant_model_code UNIQUE (tenant_id, model_code)
);
COMMENT ON TABLE ai_model IS 'AI模型定义表';
COMMENT ON COLUMN ai_model.id IS '主键';
COMMENT ON COLUMN ai_model.tenant_id IS '租户ID';
COMMENT ON COLUMN ai_model.provider_id IS '提供商ID';
COMMENT ON COLUMN ai_model.model_code IS '模型编码，如dashscope:qwen-plus';
COMMENT ON COLUMN ai_model.model_name IS '模型显示名';
COMMENT ON COLUMN ai_model.model_type IS '类型：chat/embedding/image/video/rerank';
COMMENT ON COLUMN ai_model.context_window IS '上下文窗口';
COMMENT ON COLUMN ai_model.max_tokens IS '默认最大输出token';
COMMENT ON COLUMN ai_model.status IS '状态：0停用 1正常';
COMMENT ON COLUMN ai_model.ext_config IS '默认参数JSON';
COMMENT ON COLUMN ai_model.create_by IS '创建人';
COMMENT ON COLUMN ai_model.update_by IS '修改人';
COMMENT ON COLUMN ai_model.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN ai_model.remark IS '备注';
COMMENT ON COLUMN ai_model.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_model.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_provider_id ON ai_model (provider_id);

-- ----------------------------
-- Agent 定义
-- ----------------------------

DROP TABLE IF EXISTS ai_agent CASCADE;
CREATE TABLE ai_agent (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  agent_code      VARCHAR(64)     NOT NULL,
  agent_name      VARCHAR(128)    NOT NULL,
  model_id        BIGINT          DEFAULT NULL,
  sys_prompt      TEXT,
  workspace_path  VARCHAR(512)             DEFAULT NULL,
  compaction_json JSON                     DEFAULT NULL,
  tools_json      JSON                     DEFAULT NULL,
  skills_json     JSON                     DEFAULT NULL,
  status          SMALLINT NOT NULL DEFAULT 1,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_agent PRIMARY KEY (id),
  CONSTRAINT uk_tenant_agent_code UNIQUE (tenant_id, agent_code)
);
COMMENT ON TABLE ai_agent IS 'AI Agent定义表';
COMMENT ON COLUMN ai_agent.id IS '主键';
COMMENT ON COLUMN ai_agent.tenant_id IS '租户ID';
COMMENT ON COLUMN ai_agent.agent_code IS 'Agent编码';
COMMENT ON COLUMN ai_agent.agent_name IS 'Agent名称';
COMMENT ON COLUMN ai_agent.model_id IS '默认模型ID';
COMMENT ON COLUMN ai_agent.sys_prompt IS '系统提示词';
COMMENT ON COLUMN ai_agent.workspace_path IS '工作区路径';
COMMENT ON COLUMN ai_agent.compaction_json IS '压缩策略配置JSON';
COMMENT ON COLUMN ai_agent.tools_json IS '工具声明JSON';
COMMENT ON COLUMN ai_agent.skills_json IS '技能配置JSON';
COMMENT ON COLUMN ai_agent.status IS '状态：0停用 1正常';
COMMENT ON COLUMN ai_agent.create_by IS '创建人';
COMMENT ON COLUMN ai_agent.update_by IS '修改人';
COMMENT ON COLUMN ai_agent.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN ai_agent.remark IS '备注';
COMMENT ON COLUMN ai_agent.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_agent.gmt_modified IS '修改时间';

-- ----------------------------
-- Agent 会话
-- ----------------------------

DROP TABLE IF EXISTS ai_agent_session CASCADE;
CREATE TABLE ai_agent_session (
  id                BIGINT NOT NULL,
  tenant_id         BIGINT NOT NULL DEFAULT 0,
  agent_id          BIGINT NOT NULL,
  session_id        VARCHAR(128)    NOT NULL,
  user_id           BIGINT          DEFAULT NULL,
  title             VARCHAR(255)             DEFAULT NULL,
  status            SMALLINT NOT NULL DEFAULT 1,
  last_message_time TIMESTAMP                 DEFAULT NULL,
  ext_json          JSON                     DEFAULT NULL,
  create_by         BIGINT          DEFAULT NULL,
  update_by         BIGINT          DEFAULT NULL,
  is_deleted        SMALLINT NOT NULL DEFAULT 0,
  gmt_create        TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_agent_session PRIMARY KEY (id),
  CONSTRAINT uk_tenant_agent_session UNIQUE (tenant_id, agent_id, session_id)
);
COMMENT ON TABLE ai_agent_session IS 'AI Agent会话表';
COMMENT ON COLUMN ai_agent_session.id IS '主键';
COMMENT ON COLUMN ai_agent_session.tenant_id IS '租户ID';
COMMENT ON COLUMN ai_agent_session.agent_id IS 'AgentID';
COMMENT ON COLUMN ai_agent_session.session_id IS '会话业务ID';
COMMENT ON COLUMN ai_agent_session.user_id IS '业务用户ID';
COMMENT ON COLUMN ai_agent_session.title IS '会话标题';
COMMENT ON COLUMN ai_agent_session.status IS '状态：0关闭 1进行中';
COMMENT ON COLUMN ai_agent_session.last_message_time IS '最后消息时间';
COMMENT ON COLUMN ai_agent_session.ext_json IS '扩展信息JSON';
COMMENT ON COLUMN ai_agent_session.create_by IS '创建人';
COMMENT ON COLUMN ai_agent_session.update_by IS '修改人';
COMMENT ON COLUMN ai_agent_session.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN ai_agent_session.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_agent_session.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_tenant_user ON ai_agent_session (tenant_id, user_id);

-- ----------------------------
-- Agent 消息
-- ----------------------------

DROP TABLE IF EXISTS ai_agent_message CASCADE;
CREATE TABLE ai_agent_message (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  session_pk      BIGINT NOT NULL,
  role            VARCHAR(32)     NOT NULL,
  content         TEXT,
  content_blocks  JSON                     DEFAULT NULL,
  token_usage     JSON                     DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_agent_message PRIMARY KEY (id)
);
COMMENT ON TABLE ai_agent_message IS 'AI Agent消息表';
COMMENT ON COLUMN ai_agent_message.id IS '主键';
COMMENT ON COLUMN ai_agent_message.tenant_id IS '租户ID';
COMMENT ON COLUMN ai_agent_message.session_pk IS '会话表主键';
COMMENT ON COLUMN ai_agent_message.role IS '角色：user/assistant/system/tool';
COMMENT ON COLUMN ai_agent_message.content IS '消息内容';
COMMENT ON COLUMN ai_agent_message.content_blocks IS '多模态或工具调用块JSON';
COMMENT ON COLUMN ai_agent_message.token_usage IS 'token统计JSON';
COMMENT ON COLUMN ai_agent_message.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_agent_message.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_session_create ON ai_agent_message (session_pk, gmt_create);

-- ----------------------------
-- 知识库
-- ----------------------------

DROP TABLE IF EXISTS ai_knowledge_base CASCADE;
CREATE TABLE ai_knowledge_base (
  id                 BIGINT NOT NULL,
  tenant_id          BIGINT NOT NULL DEFAULT 0,
  kb_code            VARCHAR(64)     NOT NULL,
  kb_name            VARCHAR(128)    NOT NULL,
  embedding_model_id BIGINT          DEFAULT NULL,
  index_name         VARCHAR(128)             DEFAULT NULL,
  chunk_size         INTEGER    NOT NULL DEFAULT 500,
  chunk_overlap      INTEGER    NOT NULL DEFAULT 50,
  status             SMALLINT NOT NULL DEFAULT 1,
  create_by          BIGINT          DEFAULT NULL,
  update_by          BIGINT          DEFAULT NULL,
  is_deleted         SMALLINT NOT NULL DEFAULT 0,
  remark             VARCHAR(500)             DEFAULT NULL,
  gmt_create         TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified       TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_knowledge_base PRIMARY KEY (id),
  CONSTRAINT uk_tenant_kb_code UNIQUE (tenant_id, kb_code)
);
COMMENT ON TABLE ai_knowledge_base IS '知识库表';
COMMENT ON COLUMN ai_knowledge_base.id IS '主键';
COMMENT ON COLUMN ai_knowledge_base.tenant_id IS '租户ID';
COMMENT ON COLUMN ai_knowledge_base.kb_code IS '知识库编码';
COMMENT ON COLUMN ai_knowledge_base.kb_name IS '知识库名称';
COMMENT ON COLUMN ai_knowledge_base.embedding_model_id IS '向量模型ID';
COMMENT ON COLUMN ai_knowledge_base.index_name IS '检索索引名';
COMMENT ON COLUMN ai_knowledge_base.chunk_size IS '默认分片大小';
COMMENT ON COLUMN ai_knowledge_base.chunk_overlap IS '分片重叠长度';
COMMENT ON COLUMN ai_knowledge_base.status IS '状态：0停用 1正常';
COMMENT ON COLUMN ai_knowledge_base.create_by IS '创建人';
COMMENT ON COLUMN ai_knowledge_base.update_by IS '修改人';
COMMENT ON COLUMN ai_knowledge_base.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN ai_knowledge_base.remark IS '备注';
COMMENT ON COLUMN ai_knowledge_base.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_knowledge_base.gmt_modified IS '修改时间';

-- ----------------------------
-- 知识库文档
-- ----------------------------

DROP TABLE IF EXISTS ai_knowledge_doc CASCADE;
CREATE TABLE ai_knowledge_doc (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  kb_id           BIGINT NOT NULL,
  file_id         BIGINT          DEFAULT NULL,
  doc_name        VARCHAR(255)    NOT NULL,
  doc_type        VARCHAR(32)              DEFAULT NULL,
  source_url      VARCHAR(1000)            DEFAULT NULL,
  parse_status    SMALLINT NOT NULL DEFAULT 0,
  chunk_count     INTEGER    NOT NULL DEFAULT 0,
  error_msg       VARCHAR(1000)            DEFAULT NULL,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_knowledge_doc PRIMARY KEY (id)
);
COMMENT ON TABLE ai_knowledge_doc IS '知识库文档表';
COMMENT ON COLUMN ai_knowledge_doc.id IS '主键';
COMMENT ON COLUMN ai_knowledge_doc.tenant_id IS '租户ID';
COMMENT ON COLUMN ai_knowledge_doc.kb_id IS '知识库ID';
COMMENT ON COLUMN ai_knowledge_doc.file_id IS '文件ID';
COMMENT ON COLUMN ai_knowledge_doc.doc_name IS '文档名';
COMMENT ON COLUMN ai_knowledge_doc.doc_type IS '类型：pdf/md/docx/html/url';
COMMENT ON COLUMN ai_knowledge_doc.source_url IS '来源URL';
COMMENT ON COLUMN ai_knowledge_doc.parse_status IS '解析状态：0待处理 1处理中 2成功 3失败';
COMMENT ON COLUMN ai_knowledge_doc.chunk_count IS '分片数';
COMMENT ON COLUMN ai_knowledge_doc.error_msg IS '失败原因';
COMMENT ON COLUMN ai_knowledge_doc.create_by IS '创建人';
COMMENT ON COLUMN ai_knowledge_doc.update_by IS '修改人';
COMMENT ON COLUMN ai_knowledge_doc.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN ai_knowledge_doc.remark IS '备注';
COMMENT ON COLUMN ai_knowledge_doc.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_knowledge_doc.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_kb_id ON ai_knowledge_doc (kb_id);
CREATE INDEX IF NOT EXISTS idx_parse_status ON ai_knowledge_doc (parse_status);

-- ----------------------------
-- 知识库分片
-- ----------------------------

DROP TABLE IF EXISTS ai_knowledge_chunk CASCADE;
CREATE TABLE ai_knowledge_chunk (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  kb_id           BIGINT NOT NULL,
  doc_id          BIGINT NOT NULL,
  chunk_index     INTEGER    NOT NULL DEFAULT 0,
  content         TEXT      NOT NULL,
  token_count     INTEGER             DEFAULT NULL,
  vector_id       VARCHAR(128)             DEFAULT NULL,
  metadata_json   JSON                     DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_knowledge_chunk PRIMARY KEY (id)
);
COMMENT ON TABLE ai_knowledge_chunk IS '知识库分片表';
COMMENT ON COLUMN ai_knowledge_chunk.id IS '主键';
COMMENT ON COLUMN ai_knowledge_chunk.tenant_id IS '租户ID';
COMMENT ON COLUMN ai_knowledge_chunk.kb_id IS '知识库ID';
COMMENT ON COLUMN ai_knowledge_chunk.doc_id IS '文档ID';
COMMENT ON COLUMN ai_knowledge_chunk.chunk_index IS '分片序号';
COMMENT ON COLUMN ai_knowledge_chunk.content IS '分片文本';
COMMENT ON COLUMN ai_knowledge_chunk.token_count IS 'token数';
COMMENT ON COLUMN ai_knowledge_chunk.vector_id IS '向量库文档ID';
COMMENT ON COLUMN ai_knowledge_chunk.metadata_json IS '元数据JSON';
COMMENT ON COLUMN ai_knowledge_chunk.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN ai_knowledge_chunk.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_knowledge_chunk.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_doc_chunk ON ai_knowledge_chunk (doc_id, chunk_index);
CREATE INDEX IF NOT EXISTS idx_kb_id ON ai_knowledge_chunk (kb_id);

-- ----------------------------
-- RAG 问答日志
-- ----------------------------

DROP TABLE IF EXISTS ai_rag_query_log CASCADE;
CREATE TABLE ai_rag_query_log (
  id               BIGINT NOT NULL,
  tenant_id        BIGINT NOT NULL DEFAULT 0,
  kb_id            BIGINT          DEFAULT NULL,
  user_id          BIGINT          DEFAULT NULL,
  question         TEXT            NOT NULL,
  answer           TEXT,
  retrieved_chunks JSON                     DEFAULT NULL,
  model_code       VARCHAR(128)             DEFAULT NULL,
  latency_ms       BIGINT          DEFAULT NULL,
  gmt_create       TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified     TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_rag_query_log PRIMARY KEY (id)
);
COMMENT ON TABLE ai_rag_query_log IS 'RAG问答日志表';
COMMENT ON COLUMN ai_rag_query_log.id IS '主键';
COMMENT ON COLUMN ai_rag_query_log.tenant_id IS '租户ID';
COMMENT ON COLUMN ai_rag_query_log.kb_id IS '知识库ID';
COMMENT ON COLUMN ai_rag_query_log.user_id IS '用户ID';
COMMENT ON COLUMN ai_rag_query_log.question IS '问题';
COMMENT ON COLUMN ai_rag_query_log.answer IS '回答';
COMMENT ON COLUMN ai_rag_query_log.retrieved_chunks IS '召回分片JSON';
COMMENT ON COLUMN ai_rag_query_log.model_code IS '使用模型编码';
COMMENT ON COLUMN ai_rag_query_log.latency_ms IS '耗时，单位毫秒';
COMMENT ON COLUMN ai_rag_query_log.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_rag_query_log.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_kb_create ON ai_rag_query_log (kb_id, gmt_create);

-- ----------------------------
-- 工作流定义
-- ----------------------------

DROP TABLE IF EXISTS ai_workflow CASCADE;
CREATE TABLE ai_workflow (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  workflow_code   VARCHAR(64)     NOT NULL,
  workflow_name   VARCHAR(128)    NOT NULL,
  version         INTEGER    NOT NULL DEFAULT 1,
  graph_json      JSON                     DEFAULT NULL,
  status          SMALLINT NOT NULL DEFAULT 0,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_workflow PRIMARY KEY (id),
  CONSTRAINT uk_tenant_workflow_ver UNIQUE (tenant_id, workflow_code, version)
);
COMMENT ON TABLE ai_workflow IS 'AI工作流定义表';
COMMENT ON COLUMN ai_workflow.id IS '主键';
COMMENT ON COLUMN ai_workflow.tenant_id IS '租户ID';
COMMENT ON COLUMN ai_workflow.workflow_code IS '工作流编码';
COMMENT ON COLUMN ai_workflow.workflow_name IS '工作流名称';
COMMENT ON COLUMN ai_workflow.version IS '版本号';
COMMENT ON COLUMN ai_workflow.graph_json IS '画布完整JSON';
COMMENT ON COLUMN ai_workflow.status IS '状态：0草稿 1已发布 2停用';
COMMENT ON COLUMN ai_workflow.create_by IS '创建人';
COMMENT ON COLUMN ai_workflow.update_by IS '修改人';
COMMENT ON COLUMN ai_workflow.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN ai_workflow.remark IS '备注';
COMMENT ON COLUMN ai_workflow.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_workflow.gmt_modified IS '修改时间';

-- ----------------------------
-- 工作流节点
-- ----------------------------

DROP TABLE IF EXISTS ai_workflow_node CASCADE;
CREATE TABLE ai_workflow_node (
  id              BIGINT NOT NULL,
  workflow_id     BIGINT NOT NULL,
  node_key        VARCHAR(64)     NOT NULL,
  node_type       VARCHAR(64)     NOT NULL,
  node_name       VARCHAR(128)             DEFAULT NULL,
  config_json     JSON                     DEFAULT NULL,
  position_x      INTEGER                      DEFAULT NULL,
  position_y      INTEGER                      DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_workflow_node PRIMARY KEY (id),
  CONSTRAINT uk_workflow_node UNIQUE (workflow_id, node_key)
);
COMMENT ON TABLE ai_workflow_node IS 'AI工作流节点表';
COMMENT ON COLUMN ai_workflow_node.id IS '主键';
COMMENT ON COLUMN ai_workflow_node.workflow_id IS '工作流ID';
COMMENT ON COLUMN ai_workflow_node.node_key IS '节点唯一键';
COMMENT ON COLUMN ai_workflow_node.node_type IS '类型：start/llm/agent/rag/tool/condition/end';
COMMENT ON COLUMN ai_workflow_node.node_name IS '节点名称';
COMMENT ON COLUMN ai_workflow_node.config_json IS '节点配置JSON';
COMMENT ON COLUMN ai_workflow_node.position_x IS '画布X坐标';
COMMENT ON COLUMN ai_workflow_node.position_y IS '画布Y坐标';
COMMENT ON COLUMN ai_workflow_node.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_workflow_node.gmt_modified IS '修改时间';

-- ----------------------------
-- 工作流连线
-- ----------------------------

DROP TABLE IF EXISTS ai_workflow_edge CASCADE;
CREATE TABLE ai_workflow_edge (
  id              BIGINT NOT NULL,
  workflow_id     BIGINT NOT NULL,
  edge_key        VARCHAR(64)     NOT NULL,
  source_node_key VARCHAR(64)     NOT NULL,
  target_node_key VARCHAR(64)     NOT NULL,
  condition_expr  VARCHAR(512)             DEFAULT NULL,
  config_json     JSON                     DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_workflow_edge PRIMARY KEY (id),
  CONSTRAINT uk_workflow_edge UNIQUE (workflow_id, edge_key)
);
COMMENT ON TABLE ai_workflow_edge IS 'AI工作流连线表';
COMMENT ON COLUMN ai_workflow_edge.id IS '主键';
COMMENT ON COLUMN ai_workflow_edge.workflow_id IS '工作流ID';
COMMENT ON COLUMN ai_workflow_edge.edge_key IS '边唯一键';
COMMENT ON COLUMN ai_workflow_edge.source_node_key IS '源节点键';
COMMENT ON COLUMN ai_workflow_edge.target_node_key IS '目标节点键';
COMMENT ON COLUMN ai_workflow_edge.condition_expr IS '条件表达式';
COMMENT ON COLUMN ai_workflow_edge.config_json IS '扩展配置JSON';
COMMENT ON COLUMN ai_workflow_edge.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_workflow_edge.gmt_modified IS '修改时间';

-- ----------------------------
-- 工作流运行记录
-- ----------------------------

DROP TABLE IF EXISTS ai_workflow_run CASCADE;
CREATE TABLE ai_workflow_run (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  workflow_id     BIGINT NOT NULL,
  run_no          VARCHAR(64)     NOT NULL,
  status          SMALLINT NOT NULL DEFAULT 0,
  input_json      JSON                     DEFAULT NULL,
  output_json     JSON                     DEFAULT NULL,
  error_msg       VARCHAR(2000)            DEFAULT NULL,
  start_time      TIMESTAMP                 DEFAULT NULL,
  end_time        TIMESTAMP                 DEFAULT NULL,
  create_by       BIGINT          DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_workflow_run PRIMARY KEY (id),
  CONSTRAINT uk_run_no UNIQUE (run_no)
);
COMMENT ON TABLE ai_workflow_run IS 'AI工作流运行记录表';
COMMENT ON COLUMN ai_workflow_run.id IS '主键';
COMMENT ON COLUMN ai_workflow_run.tenant_id IS '租户ID';
COMMENT ON COLUMN ai_workflow_run.workflow_id IS '工作流ID';
COMMENT ON COLUMN ai_workflow_run.run_no IS '运行编号';
COMMENT ON COLUMN ai_workflow_run.status IS '状态：0排队 1运行中 2成功 3失败 4取消';
COMMENT ON COLUMN ai_workflow_run.input_json IS '输入JSON';
COMMENT ON COLUMN ai_workflow_run.output_json IS '输出JSON';
COMMENT ON COLUMN ai_workflow_run.error_msg IS '错误信息';
COMMENT ON COLUMN ai_workflow_run.start_time IS '开始时间';
COMMENT ON COLUMN ai_workflow_run.end_time IS '结束时间';
COMMENT ON COLUMN ai_workflow_run.create_by IS '创建人';
COMMENT ON COLUMN ai_workflow_run.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_workflow_run.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_workflow_create ON ai_workflow_run (workflow_id, gmt_create);

-- ----------------------------
-- 媒体生成任务
-- ----------------------------

DROP TABLE IF EXISTS ai_media_task CASCADE;
CREATE TABLE ai_media_task (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  task_no         VARCHAR(64)     NOT NULL,
  media_type      VARCHAR(32)     NOT NULL,
  model_code      VARCHAR(128)             DEFAULT NULL,
  prompt          TEXT,
  params_json     JSON                     DEFAULT NULL,
  status          SMALLINT NOT NULL DEFAULT 0,
  result_file_ids VARCHAR(1000)            DEFAULT NULL,
  result_urls     TEXT,
  error_msg       VARCHAR(2000)            DEFAULT NULL,
  mq_msg_id       VARCHAR(128)             DEFAULT NULL,
  create_by       BIGINT          DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_ai_media_task PRIMARY KEY (id),
  CONSTRAINT uk_task_no UNIQUE (task_no)
);
COMMENT ON TABLE ai_media_task IS 'AI媒体生成任务表';
COMMENT ON COLUMN ai_media_task.id IS '主键';
COMMENT ON COLUMN ai_media_task.tenant_id IS '租户ID';
COMMENT ON COLUMN ai_media_task.task_no IS '任务编号';
COMMENT ON COLUMN ai_media_task.media_type IS '类型：image/video/doc';
COMMENT ON COLUMN ai_media_task.model_code IS '模型编码';
COMMENT ON COLUMN ai_media_task.prompt IS '提示词';
COMMENT ON COLUMN ai_media_task.params_json IS '生成参数JSON';
COMMENT ON COLUMN ai_media_task.status IS '状态：0排队 1处理中 2成功 3失败';
COMMENT ON COLUMN ai_media_task.result_file_ids IS '结果文件ID，逗号分隔';
COMMENT ON COLUMN ai_media_task.result_urls IS '结果URL';
COMMENT ON COLUMN ai_media_task.error_msg IS '错误信息';
COMMENT ON COLUMN ai_media_task.mq_msg_id IS 'MQ消息ID';
COMMENT ON COLUMN ai_media_task.create_by IS '创建人';
COMMENT ON COLUMN ai_media_task.gmt_create IS '创建时间';
COMMENT ON COLUMN ai_media_task.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_tenant_status_create ON ai_media_task (tenant_id, status, gmt_create);

\echo === 06_nova_platform.sql ===
-- =========================================================
-- NovaCloud PostgreSQL 脚本（由 MySQL 版对照生成）
-- 源文件: sql/06_nova_platform.sql
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
-- nova-search / nova-job / nova-monitor 业务辅助表
-- 说明：XXL-JOB / Nacos / SkyWalking 自带库表不在此重复
-- 规范：阿里巴巴 Java 开发手册 2.0 建表规约（无外键）
-- =========================================================
-- ----------------------------
-- 搜索索引元数据
-- ----------------------------

DROP TABLE IF EXISTS search_index_meta CASCADE;
CREATE TABLE search_index_meta (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  index_code      VARCHAR(64)     NOT NULL,
  index_name      VARCHAR(128)    NOT NULL,
  index_alias     VARCHAR(128)             DEFAULT NULL,
  mapping_json    JSON                     DEFAULT NULL,
  settings_json   JSON                     DEFAULT NULL,
  status          SMALLINT NOT NULL DEFAULT 1,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_search_index_meta PRIMARY KEY (id),
  CONSTRAINT uk_tenant_index_code UNIQUE (tenant_id, index_code)
);
COMMENT ON TABLE search_index_meta IS '搜索索引元数据表';
COMMENT ON COLUMN search_index_meta.id IS '主键';
COMMENT ON COLUMN search_index_meta.tenant_id IS '租户ID';
COMMENT ON COLUMN search_index_meta.index_code IS '业务索引编码';
COMMENT ON COLUMN search_index_meta.index_name IS 'ES索引名';
COMMENT ON COLUMN search_index_meta.index_alias IS '索引别名';
COMMENT ON COLUMN search_index_meta.mapping_json IS 'mapping定义JSON';
COMMENT ON COLUMN search_index_meta.settings_json IS 'settings定义JSON';
COMMENT ON COLUMN search_index_meta.status IS '状态：0停用 1正常';
COMMENT ON COLUMN search_index_meta.create_by IS '创建人';
COMMENT ON COLUMN search_index_meta.update_by IS '修改人';
COMMENT ON COLUMN search_index_meta.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN search_index_meta.remark IS '备注';
COMMENT ON COLUMN search_index_meta.gmt_create IS '创建时间';
COMMENT ON COLUMN search_index_meta.gmt_modified IS '修改时间';

-- ----------------------------
-- 搜索同步任务
-- ----------------------------

DROP TABLE IF EXISTS search_sync_task CASCADE;
CREATE TABLE search_sync_task (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  index_id        BIGINT NOT NULL,
  task_no         VARCHAR(64)     NOT NULL,
  sync_type       VARCHAR(32)     NOT NULL DEFAULT 'full',
  status          SMALLINT NOT NULL DEFAULT 0,
  total_count     BIGINT NOT NULL DEFAULT 0,
  success_count   BIGINT NOT NULL DEFAULT 0,
  fail_count      BIGINT NOT NULL DEFAULT 0,
  error_msg       VARCHAR(2000)            DEFAULT NULL,
  start_time      TIMESTAMP                 DEFAULT NULL,
  end_time        TIMESTAMP                 DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_search_sync_task PRIMARY KEY (id),
  CONSTRAINT uk_task_no UNIQUE (task_no)
);
COMMENT ON TABLE search_sync_task IS '搜索同步任务表';
COMMENT ON COLUMN search_sync_task.id IS '主键';
COMMENT ON COLUMN search_sync_task.tenant_id IS '租户ID';
COMMENT ON COLUMN search_sync_task.index_id IS '索引元数据ID';
COMMENT ON COLUMN search_sync_task.task_no IS '任务编号';
COMMENT ON COLUMN search_sync_task.sync_type IS '类型：full/incr';
COMMENT ON COLUMN search_sync_task.status IS '状态：0待执行 1执行中 2成功 3失败';
COMMENT ON COLUMN search_sync_task.total_count IS '总条数';
COMMENT ON COLUMN search_sync_task.success_count IS '成功条数';
COMMENT ON COLUMN search_sync_task.fail_count IS '失败条数';
COMMENT ON COLUMN search_sync_task.error_msg IS '错误信息';
COMMENT ON COLUMN search_sync_task.start_time IS '开始时间';
COMMENT ON COLUMN search_sync_task.end_time IS '结束时间';
COMMENT ON COLUMN search_sync_task.gmt_create IS '创建时间';
COMMENT ON COLUMN search_sync_task.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_index_create ON search_sync_task (index_id, gmt_create);

-- ----------------------------
-- 业务任务定义
-- ----------------------------

DROP TABLE IF EXISTS job_definition CASCADE;
CREATE TABLE job_definition (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  job_code        VARCHAR(64)     NOT NULL,
  job_name        VARCHAR(128)    NOT NULL,
  xxl_job_id      INTEGER             DEFAULT NULL,
  cron_expr       VARCHAR(128)             DEFAULT NULL,
  handler         VARCHAR(128)    NOT NULL,
  param_json      JSON                     DEFAULT NULL,
  status          SMALLINT NOT NULL DEFAULT 1,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_job_definition PRIMARY KEY (id),
  CONSTRAINT uk_tenant_job_code UNIQUE (tenant_id, job_code)
);
COMMENT ON TABLE job_definition IS '业务任务定义表';
COMMENT ON COLUMN job_definition.id IS '主键';
COMMENT ON COLUMN job_definition.tenant_id IS '租户ID';
COMMENT ON COLUMN job_definition.job_code IS '任务编码';
COMMENT ON COLUMN job_definition.job_name IS '任务名称';
COMMENT ON COLUMN job_definition.xxl_job_id IS 'XXL-JOB任务ID';
COMMENT ON COLUMN job_definition.cron_expr IS 'Cron表达式';
COMMENT ON COLUMN job_definition.handler IS '执行器Handler';
COMMENT ON COLUMN job_definition.param_json IS '默认参数JSON';
COMMENT ON COLUMN job_definition.status IS '状态：0停用 1正常';
COMMENT ON COLUMN job_definition.create_by IS '创建人';
COMMENT ON COLUMN job_definition.update_by IS '修改人';
COMMENT ON COLUMN job_definition.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN job_definition.remark IS '备注';
COMMENT ON COLUMN job_definition.gmt_create IS '创建时间';
COMMENT ON COLUMN job_definition.gmt_modified IS '修改时间';

-- ----------------------------
-- 业务任务执行日志
-- ----------------------------

DROP TABLE IF EXISTS job_exec_log CASCADE;
CREATE TABLE job_exec_log (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  job_id          BIGINT NOT NULL,
  xxl_log_id      BIGINT          DEFAULT NULL,
  status          SMALLINT NOT NULL DEFAULT 0,
  trigger_time    TIMESTAMP                 DEFAULT NULL,
  finish_time     TIMESTAMP                 DEFAULT NULL,
  cost_ms         BIGINT          DEFAULT NULL,
  result_msg      VARCHAR(2000)            DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_job_exec_log PRIMARY KEY (id)
);
COMMENT ON TABLE job_exec_log IS '业务任务执行日志表';
COMMENT ON COLUMN job_exec_log.id IS '主键';
COMMENT ON COLUMN job_exec_log.tenant_id IS '租户ID';
COMMENT ON COLUMN job_exec_log.job_id IS '任务定义ID';
COMMENT ON COLUMN job_exec_log.xxl_log_id IS 'XXL-JOB日志ID';
COMMENT ON COLUMN job_exec_log.status IS '状态：0执行中 1成功 2失败';
COMMENT ON COLUMN job_exec_log.trigger_time IS '触发时间';
COMMENT ON COLUMN job_exec_log.finish_time IS '完成时间';
COMMENT ON COLUMN job_exec_log.cost_ms IS '耗时，单位毫秒';
COMMENT ON COLUMN job_exec_log.result_msg IS '结果摘要';
COMMENT ON COLUMN job_exec_log.gmt_create IS '创建时间';
COMMENT ON COLUMN job_exec_log.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_job_create ON job_exec_log (job_id, gmt_create);

-- ----------------------------
-- 监控告警规则
-- ----------------------------

DROP TABLE IF EXISTS monitor_alert_rule CASCADE;
CREATE TABLE monitor_alert_rule (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  rule_code       VARCHAR(64)     NOT NULL,
  rule_name       VARCHAR(128)    NOT NULL,
  metric_expr     VARCHAR(1000)   NOT NULL,
  severity        VARCHAR(16)     NOT NULL DEFAULT 'critical',
  notify_channel  VARCHAR(255)             DEFAULT NULL,
  notify_targets  VARCHAR(1000)            DEFAULT NULL,
  status          SMALLINT NOT NULL DEFAULT 1,
  create_by       BIGINT          DEFAULT NULL,
  update_by       BIGINT          DEFAULT NULL,
  is_deleted      SMALLINT NOT NULL DEFAULT 0,
  remark          VARCHAR(500)             DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_monitor_alert_rule PRIMARY KEY (id),
  CONSTRAINT uk_tenant_rule_code UNIQUE (tenant_id, rule_code)
);
COMMENT ON TABLE monitor_alert_rule IS '监控告警规则表';
COMMENT ON COLUMN monitor_alert_rule.id IS '主键';
COMMENT ON COLUMN monitor_alert_rule.tenant_id IS '租户ID';
COMMENT ON COLUMN monitor_alert_rule.rule_code IS '规则编码';
COMMENT ON COLUMN monitor_alert_rule.rule_name IS '规则名称';
COMMENT ON COLUMN monitor_alert_rule.metric_expr IS '指标表达式或PromQL';
COMMENT ON COLUMN monitor_alert_rule.severity IS '级别：info/warn/critical';
COMMENT ON COLUMN monitor_alert_rule.notify_channel IS '通知渠道：mail,dingtalk,webhook';
COMMENT ON COLUMN monitor_alert_rule.notify_targets IS '通知目标';
COMMENT ON COLUMN monitor_alert_rule.status IS '状态：0停用 1正常';
COMMENT ON COLUMN monitor_alert_rule.create_by IS '创建人';
COMMENT ON COLUMN monitor_alert_rule.update_by IS '修改人';
COMMENT ON COLUMN monitor_alert_rule.is_deleted IS '是否删除：0否 1是';
COMMENT ON COLUMN monitor_alert_rule.remark IS '备注';
COMMENT ON COLUMN monitor_alert_rule.gmt_create IS '创建时间';
COMMENT ON COLUMN monitor_alert_rule.gmt_modified IS '修改时间';

-- ----------------------------
-- 监控告警记录
-- ----------------------------

DROP TABLE IF EXISTS monitor_alert_record CASCADE;
CREATE TABLE monitor_alert_record (
  id              BIGINT NOT NULL,
  tenant_id       BIGINT NOT NULL DEFAULT 0,
  rule_id         BIGINT NOT NULL,
  alert_title     VARCHAR(255)    NOT NULL,
  alert_content   TEXT,
  severity        VARCHAR(16)     NOT NULL DEFAULT 'critical',
  status          SMALLINT NOT NULL DEFAULT 0,
  fired_time      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  resolved_time   TIMESTAMP                 DEFAULT NULL,
  gmt_create      TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_monitor_alert_record PRIMARY KEY (id)
);
COMMENT ON TABLE monitor_alert_record IS '监控告警记录表';
COMMENT ON COLUMN monitor_alert_record.id IS '主键';
COMMENT ON COLUMN monitor_alert_record.tenant_id IS '租户ID';
COMMENT ON COLUMN monitor_alert_record.rule_id IS '规则ID';
COMMENT ON COLUMN monitor_alert_record.alert_title IS '告警标题';
COMMENT ON COLUMN monitor_alert_record.alert_content IS '告警内容';
COMMENT ON COLUMN monitor_alert_record.severity IS '级别：info/warn/critical';
COMMENT ON COLUMN monitor_alert_record.status IS '状态：0待处理 1已确认 2已关闭';
COMMENT ON COLUMN monitor_alert_record.fired_time IS '触发时间';
COMMENT ON COLUMN monitor_alert_record.resolved_time IS '恢复时间';
COMMENT ON COLUMN monitor_alert_record.gmt_create IS '创建时间';
COMMENT ON COLUMN monitor_alert_record.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_rule_fired ON monitor_alert_record (rule_id, fired_time);

\echo === 07_nova_demo.sql ===
-- =========================================================
-- NovaCloud PostgreSQL 脚本（由 MySQL 版对照生成）
-- 源文件: sql/07_nova_demo.sql
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
-- nova-demo：分表示例（ShardingSphere 逻辑表 demo_order）
-- 规范：阿里巴巴 Java 开发手册 2.0 建表规约（无外键）
-- =========================================================

DROP TABLE IF EXISTS demo_order_0 CASCADE;
CREATE TABLE demo_order_0 (
  id            BIGINT NOT NULL,
  user_id       BIGINT NOT NULL,
  order_no      VARCHAR(64)     NOT NULL,
  amount        DECIMAL(18, 2)  NOT NULL DEFAULT 0.00,
  status        SMALLINT NOT NULL DEFAULT 0,
  gmt_create    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified  TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_demo_order_0 PRIMARY KEY (id),
  CONSTRAINT uk_demo_order0_order_no UNIQUE (order_no)
);
COMMENT ON TABLE demo_order_0 IS '演示订单分表0';
COMMENT ON COLUMN demo_order_0.id IS '主键';
COMMENT ON COLUMN demo_order_0.user_id IS '用户ID（分片键）';
COMMENT ON COLUMN demo_order_0.order_no IS '订单号';
COMMENT ON COLUMN demo_order_0.amount IS '金额';
COMMENT ON COLUMN demo_order_0.status IS '状态：0待支付 1已支付 2已取消';
COMMENT ON COLUMN demo_order_0.gmt_create IS '创建时间';
COMMENT ON COLUMN demo_order_0.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_demo_order0_user_id ON demo_order_0 (user_id);

DROP TABLE IF EXISTS demo_order_1 CASCADE;
CREATE TABLE demo_order_1 (
  id            BIGINT NOT NULL,
  user_id       BIGINT NOT NULL,
  order_no      VARCHAR(64)     NOT NULL,
  amount        DECIMAL(18, 2)  NOT NULL DEFAULT 0.00,
  status        SMALLINT NOT NULL DEFAULT 0,
  gmt_create    TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  gmt_modified  TIMESTAMP        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_demo_order_1 PRIMARY KEY (id),
  CONSTRAINT uk_demo_order1_order_no UNIQUE (order_no)
);
COMMENT ON TABLE demo_order_1 IS '演示订单分表1';
COMMENT ON COLUMN demo_order_1.id IS '主键';
COMMENT ON COLUMN demo_order_1.user_id IS '用户ID（分片键）';
COMMENT ON COLUMN demo_order_1.order_no IS '订单号';
COMMENT ON COLUMN demo_order_1.amount IS '金额';
COMMENT ON COLUMN demo_order_1.status IS '状态：0待支付 1已支付 2已取消';
COMMENT ON COLUMN demo_order_1.gmt_create IS '创建时间';
COMMENT ON COLUMN demo_order_1.gmt_modified IS '修改时间';
CREATE INDEX IF NOT EXISTS idx_demo_order1_user_id ON demo_order_1 (user_id);

\echo === 99_init_data.sql ===
-- =========================================================
-- NovaCloud PostgreSQL 脚本（由 MySQL 版对照生成）
-- 源文件: sql/99_init_data.sql
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
-- NovaCloud 初始化数据（开发环境）
-- 默认账号：admin / admin123
-- =========================================================
-- 平台租户
INSERT INTO sys_tenant
(id, tenant_code, tenant_name, contact_name, status, is_deleted, remark)
VALUES
(1, 'platform', '平台租户', 'admin', 1, 0, '系统默认租户');

-- 根部门
INSERT INTO sys_dept
(id, tenant_id, parent_id, ancestors, dept_name, dept_code, sort, status, is_deleted)
VALUES
(100, 1, 0, '0', 'NovaCloud', 'NOVA', 0, 1, 0),
(101, 1, 100, '0,100', '研发中心', 'RD', 1, 1, 0),
(102, 1, 100, '0,100', '运营中心', 'OPS', 2, 1, 0);

-- 岗位
INSERT INTO sys_post
(id, tenant_id, post_code, post_name, sort, status, is_deleted)
VALUES
(1, 1, 'ceo', '董事长', 1, 1, 0),
(2, 1, 'se', '项目经理', 2, 1, 0),
(3, 1, 'dev', '开发工程师', 3, 1, 0);

-- 超级管理员（密码 admin123，BCrypt）
INSERT INTO sys_user
(id, tenant_id, dept_id, username, password, nickname, real_name, email, user_type, status, is_deleted, remark)
VALUES
(1, 1, 100, 'admin',
 '$2a$10$jzJqz6b8fJ.4GHPlybfgx.J3p1/7PsbBwA71JFoi08buJnOD5OXMu',
 '超级管理员', '管理员', 'admin@nova.local', 9, 1, 0, '默认超管，请尽快修改密码');

-- 角色
INSERT INTO sys_role
(id, tenant_id, role_code, role_name, data_scope, sort, status, is_deleted, remark)
VALUES
(1, 1, 'super_admin', '超级管理员', 1, 1, 1, 0, '拥有所有权限'),
(2, 1, 'tenant_admin', '租户管理员', 1, 2, 1, 0, '租户内管理员'),
(3, 1, 'common', '普通用户', 5, 3, 1, 0, '默认普通角色');

INSERT INTO sys_user_role (id, user_id, role_id) VALUES (1, 1, 1);
INSERT INTO sys_user_post (id, user_id, post_id) VALUES (1, 1, 1);

-- 基础菜单
INSERT INTO sys_menu
(id, parent_id, menu_name, menu_type, path, component, permission, icon, sort, is_visible, status, is_frame, is_cache, is_deleted)
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

INSERT INTO sys_role_menu (id, role_id, menu_id)
SELECT id, 1, id FROM sys_menu;

INSERT INTO sys_dict_type
(id, tenant_id, dict_name, dict_type, status, is_deleted, remark)
VALUES
(1, 0, '用户性别', 'sys_user_sex', 1, 0, NULL),
(2, 0, '系统状态', 'sys_common_status', 1, 0, NULL),
(3, 0, '文件上传状态', 'file_upload_status', 1, 0, NULL),
(4, 0, 'AI任务状态', 'ai_task_status', 1, 0, NULL);

INSERT INTO sys_dict_data
(id, tenant_id, dict_type, dict_label, dict_value, sort, status, is_deleted)
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

INSERT INTO sys_config
(id, tenant_id, config_name, config_key, config_value, is_system, is_deleted, remark)
VALUES
(1, 0, '账号初始密码', 'sys.user.initPassword', 'admin123', 1, 0, '用户管理-账号初始密码'),
(2, 0, '用户注册开关', 'sys.account.registerEnabled', 'false', 1, 0, '是否开放注册'),
(3, 0, '验证码开关', 'sys.account.captchaEnabled', 'true', 1, 0, '登录是否校验验证码');

-- 默认本地存储
INSERT INTO file_storage
(id, tenant_id, storage_code, storage_name, storage_type, base_path, is_default, status, is_deleted, remark)
VALUES
(1, 0, 'local', '本地存储', 'local', '/data/nova/files', 1, 1, 0, '开发默认本地磁盘');

-- AI 模型提供商 / 模型 / 默认 Agent（API Key 请在后台填写，或设置环境变量 DASHSCOPE_API_KEY）
INSERT INTO ai_model_provider
(id, tenant_id, provider_code, provider_name, base_url, api_key_cipher, status, is_deleted, remark)
VALUES
(1, 0, 'dashscope', '阿里云百炼 DashScope', NULL, NULL, 1, 0, 'API Key 优先读库，为空则读环境变量 DASHSCOPE_API_KEY'),
(2, 0, 'openai', 'OpenAI 兼容', 'https://api.openai.com/v1', NULL, 1, 0, '可用于 OpenAI / DeepSeek 等兼容端点'),
(3, 0, 'ollama', 'Ollama 本地', 'http://127.0.0.1:11434', NULL, 1, 0, '本地模型');

INSERT INTO ai_model
(id, tenant_id, provider_id, model_code, model_name, model_type, max_tokens, status, is_deleted, remark)
VALUES
(1, 0, 1, 'dashscope:qwen-plus', '通义千问 Plus', 'chat', 2048, 1, 0, '默认对话模型'),
(2, 0, 1, 'dashscope:qwen-turbo', '通义千问 Turbo', 'chat', 2048, 1, 0, NULL),
(3, 0, 3, 'ollama:llama3', 'Llama3 本地', 'chat', 2048, 1, 0, NULL);

INSERT INTO ai_agent
(id, tenant_id, agent_code, agent_name, model_id, sys_prompt, workspace_path, status, is_deleted, remark)
VALUES
(1, 0, 'default', '默认助手', 1,
 '你是 NovaCloud 平台助手，回答简洁准确，使用中文。',
 './work/agentscope/workspace', 1, 0, 'Harness 多轮会话默认 Agent');

-- 默认 OAuth2 客户端（密钥请在生产环境重新生成）
INSERT INTO auth_client
(id, tenant_id, client_id, client_secret, client_name, authorization_grant_types,
 redirect_uris, scopes, is_require_consent, access_token_ttl, refresh_token_ttl, status, is_deleted, remark)
VALUES
(1, 0, 'nova-web',
 '$2a$10$jzJqz6b8fJ.4GHPlybfgx.J3p1/7PsbBwA71JFoi08buJnOD5OXMu',
 'NovaCloud Web',
 'authorization_code,refresh_token,client_credentials',
 'http://127.0.0.1:5173/callback',
 'openid,profile,api',
 0, 7200, 604800, 1, 0, '前端开发客户端');

