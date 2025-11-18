[根目录](../../CLAUDE.md) > [plugins](../) > **commit-commands**

# Commit Commands Plugin

## 模块职责

简化常用 Git 操作，提供 streamlined 命令用于提交、推送和创建 Pull Request，减少上下文切换并提高开发效率。

## 入口与启动

### 插件元数据
- **配置文件**: `.claude-plugin/plugin.json`
- **版本**: 1.0.0
- **作者**: Anthropic (support@anthropic.com)

### 核心组件结构
```
commit-commands/
├── .claude-plugin/plugin.json    # 插件元数据
├── README.md                     # 插件文档
└── commands/                     # 斜杠命令
    ├── commit.md                 # Git 提交命令
    ├── commit-push-pr.md         # 组合命令
    └── clean_gone.md             # 分支清理命令
```

## 对外接口

### 主要命令

#### `/commit` - 创建 Git 提交
- **功能**: 生成合适的提交信息并创建提交
- **自动检测**: 变更文件类型和影响范围
- **信息生成**: 基于变更内容生成语义化提交信息

#### `/commit-push-pr` - 一键式工作流
- **功能**: 提交、推送并创建 PR 的组合命令
- **流程优化**: 减少多个命令的手动执行
- **PR 模板**: 自动填充 PR 描述和标题

#### `/clean_gone` - 分支清理
- **功能**: 清理标记为 [gone] 的本地分支
- **安全检查**: 确认分支已完全合并或删除
- **批量操作**: 支持一次清理多个过期分支

## 关键依赖与配置

### 依赖要求
- Git 2.0+ - 版本控制操作
- GitHub CLI (`gh`) - PR 创建和交互
- 有效的 GitHub 认证 - 推送和 PR 权限

### 配置要求
- **远程仓库**: 必须配置正确的远程仓库地址
- **分支策略**: 需要遵循标准 Git 工作流
- **认证配置**: GitHub token 或 SSH 密钥配置

## 数据模型

### 提交信息模型
```
type(影响范围): description

[optional body]

Closes #issue-number
```

### 命令参数模型
```json
{
  "command": "commit|commit-push-pr|clean_gone",
  "options": {
    "message": "自定义提交信息",
    "draft": "是否创建草稿 PR",
    "force": "强制清理分支"
  }
}
```

## 测试与质量

### 安全机制
- **确认提示**: 重要操作前的用户确认
- **回滚支持**: 提供撤销操作的指导
- **分支保护**: 防止误删重要分支

### 质量保证
- **提交信息验证**: 确保符合项目约定
- **PR 模板检查**: 验证 PR 描述完整性
- **分支状态检查**: 避免基于过期分支的操作

## 常见问题 (FAQ)

**Q: 自动生成的提交信息如何保证质量？**
A: 基于变更文件的类型和内容分析，遵循语义化提交规范。

**Q: 支持哪些 PR 模板？**
A: 支持标准的 GitHub PR 模板，自动填充变更摘要和相关 issue。

**Q: 如何自定义提交信息格式？**
A: 可以在命令中提供自定义信息，或修改命令定义中的格式规则。

**Q: 清理分支操作安全吗？**
A: 只清理已标记为 [gone] 的分支，且会在操作前显示确认信息。

## 相关文件清单

### 核心文件
- `.claude-plugin/plugin.json` - 插件配置
- `README.md` - 详细文档和使用说明
- `commands/commit.md` - 提交命令实现
- `commands/commit-push-pr.md` - 组合工作流命令
- `commands/clean_gone.md` - 分支清理命令

### 命令特性
- 支持交互式确认
- 提供详细的操作日志
- 包含错误处理和回滚指导

## 变更记录 (Changelog)

### 2025-11-18 16:43:03 - 初始化文档
- 创建模块级 CLAUDE.md 文档
- 分析三个核心命令的功能和流程
- 生成导航面包屑和使用指南

---

## 模块覆盖状态

**扫描统计**：
- 总文件数：5
- 已扫描文件数：5
- 覆盖率：100%

**关键文件分析**：
- ✅ plugin.json - 插件元数据完整
- ✅ README.md - 文档详细，包含使用说明
- ✅ commit.md - 提交命令功能完整
- ✅ commit-push-pr.md - 组合命令流程清晰
- ✅ clean_gone.md - 清理命令安全机制完善

**功能缺口**：无，所有命令功能完整且文档齐全。