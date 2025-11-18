[根目录](../CLAUDE.md) > **examples**

# Examples Module

## 模块职责

提供 Claude Code 钩子系统的示例代码，展示如何实现 PreToolUse 钩子，帮助开发者理解和创建自定义钩子功能。

## 入口与启动

### 示例类型
- **语言**: Python 3
- **钩子类型**: PreToolUse 钩子
- **目标**: Bash 命令验证和改进建议

### 核心组件结构
```
examples/
├── hooks/
│   ├── bash_command_validator_example.py  # Bash 命令验证钩子示例
│   └── README.md                          # 钩子示例说明
└── CLAUDE.md                              # 模块文档
```

## 对外接口

### 主要示例

#### bash_command_validator_example.py - Bash 命令验证钩子
**功能**: 在执行 Bash 命令前进行验证，提供更好的工具建议

**触发条件**: PreToolUse 钩子，匹配 Bash 工具使用

**配置示例**:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "python3 /path/to/claude-code/examples/hooks/bash_command_validator_example.py"
          }
        ]
      }
    ]
  }
}
```

## 验证规则详解

### 当前验证规则

#### 1. grep 替换建议
**模式**: `^grep\b(?!.*\|)`
**建议**: 使用 'rg' (ripgrep) 替代 'grep' 获得更好的性能和功能

**理由**:
- ripgrep 比 grep 更快
- 默认忽略 .gitignore 中的文件
- 更好的搜索体验和输出格式

#### 2. find 命令改进
**模式**: `^find\s+\S+\s+-name\b`
**建议**: 使用 'rg --files | rg pattern' 或 'rg --files -g pattern' 替代 'find -name'

**理由**:
- 更快的文件搜索性能
- 更灵活的模式匹配
- 更好的并行处理能力

### 验证流程

1. **输入解析**: 解析 JSON 格式的钩子输入
2. **工具匹配**: 验证是否为 Bash 工具调用
3. **命令提取**: 提取要执行的 Bash 命令
4. **规则匹配**: 检查命令是否匹配验证规则
5. **建议输出**: 对匹配的规则输出改进建议
6. **退出控制**: 根据验证结果决定是否阻止执行

## 钩子实现机制

### 输入格式
```json
{
  "tool_name": "Bash",
  "tool_input": {
    "command": "grep pattern file.txt"
  }
}
```

### 验证逻辑
```python
def _validate_command(command: str) -> list[str]:
    issues = []
    for pattern, message in _VALIDATION_RULES:
        if re.search(pattern, command):
            issues.append(message)
    return issues
```

### 退出代码
- **退出代码 0**: 允许工具执行（无问题）
- **退出代码 1**: 显示错误给用户，不阻止 Claude（JSON 解析错误）
- **退出代码 2**: 阻止工具执行，向 Claude 显示 stderr（发现验证问题）

## 关键依赖与配置

### 技术依赖
- **Python 3.6+**: 钩子执行环境
- **标准库**: json, re, sys 模块
- **无外部依赖**: 使用 Python 标准库实现

### 配置要求
- **执行权限**: Python 脚本需要执行权限
- **路径配置**: 需要正确配置脚本路径
- **钩子注册**: 在 Claude Code 设置中注册钩子

## 数据模型

### 验证规则模型
```python
_VALIDATION_RULES = [
    (
        r"^grep\b(?!.*\|)",
        "Use 'rg' (ripgrep) instead of 'grep' for better performance and features",
    ),
    (
        r"^find\s+\S+\s+-name\b",
        "Use 'rg --files | rg pattern' or 'rg --files -g pattern' instead of 'find -name' for better performance",
    ),
]
```

### 钩子输入模型
```json
{
  "tool_name": "工具名称字符串",
  "tool_input": {
    "command": "要执行的命令字符串",
    "other_params": "其他参数"
  }
}
```

## 扩展指南

### 添加新的验证规则

1. **定义规则模式**: 使用正则表达式定义匹配模式
2. **编写建议信息**: 提供清晰的改进建议
3. **添加到规则列表**: 将新规则添加到 `_VALIDATION_RULES`
4. **测试验证**: 使用各种命令测试规则的准确性

**示例新规则**:
```python
(
    r"^curl.*-X POST.*without.*header",
    "Consider adding Content-Type header for POST requests: curl -X POST -H 'Content-Type: application/json'"
),
```

### 创建其他类型钩子

#### PostToolUse 钩子示例
```python
# 在工具执行后进行清理或日志记录
def post_tool_hook():
    # 记录执行结果
    # 进行资源清理
    # 发送通知等
    pass
```

#### SessionStart 钩子示例
```python
# 在会话开始时进行初始化
def session_start_hook():
    # 加载配置
    # 设置环境
    # 初始化状态
    pass
```

## 测试与质量

### 测试策略
- **规则测试**: 测试每个验证规则的准确性
- **边界测试**: 测试各种命令格式的边界情况
- **性能测试**: 确保钩子不会显著影响性能
- **集成测试**: 在实际使用场景中验证钩子功能

### 质量保证
- **错误处理**: 完善的错误处理和日志记录
- **性能优化**: 高效的正则表达式和匹配逻辑
- **用户友好**: 清晰的改进建议和错误信息

## 常见问题 (FAQ)

**Q: 如何测试钩子是否正常工作？**
A: 执行匹配规则的命令，观察是否出现建议信息

**Q: 钩子会阻止命令执行吗？**
A: 会，退出代码 2 会阻止命令执行，用户需要确认后继续

**Q: 如何添加自定义验证规则？**
A: 在 `_VALIDATION_RULES` 列表中添加新的 (模式, 建议) 元组

**Q: 钩子支持所有类型的工具吗？**
A: 当前示例针对 Bash 工具，可以扩展支持其他工具类型

**Q: 如何处理复杂的命令验证？**
A: 使用更复杂的正则表达式或多阶段验证逻辑

## 相关文件清单

### 核心文件
- `hooks/bash_command_validator_example.py` - 主要钩子实现
- `hooks/README.md` - 钩子使用说明和配置示例

### 文件特性
- 完整的钩子实现示例
- 详细的配置说明
- 可扩展的规则系统

## 变更记录 (Changelog)

### 2025-11-18 16:43:03 - 初始化文档
- 创建模块级 CLAUDE.md 文档
- 分析 Bash 命令验证钩子示例
- 记录验证规则和扩展指南
- 生成导航面包屑和使用说明

---

## 模块覆盖状态

**扫描统计**：
- 总文件数：2
- 已扫描文件数：2
- 覆盖率：100%

**关键文件分析**：
- ✅ bash_command_validator_example.py - 钩子实现完整，包含详细注释
- ✅ README.md - 配置说明详细，包含完整的使用示例

**功能缺口**：无，示例代码完整且文档详细，适合学习和扩展。