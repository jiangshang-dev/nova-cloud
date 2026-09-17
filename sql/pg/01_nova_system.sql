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
