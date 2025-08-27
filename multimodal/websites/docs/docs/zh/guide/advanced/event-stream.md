# Event Stream

Agent TARS 的核心是事件驱动架构，通过 Event Stream 记录和管理 Agent 运行过程中的所有状态变化。Event Stream 不仅用于构建对话历史，还为实时 UI 更新、调试分析和状态监控提供统一的数据源。

## 架构概览

Event Stream 采用发布-订阅模式，支持以下核心功能：

- **事件创建与发送**：统一的事件格式和发送机制
- **实时订阅**：支持按类型订阅特定事件
- **历史查询**：按类型和时间范围查询历史事件
- **流式处理**：支持实时流式事件的增量更新
- **内存管理**：自动清理历史事件，防止内存溢出

## 事件类型

### 基础事件结构

所有事件都继承自 `BaseEvent`：

```typescript
interface BaseEvent {
  id: string;        // 唯一标识符
  type: string;      // 事件类型
  timestamp: number; // 时间戳（毫秒）
}
```

### 对话流事件

#### UserMessageEvent

用户输入事件，支持文本和多模态内容：

```typescript
interface UserMessageEvent extends BaseEvent {
  type: 'user_message';
  content: string | ChatCompletionContentPart[];
}
```

示例：
```json
{
  "id": "f5c8c06e-b676-49aa-bb13-73f5c36bd1f4",
  "type": "user_message",
  "timestamp": 1748329959480,
  "content": "Why has Tesla's stock price recently fallen?"
}
```

#### AssistantMessageEvent

Assistant 完整响应事件：

```typescript
interface AssistantMessageEvent extends BaseEvent {
  type: 'assistant_message';
  content: string;                              // 响应内容
  rawContent?: string;                          // 原始响应内容
  toolCalls?: ChatCompletionMessageToolCall[];  // 工具调用
  finishReason?: string;                        // 结束原因
  elapsedMs?: number;                          // 耗时
  messageId?: string;                          // 消息ID，用于关联流式事件
}
```

#### AssistantStreamingMessageEvent

实时流式响应事件，用于增量更新：

```typescript
interface AssistantStreamingMessageEvent extends BaseEvent {
  type: 'assistant_streaming_message';
  content: string;      // 增量内容片段
  isComplete?: boolean; // 是否完成
  messageId?: string;   // 关联的消息ID
}
```

流式事件示例：
```json
[
  {
    "id": "ab4c2ea6-3bb4-4a02-9402-b87f376f5d97",
    "type": "assistant_streaming_message",
    "timestamp": 1748329963848,
    "content": "Starting",
    "isComplete": false,
    "messageId": "msg_1748329963755_c90x1ktc"
  },
  {
    "id": "2fe5f568-9ee5-4e30-afad-ced9e20d37ac",
    "type": "assistant_streaming_message",
    "timestamp": 1748329963859,
    "content": " research",
    "isComplete": false,
    "messageId": "msg_1748329963755_c90x1ktc"
  }
]
```

#### AssistantStreamingToolCallEvent

实时工具调用构建事件：

```typescript
interface AssistantStreamingToolCallEvent extends BaseEvent {
  type: 'assistant_streaming_tool_call';
  toolCallId: string;  // 工具调用ID
  toolName: string;    // 工具名称
  arguments: string;   // 增量参数（仅包含本次更新的部分）
  isComplete: boolean; // 是否完成
  messageId?: string;  // 关联的消息ID
}
```

> **设计说明**：`arguments` 字段采用增量设计，客户端需要累积这些增量来构建完整参数。这种设计优化了大型工具调用（如 `write_file`）的性能。

### 工具执行事件

#### ToolCallEvent

工具调用开始事件：

```typescript
interface ToolCallEvent extends BaseEvent {
  type: 'tool_call';
  toolCallId: string;     // 工具调用ID
  name: string;           // 工具名称
  arguments: Record<string, any>; // 工具参数
  startTime: number;      // 开始时间
  tool: {                 // 工具元数据
    name: string;
    description: string;
    schema: any;
  };
}
```

#### ToolResultEvent

工具执行结果事件：

```typescript
interface ToolResultEvent extends BaseEvent {
  type: 'tool_result';
  toolCallId: string;                       // 对应的工具调用ID
  name: string;                            // 工具名称
  content: any;                            // 执行结果
  processedContent?: ChatCompletionContentPart[]; // 处理后的多模态内容
  elapsedMs: number;                       // 执行耗时
  error?: string;                          // 错误信息
  _extra?: any;                           // 内部状态（不建议依赖）
}
```

> **FIXME**：`processedContent` 字段当前未在消息历史中设置值，需要完善。`_extra` 字段为临时解决方案，应该用长期方案替代。

### Agent 生命周期事件

#### AgentRunStartEvent

Agent 执行开始事件：

```typescript
interface AgentRunStartEvent extends BaseEvent {
  type: 'agent_run_start';
  sessionId: string;                    // 会话ID
  runOptions: AgentRunObjectOptions;    // 运行选项
  provider?: string;                    // 模型提供商
  model?: string;                       // 模型标识
  modelDisplayName?: string;            // 模型显示名称
  agentName?: string;                   // Agent 名称
}
```

#### AgentRunEndEvent

Agent 执行结束事件：

```typescript
interface AgentRunEndEvent extends BaseEvent {
  type: 'agent_run_end';
  sessionId: string;    // 会话ID
  iterations: number;   // 执行轮次
  elapsedMs: number;    // 总耗时
  status: AgentStatus;  // 最终状态
}
```

> **注意**：当前 `AgentRunEndEvent` 存在 Bug，示例数据缺失，需要修复。

### 规划事件

#### PlanStartEvent

规划开始事件：

```typescript
interface PlanStartEvent extends BaseEvent {
  type: 'plan_start';
  sessionId: string; // 会话ID
}
```

#### PlanUpdateEvent

规划更新事件：

```typescript
interface PlanUpdateEvent extends BaseEvent {
  type: 'plan_update';
  sessionId: string;     // 会话ID
  steps: PlanStep[];     // 规划步骤
}

interface PlanStep {
  content: string;  // 步骤描述
  done: boolean;    // 是否完成
}
```

示例：
```json
{
  "id": "06a53251-0c7e-4660-8393-935210dd86f5",
  "type": "plan_update",
  "timestamp": 1748329962770,
  "sessionId": "1748329959477-3kle208",
  "steps": [
    {
      "content": "Research recent news and events related to Tesla",
      "done": false
    },
    {
      "content": "Analyze market trends and broader economic factors",
      "done": false
    }
  ]
}
```

#### PlanFinishEvent

规划完成事件：

```typescript
interface PlanFinishEvent extends BaseEvent {
  type: 'plan_finish';
  sessionId: string; // 会话ID
  summary: string;   // 规划总结
}
```

### 系统事件

#### SystemEvent

系统日志和通知事件：

```typescript
interface SystemEvent extends BaseEvent {
  type: 'system';
  level: 'info' | 'warning' | 'error'; // 日志级别
  message: string;                      // 消息内容
  details?: Record<string, any>;        // 详细信息
}
```

> **注意**：当前存在滥用 `system` 事件传递规划信息的情况，应该使用专门的规划事件类型。

### 最终答案事件

#### FinalAnswerEvent

结构化最终答案事件：

```typescript
interface FinalAnswerEvent extends BaseEvent {
  type: 'final_answer';
  content: string;         // 最终答案内容
  isDeepResearch: boolean; // 是否来自深度研究
  title?: string;          // 可选标题
  format?: string;         // 格式（如 'markdown', 'json'）
  messageId?: string;      // 关联的消息ID
}
```

#### FinalAnswerStreamingEvent

流式最终答案事件：

```typescript
interface FinalAnswerStreamingEvent extends BaseEvent {
  type: 'final_answer_streaming';
  content: string;         // 增量内容
  isDeepResearch: boolean; // 是否来自深度研究
  isComplete?: boolean;    // 是否完成
  messageId?: string;      // 关联的消息ID
}
```

## 事件处理器

### AgentEventStreamProcessor

事件流处理器提供完整的事件管理功能：

```typescript
class AgentEventStreamProcessor implements AgentEventStream.Processor {
  // 创建事件
  createEvent<T extends EventType>(
    type: T,
    data: Omit<EventPayload<T>, keyof BaseEvent>
  ): EventPayload<T>

  // 发送事件
  sendEvent(event: Event): void

  // 查询事件
  getEvents(filter?: EventType[], limit?: number): Event[]
  getEventsByType(types: EventType[], limit?: number): Event[]
  getLatestToolResults(): { toolCallId: string; toolName: string; content: any }[]

  // 订阅事件
  subscribe(callback: (event: Event) => void): () => void
  subscribeToTypes(types: EventType[], callback: (event: Event) => void): () => void
  subscribeToStreamingEvents(callback: (event: StreamingEvent) => void): () => void

  // 清理资源
  dispose(): void
}
```

### 配置选项

```typescript
interface ProcessorOptions {
  maxEvents?: number;   // 最大事件数量（默认1000）
  autoTrim?: boolean;   // 自动清理（默认true）
}
```

## 使用模式

### 基础用法

```typescript
// 创建事件流处理器
const processor = new AgentEventStreamProcessor({
  maxEvents: 1000,
  autoTrim: true
});

// 创建并发送事件
const userEvent = processor.createEvent('user_message', {
  content: 'Hello, Agent TARS!'
});
processor.sendEvent(userEvent);

// 订阅事件
const unsubscribe = processor.subscribe((event) => {
  console.log(`New event: ${event.type}`);
});

// 查询历史事件
const messages = processor.getEventsByType(['user_message', 'assistant_message']);
```

### 流式事件处理

```typescript
// 订阅流式事件
processor.subscribeToStreamingEvents((event) => {
  switch (event.type) {
    case 'assistant_streaming_message':
      // 更新UI显示增量内容
      updateMessageContent(event.messageId, event.content);
      break;
    case 'assistant_streaming_tool_call':
      // 累积工具调用参数
      accumulateToolCallArgs(event.toolCallId, event.arguments);
      break;
  }
});
```

### 工具结果查询

```typescript
// 获取最新的工具执行结果
const toolResults = processor.getLatestToolResults();
toolResults.forEach(result => {
  console.log(`Tool ${result.toolName}: ${result.content}`);
});
```

## 最佳实践

### 1. 事件关联

使用 `messageId` 字段关联流式事件和最终事件：

```typescript
// 流式事件
{ type: 'assistant_streaming_message', messageId: 'msg_123', content: 'Hello' }
{ type: 'assistant_streaming_message', messageId: 'msg_123', content: ' world' }

// 最终事件
{ type: 'assistant_message', messageId: 'msg_123', content: 'Hello world' }
```

### 2. 错误处理

始终检查 `ToolResultEvent` 的 `error` 字段：

```typescript
processor.subscribeToTypes(['tool_result'], (event) => {
  const toolResult = event as AgentEventStream.ToolResultEvent;
  if (toolResult.error) {
    console.error(`Tool ${toolResult.name} failed: ${toolResult.error}`);
  }
});
```

### 3. 内存管理

合理配置事件数量限制：

```typescript
// 长期运行的Agent
const processor = new AgentEventStreamProcessor({
  maxEvents: 500,    // 减少内存占用
  autoTrim: true     // 自动清理
});

// 调试场景
const debugProcessor = new AgentEventStreamProcessor({
  maxEvents: 10000,  // 保留更多历史
  autoTrim: false    // 手动控制
});
```

### 4. 性能优化

避免在订阅回调中执行耗时操作：

```typescript
// ❌ 不推荐
processor.subscribe((event) => {
  // 同步的耗时操作
  heavyProcessing(event);
});

// ✅ 推荐
processor.subscribe((event) => {
  // 异步处理
  setTimeout(() => heavyProcessing(event), 0);
});
```

## 扩展机制

### 自定义事件类型

通过模块扩展添加自定义事件：

```typescript
// 扩展事件映射
declare module '@tarko/agent-interface' {
  namespace AgentEventStream {
    interface ExtendedEventMapping {
      custom_event: CustomEvent;
    }
  }
}

interface CustomEvent extends AgentEventStream.BaseEvent {
  type: 'custom_event';
  customData: string;
}
```

### 事件中间件

```typescript
class EventMiddleware {
  constructor(private processor: AgentEventStreamProcessor) {
    // 拦截所有事件
    processor.subscribe(this.handleEvent.bind(this));
  }

  private handleEvent(event: AgentEventStream.Event) {
    // 添加自定义逻辑
    if (event.type === 'tool_call') {
      this.logToolCall(event as AgentEventStream.ToolCallEvent);
    }
  }

  private logToolCall(event: AgentEventStream.ToolCallEvent) {
    console.log(`Tool called: ${event.name} with args:`, event.arguments);
  }
}
```

## 故障排查

### 常见问题

1. **事件丢失**：检查 `maxEvents` 配置和 `autoTrim` 设置
2. **内存泄漏**：确保调用 `dispose()` 清理资源
3. **订阅失效**：保存并正确调用取消订阅函数
4. **流式事件乱序**：使用 `messageId` 进行事件关联

### 调试技巧

```typescript
// 开启详细日志
const processor = new AgentEventStreamProcessor();
processor.subscribe((event) => {
  console.log(`[${new Date(event.timestamp).toISOString()}] ${event.type}:`, event);
});

// 统计事件类型
const stats = new Map<string, number>();
processor.subscribe((event) => {
  stats.set(event.type, (stats.get(event.type) || 0) + 1);
  console.log('Event stats:', Object.fromEntries(stats));
});
```

Event Stream 是 Agent TARS 的核心基础设施，理解其设计原理和使用模式对于开发高质量的 Agent 应用至关重要。通过合理使用事件订阅和查询功能，可以构建响应式的用户界面和强大的调试工具。
