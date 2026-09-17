# Nova AI 简单能力说明

基于 [AgentScope Java 2.0 Quickstart](https://java.agentscope.io/v2/zh/docs/quickstart) 落地两套方案，模型均从 `ai_model_provider` / `ai_model` 表读取（管理接口可改）。

## 方案 A：ReAct 简单问答

- 类：`ReActAgent`
- 接口：
  - `POST /ai/chat` 同步
  - `POST /ai/chat/stream` SSE 流式
- 请求示例：

```json
{
  "modelCode": "dashscope:qwen-plus",
  "prompt": "用一句话介绍 NovaCloud",
  "sysPrompt": "你是简洁助手"
}
```

## 方案 B：Harness 多轮会话

- 类：`HarnessAgent`（工作区 + 会话压缩 + RuntimeContext）
- 接口：
  - `POST /ai/agent/chat`
  - `POST /ai/agent/chat/stream`（SSE，每条事件为 `ChatResponse`，`content` 为增量文本）
  - `GET /ai/agent/session/list`
  - `GET /ai/agent/session/{sessionPk}/messages`
- 请求示例：

```json
{
  "agentCode": "default",
  "sessionId": "demo-001",
  "userId": 1,
  "prompt": "我叫小白，记住我。"
}
```

同 `sessionId` 下一轮可继续问「我叫什么？」

## 模型配置

1. `POST /ai/model/provider` 写入 `apiKeyCipher`
2. 或环境变量 `DASHSCOPE_API_KEY` / `OPENAI_API_KEY`
3. `POST /ai/model` 维护模型编码（建议 `provider:modelName`）

## 启动

```bash
mvn -pl nova-ai/nova-ai-server -am -DskipTests package
java -jar nova-ai/nova-ai-server/target/nova-ai-server-1.0-SNAPSHOT.jar
```

网关：`/ai/**` → `lb://nova-ai-server`（端口 8085）
