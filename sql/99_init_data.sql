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
 '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE/sLtTQzR6.6.',
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
(14, 13, '文件管理', 'C', 'list', 'file/index', 'file:info:list', 'list', 1, 1, 1, 0, 0, 0),
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

-- 默认 OAuth2 客户端（密钥请在生产环境重新生成）
INSERT INTO `auth_client`
(`id`, `tenant_id`, `client_id`, `client_secret`, `client_name`, `authorization_grant_types`,
 `redirect_uris`, `scopes`, `is_require_consent`, `access_token_ttl`, `refresh_token_ttl`, `status`, `is_deleted`, `remark`)
VALUES
(1, 0, 'nova-web',
 '$2a$10$7JB720yubVSZvUI0rEqK/.VqGOZTH.ulu33dHOiBE/sLtTQzR6.6.',
 'NovaCloud Web',
 'authorization_code,refresh_token,client_credentials',
 'http://127.0.0.1:5173/callback',
 'openid,profile,api',
 0, 7200, 604800, 1, 0, '前端开发客户端');
