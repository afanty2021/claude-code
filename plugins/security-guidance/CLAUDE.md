[根目录](../../CLAUDE.md) > [plugins](../) > **security-guidance**

# Security Guidance Plugin

## 模块职责

提供安全提醒钩子，在编辑文件时警告潜在的安全问题，帮助开发者识别和避免常见的安全漏洞。

## 入口与启动

### 插件元数据
- **配置文件**: `.claude-plugin/plugin.json`
- **钩子配置**: `hooks/hooks.json`

### 核心组件结构
```
security-guidance/
├── .claude-plugin/plugin.json      # 插件元数据
├── README.md                       # 插件文档
├── hooks/
│   ├── hooks.json                  # 钩子配置
│   └── security_reminder_hook.py   # 安全提醒钩子实现
└── CLAUDE.md                       # 模块文档
```

## 对外接口

### 钩子配置
```json
{
  "description": "Security reminder hook that warns about potential security issues when editing files",
  "hooks": {
    "PreToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "python3 ${CLAUDE_PLUGIN_ROOT}/hooks/security_reminder_hook.py"
          }
        ],
        "matcher": "Edit|Write|MultiEdit"
      }
    ]
  }
}
```

### 触发条件
当执行以下操作时自动触发安全检查：
- **Edit**: 编辑文件内容
- **Write**: 写入新文件
- **MultiEdit**: 批量编辑操作

## 安全检查规则

### 1. GitHub Actions 工作流注入
**检查路径**: `.github/workflows/*.yml` 或 `.github/workflows/*.yaml`

**风险**: 命令注入漏洞
- 避免在 `run:` 命令中直接使用不受信任的输入
- 使用环境变量和适当引号

**不安全模式**:
```yaml
run: echo "${{ github.event.issue.title }}"
```

**安全模式**:
```yaml
env:
  TITLE: ${{ github.event.issue.title }}
run: echo "$TITLE"
```

### 2. 子进程执行注入
**检查内容**: `child_process.exec`, `exec(`, `execSync(`

**风险**: 命令注入漏洞
- 推荐使用 `execFileNoThrow` 工具
- 使用参数数组而非字符串连接

**安全替代**:
```javascript
import { execFileNoThrow } from '../utils/execFileNoThrow.js'
await execFileNoThrow('command', [userInput])
```

### 3. 动态代码执行
**检查内容**: `new Function`, `eval(`

**风险**: 代码注入漏洞
- 考虑使用 JSON.parse() 或其他安全序列化格式
- 只在真正需要评估任意动态代码时使用

### 4. XSS 防护
**检查内容**: `dangerouslySetInnerHTML`, `document.write`, `.innerHTML =`

**风险**: 跨站脚本攻击 (XSS)
- 使用 DOMPurify 等HTML清理库
- 使用 textContent 或安全DOM方法

### 5. 反序列化安全
**检查内容**: `pickle`

**风险**: 任意代码执行
- 考虑使用 JSON 或其他安全序列化格式
- 只在明确需要或用户要求时使用 pickle

### 6. 系统调用安全
**检查内容**: `os.system`, `from os import system`

**风险**: 命令注入
- 只应用于静态参数
- 永远不要使用可能受用户控制的参数

## 钩子实现机制

### 输入处理
钩子通过 stdin 接收 JSON 格式的输入：
```json
{
  "session_id": "会话标识符",
  "tool_name": "工具名称",
  "tool_input": {
    "file_path": "文件路径",
    "content": "文件内容"
  }
}
```

### 状态管理
- **会话范围**: 使用会话 ID 管理警告状态
- **去重机制**: 同一文件和规则在同一会话中只警告一次
- **自动清理**: 30 天后自动清理过期状态文件

### 输出控制
- **退出代码 0**: 允许工具执行
- **退出代码 1**: 显示错误给用户，不阻止 Claude
- **退出代码 2**: 阻止工具执行，向 Claude 显示 stderr

## 关键依赖与配置

### 依赖要求
- **Python 3.6+**: 钩子执行环境
- **文件系统权限**: 读写状态文件
- **环境变量**: 控制钩子行为

### 配置选项
- **ENABLE_SECURITY_REMINDER**: 启用/禁用安全提醒 (默认: 1)
- **CLAUDE_PLUGIN_ROOT**: 插件根目录路径
- **会话管理**: 自动状态文件清理

## 数据模型

### 安全规则模型
```json
{
  "ruleName": "规则名称",
  "path_check": "路径检查函数",
  "substrings": ["检查内容列表"],
  "reminder": "安全提醒信息"
}
```

### 状态管理模型
```json
{
  "session_id": "会话ID",
  "shown_warnings": ["已显示警告列表"],
  "last_cleanup": "最后清理时间"
}
```

## 测试与质量

### 测试策略
- **规则测试**: 每个安全规则的准确性验证
- **性能测试**: 大文件处理性能
- **误报测试**: 最小化误报率
- **覆盖测试**: 不同文件类型和代码模式

### 质量保证
- **最小干扰**: 只在确实存在风险时警告
- **可操作建议**: 提供具体的安全修复方案
- **教育导向**: 解释风险原因和防范方法

## 常见问题 (FAQ)

**Q: 如何临时禁用安全提醒？**
A: 设置环境变量 `ENABLE_SECURITY_REMINDER=0`

**Q: 警告会阻止代码执行吗？**
A: 会的，退出代码 2 会阻止工具执行，需要用户确认后继续

**Q: 如何添加新的安全规则？**
A: 在 `SECURITY_PATTERNS` 列表中添加新的规则定义

**Q: 状态文件存储在哪里？**
A: 存储在 `~/.claude/security_warnings_state_{session_id}.json`

## 相关文件清单

### 核心文件
- `.claude-plugin/plugin.json` - 插件配置
- `README.md` - 详细文档
- `hooks/hooks.json` - 钩子配置
- `hooks/security_reminder_hook.py` - 主要实现文件

### 实现特性
- 11 个内置安全规则
- 会话状态管理
- 自动清理机制
- 详细的安全建议

## 变更记录 (Changelog)

### 2025-11-18 16:43:03 - 初始化文档
- 创建模块级 CLAUDE.md 文档
- 分析 11 个安全检查规则
- 记录钩子实现机制和状态管理
- 生成导航面包屑和使用指南

---

## 模块覆盖状态

**扫描统计**：
- 总文件数：4
- 已扫描文件数：4
- 覆盖率：100%

**关键文件分析**：
- ✅ plugin.json - 插件元数据完整
- ✅ README.md - 文档详细
- ✅ hooks.json - 钩子配置清晰
- ✅ security_reminder_hook.py - 实现完整，包含 11 个安全规则

**功能缺口**：无，安全钩子功能完整且覆盖了主要的安全风险点。