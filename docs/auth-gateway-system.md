# NovaCloud 认证 / 网关 / 系统权限

## 服务端口

| 服务 | 端口 | 说明 |
|------|------|------|
| nova-gateway | 8080 | Token 鉴权 + SM3/SM4 开关 |
| nova-system | 8081 | 用户/角色/菜单 |
| nova-auth | 9000 | OAuth2 认证中心 + 业务登录 |

## 认证接口（nova-auth）

```http
POST /auth/code/email
{"email":"admin@nova.local","scene":"login"}

POST /auth/login/password
{"username":"admin","password":"admin123"}

POST /auth/login/email
{"email":"admin@nova.local","code":"123456"}
```

标准 OAuth2（Authorization Server）：
- `/oauth2/authorize`
- `/oauth2/token`（client: `nova-web` / `nova-web-secret`）
- `/.well-known/oauth-authorization-server`

## 网关

- Token：`Authorization: Bearer <access_token>`
- 白名单：`/auth/**`、`/oauth2/**` 等
- 国密开关：`nova.crypto.enabled`
  - `false`：明文
  - `true`：请求体 SM4(hex) 解密，响应体 SM4 加密，SM3 签名头 `X-Nova-Sign`
  - 单次明文：请求头 `X-Nova-Encrypt: 0`

## 系统权限（经网关）

```http
GET /system/user/info
Authorization: Bearer <token>

GET /system/user/page?current=1&size=10
GET /system/role/list
GET /system/menu/list
```

网关会把用户信息透传到下游：
- `X-User-Id` / `X-Username` / `X-Tenant-Id` / `X-Authorities`
