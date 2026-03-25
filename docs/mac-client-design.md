# OpenClaw AI Agent Mac 客户端设计方案

## 1. 目标
- 提供一个 **原生 macOS 桌面端**，承载 OpenClaw Agent 对话与任务执行。
- 支持流式回复、工具调用状态展示、历史会话、快捷键唤起。
- 确保后续可扩展到多 Agent、插件市场和企业级鉴权。

## 2. 架构分层

### 2.1 展示层（SwiftUI）
- `MainWindowView`：主界面，包含会话侧栏、消息列表、输入区。
- `MessageRowView`：消息单元，区分 user/assistant/system/tool。
- `ToolRunBadgeView`：展示工具调用状态（running/success/error）。

### 2.2 业务层（ViewModel）
- `ChatViewModel`：
  - 维护消息状态、输入状态、发送中状态。
  - 触发 `sendMessage` / `cancelStreaming`。
  - 将 SSE 流式增量拼接到 assistant 消息。

### 2.3 服务层（API + 基础设施）
- `OpenClawAPIClient`：
  - 通过 `URLSession` 调用 OpenClaw Agent API。
  - 支持普通请求与流式请求（`URLSession.bytes` + 行解析）。
- `SecureStore`（后续）
  - 将 API Key 放入 Keychain，避免明文存储。

### 2.4 数据层
- `ChatMessage`：消息实体。
- `Conversation`：会话实体（后续接入 SQLite/CoreData）。

## 3. 核心用户流程
1. 用户输入问题。
2. `ChatViewModel.send()` 写入 user 消息。
3. 调用 `OpenClawAPIClient.streamChat()`。
4. 按 token 增量更新 assistant 消息。
5. 若出现 tool_call 事件，在消息流中显示工具状态。
6. 完成后归档到本地会话。

## 4. API 协议建议

### 请求
- `POST /v1/agent/chat`
- Body:
  - `model`
  - `messages[]`
  - `stream: true`
  - `workspace`

### 流式事件（SSE）
- `event: delta`：文本增量
- `event: tool_call`：工具调用开始/结束
- `event: done`：流结束
- `event: error`：错误

## 5. 安全与可靠性
- Keychain 保存 token。
- 请求超时与指数退避重试。
- 统一错误域：网络错误、服务错误、解析错误。
- 离线提示与重连按钮。

## 6. MVP 里程碑

### M1（本次代码骨架）
- SwiftUI 主界面
- 消息模型
- ChatViewModel
- OpenClaw API Client（流式接口定义）

### M2
- 真正 SSE 解析
- 会话持久化
- 设置页（endpoint/token/model）

### M3
- 工具调用可视化
- 全局快捷键唤起
- 菜单栏模式
