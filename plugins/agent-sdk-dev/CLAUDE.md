[根目录](../../CLAUDE.md) > [plugins](../) > **agent-sdk-dev**

# Agent SDK Development Plugin

## 模块职责

简化 Claude Agent SDK 应用程序的开发流程，提供脚手架命令和验证代理，帮助开发者快速创建和验证符合最佳实践的 SDK 应用程序。

## 入口与启动

### 插件元数据
- **配置文件**: `.claude-plugin/plugin.json`
- **版本**: 1.0.0
- **作者**: Ashwin Bhat (ashwin@anthropic.com)

### 核心组件结构
```
agent-sdk-dev/
├── .claude-plugin/plugin.json    # 插件元数据
├── README.md                     # 插件文档
├── commands/                     # 斜杠命令
│   └── new-sdk-app.md           # 新建 SDK 应用命令
└── agents/                       # 专用代理
    ├── agent-sdk-verifier-py.md # Python SDK 验证代理
    └── agent-sdk-verifier-ts.md # TypeScript SDK 验证代理
```

## 对外接口

### 主要命令
- **`/new-sdk-app`**: 交互式设置新的 Agent SDK 项目
  - 支持项目模板选择
  - 自动生成基础文件结构
  - 配置开发环境

### 验证代理
- **`agent-sdk-verifier-py`**: Python SDK 应用验证
  - 检查代码结构和依赖
  - 验证最佳实践遵循情况
  - 提供改进建议

- **`agent-sdk-verifier-ts`**: TypeScript SDK 应用验证
  - 类型定义检查
  - 模块结构验证
  - 构建配置审核

## 关键依赖与配置

### 依赖要求
- Claude Agent SDK (Python 或 TypeScript)
- Node.js 18+ (用于 TypeScript 项目)
- Python 3.8+ (用于 Python 项目)

### 配置文件
- `plugin.json`: 插件元数据和版本信息
- 命令和代理配置内嵌在各自的 `.md` 文件中

## 数据模型

### 项目模板结构
- **Python 模板**: 标准 Python 包结构，包含 `setup.py`、`requirements.txt`
- **TypeScript 模板**: 现代 Node.js 项目，包含 `package.json`、`tsconfig.json`

### 验证规则模型
- 代码结构规范
- 依赖管理最佳实践
- 错误处理标准
- 文档完整性要求

## 测试与质量

### 质量保证机制
- **静态分析**: 代理检查代码结构和约定
- **最佳实践验证**: 确保遵循 SDK 开发指南
- **模板验证**: 生成的项目模板经过测试

### 测试策略
- 模板生成功能测试
- 验证代理准确性测试
- 跨平台兼容性验证

## 常见问题 (FAQ)

**Q: 如何选择 Python 还是 TypeScript 模板？**
A: 根据项目需求和技术栈选择。Python 适合快速原型和数据处理，TypeScript 适合大型项目和类型安全。

**Q: 验证代理会修改代码吗？**
A: 不会，验证代理只进行分析和建议，不会自动修改代码。

**Q: 可以自定义项目模板吗？**
A: 当前版本使用内置模板，可以通过修改命令定义来扩展功能。

## 相关文件清单

### 核心文件
- `.claude-plugin/plugin.json` - 插件配置
- `README.md` - 详细文档
- `commands/new-sdk-app.md` - 主要命令实现
- `agents/agent-sdk-verifier-py.md` - Python 验证代理
- `agents/agent-sdk-verifier-ts.md` - TypeScript 验证代理

### 文档文件
- `agents/agent-sdk-verifier-py.md` - 包含使用说明和验证标准
- `agents/agent-sdk-verifier-ts.md` - 包含类型检查规则

## 变更记录 (Changelog)

### 2025-11-18 16:43:03 - 初始化文档
- 创建模块级 CLAUDE.md 文档
- 分析插件结构和功能
- 生成导航面包屑和模块说明

---

## 模块覆盖状态

**扫描统计**：
- 总文件数：5
- 已扫描文件数：5
- 覆盖率：100%

**关键文件分析**：
- ✅ plugin.json - 插件元数据完整
- ✅ README.md - 文档详细
- ✅ new-sdk-app.md - 命令定义清晰
- ✅ 验证代理文档 - 功能描述完整

**功能缺口**：无，模块功能完整且文档齐全。