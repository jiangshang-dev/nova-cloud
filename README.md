# NovaCloud

<p align="center">
  <strong>企业级云原生微服务与智能体开发平台</strong><br/>
  Java 21 · Spring Boot 3 · Spring Cloud Alibaba · AgentScope
</p>

<p align="center">
  <a href="https://github.com/jiangshang-dev/nova-cloud"><img src="https://img.shields.io/badge/GitHub-nova--cloud-181717?style=flat-square&logo=github" alt="GitHub" /></a>
  <img src="https://img.shields.io/badge/Java-21-orange?style=flat-square&logo=openjdk" alt="Java" />
  <img src="https://img.shields.io/badge/Spring%20Boot-3.4.9-6DB33F?style=flat-square&logo=springboot" alt="Spring Boot" />
  <img src="https://img.shields.io/badge/Spring%20Cloud-2024.0.3-6DB33F?style=flat-square&logo=spring" alt="Spring Cloud" />
  <img src="https://img.shields.io/badge/License-MIT-blue?style=flat-square" alt="License" />
</p>

---

> **如果本项目对你有帮助，请点一下右上角 Star。**  
> 微服务底座 + AI 能力持续迭代，Star 是最直接的支持；欢迎学习使用，也请别只白嫖不留痕迹。

## 项目简介

**NovaCloud** 是一套面向企业场景的云原生微服务底座，同时集成智能体（Agent）能力，适合作为中后台 / 低代码 / AI 应用的后端起点。

核心定位：

- **微服务基础设施**：网关、认证授权、系统权限、文件、任务、搜索、监控
- **工程化 Starter**：数据源、MyBatis-Plus、分库分表、MQ、文件、加密、AI 等开箱即用
- **AI 能力**：基于 [AgentScope Java 2.0](https://java.agentscope.io/v2/zh/docs/quickstart) 的对话、RAG、知识库、Agent 等模块

配套前端仓库：[nova-cloud-views](https://github.com/jiangshang-dev/nova-cloud-views)（Vue 3 + Ant Design Vue）

## 技术栈

| 类别 | 选型 |
| --- | --- |
| 语言 / 运行时 | Java 21 |
| 基础框架 | Spring Boot 3.4.9 |
| 微服务 | Spring Cloud 2024.0.3、Spring Cloud Alibaba 2023.0.3.4 |
| 注册 / 配置 | Nacos |
| 网关 / 限流 | Spring Cloud Gateway、Sentinel |
| 认证 | OAuth2.1（Authorization Server） |
| ORM / 数据 | MyBatis-Plus、动态数据源、ShardingSphere |
| 缓存 | Redis / Redisson |
| 消息 | RocketMQ / RabbitMQ |
| 搜索 | Elasticsearch |
| 任务 | XXL-JOB（规划 / 接入中） |
| API 文档 | SpringDoc OpenAPI |
| AI | AgentScope 2.0.1 |
| 安全 | 国密 SM2 / SM3 / SM4 等能力 |
| 多库 | MySQL / PostgreSQL / Oracle / 达梦（可扩展） |

## 功能特性

- **统一认证与权限**：密码 / 邮箱验证码登录，OAuth2 标准端点，网关 Token 鉴权
- **系统管理能力**：租户、用户、角色、菜单、字典、参数、公告等
- **文件服务**：多对象存储适配、大文件分片上传
- **多数据库兼容**：业务侧只选库类型与连接；方言与驱动适配下沉到 Starter
- **分库分表 / 动态数据源**：通过 Starter 接入，业务服务按需启用
- **消息与缓存**：MQ、Redis 统一封装
- **AI 模块**：同步 / SSE 对话、模型配置化、RAG / 知识库 / Agent 等扩展方向
- **可观测与治理**：Sentinel、监控相关 visual 模块预留

## 模块结构

```text
nova-cloud
├── nova-common          # 公共能力（core / redis / security / log / crypto / ai）
├── nova-starters        # 可复用 Spring Boot Starter
├── nova-platform        # 平台服务
│   ├── nova-gateway     # 网关 :8080
│   ├── nova-system      # 系统服务 :8081
│   ├── nova-auth        # 认证中心 :9000
│   ├── nova-file        # 文件服务 :8082
│   └── nova-job         # 任务服务
├── nova-business        # 业务示例（nova-demo :8090）
├── nova-ai              # AI 相关服务与能力
├── nova-search          # 搜索服务
├── nova-nacos           # Nacos 相关
├── nova-visual          # 监控 / Sentinel 等可视化组件
├── sql/                 # 初始化脚本（MySQL / PostgreSQL）
└── docs/                # 快速开始与设计说明
```

## 环境要求

- JDK **21+**
- Maven **3.8+**
- MySQL 8+（或 PostgreSQL，见 `sql/pg`）
- Redis
- Nacos（建议 2.x）
- （可选）RocketMQ / RabbitMQ、Elasticsearch

## 快速开始

### 1. 初始化数据库

```bash
# MySQL：按顺序执行 sql/ 下脚本，或直接执行
mysql -uroot -p < sql/all.sql
```

PostgreSQL 对照脚本见 [`sql/pg/`](./sql/pg/)。

### 2. 启动基础设施

确保本机或 Docker 中已启动：

- Nacos
- Redis
- MySQL / PostgreSQL

并根据环境修改各服务 `application.yml` / Nacos 配置中的连接信息。

### 3. 编译

```bash
mvn clean install -DskipTests
```

### 4. 启动核心服务（示例）

建议顺序：Nacos → Redis → MySQL → **gateway / auth / system** → 业务服务。

```bash
# 系统服务（含 SpringDoc）
mvn -pl nova-platform/nova-system -am spring-boot:run

# 认证中心
mvn -pl nova-platform/nova-auth -am spring-boot:run

# 网关
mvn -pl nova-platform/nova-gateway -am spring-boot:run
```

常用地址：

| 服务 | 地址 |
| --- | --- |
| 网关 | http://127.0.0.1:8080 |
| 系统服务 Swagger | http://127.0.0.1:8081/swagger-ui.html |
| 认证中心 | http://127.0.0.1:9000 |

默认开发账号（以初始化数据为准，常见为）：

```text
username: admin
password: admin123
```

### 5. 前端（可选）

```bash
git clone https://github.com/jiangshang-dev/nova-cloud-views.git
cd nova-cloud-views
pnpm install
pnpm dev
# 默认 http://127.0.0.1:3100
```

## 文档

仓库内文档目录：[`docs/`](./docs/)

| 文档 | 说明 |
| --- | --- |
| [auth-gateway-system.md](./docs/auth-gateway-system.md) | 认证 / 网关 / 系统权限 |
| [datasource-quickstart.md](./docs/datasource-quickstart.md) | 数据源 Starter |
| [sharding-quickstart.md](./docs/sharding-quickstart.md) | 分库分表 |
| [mq-quickstart.md](./docs/mq-quickstart.md) | 消息队列 |
| [ai-quickstart.md](./docs/ai-quickstart.md) | AI 对话能力快速开始 |
| [sql/README.md](./sql/README.md) | 建表规范与脚本说明 |

## AI 能力速览

模型配置从 `ai_model_provider` / `ai_model` 表读取，可通过管理接口维护。

示例（ReAct 问答）：

```http
POST /ai/chat
Content-Type: application/json

{
  "modelCode": "dashscope:qwen-plus",
  "prompt": "用一句话介绍 NovaCloud",
  "sysPrompt": "你是简洁助手"
}
```

流式接口：`POST /ai/chat/stream`（SSE）

更多说明见 [docs/ai-quickstart.md](./docs/ai-quickstart.md)。

## 设计原则（摘要）

1. **业务服务轻量**：业务模块只关心连接哪个库、连到哪里
2. **兼容逻辑下沉 Starter**：方言、驱动、分页、分片等能力统一封装
3. **配置外置**：连接信息、开关优先放 Nacos / 环境配置
4. **表结构规范**：遵循阿里巴巴 Java 开发手册建表约定（详见 `sql/README.md`）

## 路线图（简要）

- [x] 微服务骨架与 BOM 统一管理
- [x] 网关 / 认证 / 系统 / 文件基础能力
- [x] 数据源 / MyBatis / 分片 / MQ 等 Starter
- [x] AI 基础对话（AgentScope）
- [ ] 更完整的低代码编排与可视化设计器
- [ ] 生产级 K8s / 可观测全链路示例
- [ ] 更多国产库与对象存储适配

## 支持与反馈

如果本项目帮到你：

1. **给仓库点 Star**（最重要）
2. 关注公众号「架构师姜小白」获取更新
3. 通过 GitHub Issues 提问题或建议

开源不易，企业级底座更不易。欢迎 Fork / PR，也请留下一个 Star。

## 相关链接

- 后端仓库：https://github.com/jiangshang-dev/nova-cloud
- 前端仓库：https://github.com/jiangshang-dev/nova-cloud-views
- 作者 GitHub：https://github.com/jiangshang-dev?tab=repositories
- 个人博客：https://alibabap8developer.github.io/myblog/

## License

[MIT](./LICENSE)（若仓库尚未添加 LICENSE 文件，以实际开源协议声明为准）

---

**NovaCloud** · 姜小白  
Cloud Native · Microservices · AI Agent
