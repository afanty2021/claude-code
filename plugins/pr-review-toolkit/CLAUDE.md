[根目录](../../CLAUDE.md) > [plugins](../) > **pr-review-toolkit**

# PR Review Toolkit Plugin

## 模块职责

提供综合性 Pull Request 审查工具包，使用多个专业化代理对不同代码质量方面进行深度分析，确保高质量的代码合并。

## 入口与启动

### 插件元数据
- **配置文件**: `.claude-plugin/plugin.json`
- **版本**: 1.0.0
- **作者**: Anthropic

### 核心组件结构
```
pr-review-toolkit/
├── .claude-plugin/plugin.json          # 插件元数据
├── README.md                           # 插件文档
├── commands/                           # 斜杠命令
│   └── review-pr.md                   # PR 审查命令
└── agents/                             # 专业化代理
    ├── code-reviewer.md               # 通用代码审查
    ├── code-simplifier.md             # 代码简化
    ├── comment-analyzer.md            # 注释分析
    ├── pr-test-analyzer.md            # 测试分析
    ├── silent-failure-hunter.md       # 静默失败检查
    └── type-design-analyzer.md        # 类型设计分析
```

## 对外接口

### 主要命令
- **`/review-pr [审查方面]`**: 综合 PR 审查
  - 支持特定审查方面参数
  - 自动确定适用的审查类型
  - 生成可操作的审查报告

### 审查方面选项
- **comments**: 代码注释准确性和可维护性
- **tests**: 测试覆盖率和质量完整性
- **errors**: 错误处理中的静默失败
- **types**: 类型设计和不变量（如果添加了新类型）
- **code**: 项目指南的通用代码审查
- **simplify**: 代码简化和可维护性改进
- **all**: 运行所有适用的审查（默认）

## 审查工作流

### 1. 确定审查范围
- 检查 git 状态识别变更文件
- 解析参数确定用户请求的审查方面
- 默认运行所有适用的审查

### 2. 识别变更文件
- 运行 `git diff --name-only` 查看修改的文件
- 检查 PR 是否已存在：`gh pr view`
- 识别文件类型和适用的审查

### 3. 确定适用的审查
根据变更内容确定：
- **始终适用**: code-reviewer（通用质量）
- **测试文件变更**: pr-test-analyzer
- **注释/文档添加**: comment-analyzer
- **错误处理变更**: silent-failure-hunter
- **类型添加/修改**: type-design-analyzer
- **通过审查后**: code-simplifier（抛光和优化）

### 4. 启动审查代理

#### 顺序方法（默认）
- 更容易理解和操作
- 每个报告完整后再进行下一个
- 适合交互式审查

#### 并行方法（用户可请求）
- 同时启动所有代理
- 综合审查速度更快
- 结果一起返回

### 5. 整合结果
```markdown
# PR Review Summary

## Critical Issues (X found)
- [agent-name]: Issue description [file:line]

## Important Issues (X found)
- [agent-name]: Issue description [file:line]

## Suggestions (X found)
- [agent-name]: Suggestion [file:line]

## Strengths
- What's well-done in this PR

## Recommended Action
1. Fix critical issues first
2. Address important issues
3. Consider suggestions
4. Re-run review after fixes
```

## 专业化代理详解

### comment-analyzer - 注释分析器
**功能**: 验证注释与代码的一致性
- 识别注释腐化
- 检查文档完整性
- 确保注释与实际代码匹配

### pr-test-analyzer - 测试分析器
**功能**: 审查行为测试覆盖率
- 识别关键覆盖率缺口
- 评估测试质量
- 检查测试用例的完整性

### silent-failure-hunter - 静默失败猎人
**功能**: 发现静默失败
- 审查 catch 块
- 检查错误日志记录
- 识别被忽略的错误情况

### type-design-analyzer - 类型设计分析器
**功能**: 分析类型封装
- 审查不变量表达
- 评估类型设计质量
- 检查类型安全性

### code-reviewer - 代码审查器
**功能**: 检查 CLAUDE.md 合规性
- 检测错误和问题
- 审查通用代码质量
- 确保项目约定遵循

### code-simplifier - 代码简化器
**功能**: 简化复杂代码
- 提高清晰度和可读性
- 应用项目标准
- 保持功能不变

## 使用示例

### 完整审查（默认）
```bash
/pr-review-toolkit:review-pr
```

### 特定方面审查
```bash
/pr-review-toolkit:review-pr tests errors
# 仅审查测试覆盖率和错误处理

/pr-review-toolkit:review-pr comments
# 仅审查代码注释

/pr-review-toolkit:review-pr simplify
# 简化通过审查后的代码
```

### 并行审查
```bash
/pr-review-toolkit:review-pr all parallel
# 并行启动所有代理
```

## 工作流集成

### 提交前
```bash
1. Write code
2. Run: /pr-review-toolkit:review-pr code errors
3. Fix any critical issues
4. Commit
```

### 创建 PR 前
```bash
1. Stage all changes
2. Run: /pr-review-toolkit:review-pr all
3. Address all critical and important issues
4. Run specific reviews again to verify
5. Create PR
```

### PR 反馈后
```bash
1. Make requested changes
2. Run targeted reviews based on feedback
3. Verify issues are resolved
4. Push updates
```

## 关键依赖与配置

### 依赖要求
- Git 工具 - 用于差异分析
- GitHub CLI (`gh`) - 用于 PR 信息获取
- Claude Code 环境 - 用于代理执行

### 配置参数
- **审查深度**: 可配置代理分析深度
- **并行度**: 支持并行或顺序审查
- **文件过滤**: 可指定特定文件或目录

## 数据模型

### 审查结果模型
```json
{
  "agent": "代理名称",
  "severity": "critical|important|suggestion",
  "category": "审查类别",
  "description": "问题描述",
  "file_path": "文件路径",
  "line_number": 行号,
  "suggestion": "修复建议",
  "confidence": 置信度
}
```

### 报告聚合模型
- **关键问题**: 必须在合并前修复
- **重要问题**: 应该修复的问题
- **建议**: 可选的改进建议
- **优势**: PR 中的优秀实践

## 测试与质量

### 质量保证机制
- **代理专业化**: 每个代理专注特定领域
- **置信度评估**: 代理提供审查结果的置信度
- **多角度审查**: 不同代理从不同角度分析

### 审查标准
- **功能性**: 代码是否正确工作
- **可维护性**: 代码是否易于理解和修改
- **安全性**: 是否存在安全漏洞
- **性能**: 是否存在性能问题
- **约定遵循**: 是否符合项目标准

## 常见问题 (FAQ)

**Q: 如何选择特定审查方面？**
A: 在命令后添加方面参数，如 `/review-pr tests errors`

**Q: 并行审查和顺序审查有什么区别？**
A: 并行更快但结果一次性返回，顺序更循序渐进便于理解和操作。

**Q: 如何处理误报？**
A: 代理通常提供置信度评估，低置信度问题可能是误报。

**Q: 可以自定义审查规则吗？**
A: 可以通过修改代理定义来自定义审查标准和规则。

## 相关文件清单

### 核心文件
- `.claude-plugin/plugin.json` - 插件配置
- `README.md` - 详细文档
- `commands/review-pr.md` - 主要命令实现
- `agents/code-reviewer.md` - 通用代码审查代理
- `agents/code-simplifier.md` - 代码简化代理
- `agents/comment-analyzer.md` - 注释分析代理
- `agents/pr-test-analyzer.md` - 测试分析代理
- `agents/silent-failure-hunter.md` - 静默失败检查代理
- `agents/type-design-analyzer.md` - 类型设计分析代理

### 工作流特性
- 6 个专业化代理
- 灵活的审查方面选择
- 并行和顺序审查模式

## 变更记录 (Changelog)

### 2025-11-18 16:43:03 - 初始化文档
- 创建模块级 CLAUDE.md 文档
- 分析 6 个专业化代理的功能
- 记录审查工作流和使用模式
- 生成导航面包屑和集成指南

---

## 模块覆盖状态

**扫描统计**：
- 总文件数：8
- 已扫描文件数：8
- 覆盖率：100%

**关键文件分析**：
- ✅ plugin.json - 插件元数据完整
- ✅ README.md - 文档详细
- ✅ review-pr.md - 审查命令功能完整，支持多种审查模式
- ✅ 6 个专业化代理 - 各自功能明确，覆盖不同审查维度

**功能缺口**：无，审查工具包功能完整，代理专业化程度高。