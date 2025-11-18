[根目录](../CLAUDE.md) > **scripts**

# Scripts Module

## 模块职责

提供 GitHub 自动化脚本，用于管理 Issue 重复检测、自动关闭重复问题和回填充重复检测注释，提高项目维护效率。

## 入口与启动

### 运行环境
- **运行时**: Bun 运行时环境
- **语言**: TypeScript
- **权限**: GitHub API 访问权限

### 核心组件结构
```
scripts/
├── auto-close-duplicates.ts           # 自动关闭重复 Issue 脚本
├── backfill-duplicate-comments.ts     # 回填充重复检测注释脚本
└── CLAUDE.md                          # 模块文档
```

## 对外接口

### 主要脚本

#### auto-close-duplicates.ts - 自动关闭重复 Issue
**功能**: 自动关闭被标记为重复且超过 3 天无活跃活动的 Issue

**执行命令**:
```bash
GITHUB_TOKEN=your_token bun run scripts/auto-close-duplicates.ts
```

**环境变量**:
- `GITHUB_TOKEN`: GitHub 个人访问令牌（必需）
- `GITHUB_REPOSITORY_OWNER`: 仓库所有者（默认: anthropics）
- `GITHUB_REPOSITORY_NAME`: 仓库名称（默认: claude-code）

#### backfill-duplicate-comments.ts - 回填充重复检测注释
**功能**: 为历史 Issue 触发重复检测工作流，填充缺失的重复检测注释

**执行命令**:
```bash
GITHUB_TOKEN=your_token bun run scripts/backfill-duplicate-comments.ts
```

**环境变量**:
- `GITHUB_TOKEN`: GitHub 个人访问令牌（必需）
- `DRY_RUN`: 设置为 "false" 实际触发工作流（默认: true 安全模式）
- `MAX_ISSUE_NUMBER`: 只处理小于此值的 Issue（默认: 4050）
- `MIN_ISSUE_NUMBER`: 处理范围的起始 Issue 号（默认: 1）

## 脚本功能详解

### 自动关闭重复 Issue 流程

1. **获取 Issue**: 获取创建超过 3 天的开放 Issue
2. **过滤重复检测**: 查找包含重复检测注释的 Issue
3. **时间检查**: 确保重复检测注释超过 3 天
4. **活跃度验证**: 检查重复检测后是否有新活动
5. **反应检查**: 验证 Issue 作者没有点踩（👎）重复检测
6. **自动关闭**: 符合条件则自动关闭并标记为重复

### 回填充检测注释流程

1. **范围扫描**: 指定 Issue 编号范围内的所有 Issue
2. **检测已有注释**: 查找现有的重复检测注释
3. **触发工作流**: 为缺失注释的 Issue 触发检测工作流
4. **安全模式**: 默认干运行模式，需要明确设置才实际执行

## 关键依赖与配置

### 技术依赖
- **Bun 运行时**: 高性能 JavaScript 运行时
- **GitHub API v3**: REST API 接口
- **TypeScript**: 类型安全和开发体验

### GitHub API 依赖
- **Issue 访问**: 读取 Issue 和评论的权限
- **Issue 编辑**: 关闭 Issue 和添加评论的权限
- **Actions 访问**: 触发 GitHub Actions 工作流的权限

### 配置参数
- **时间阈值**: 3 天的等待期
- **分页大小**: 每页 100 个 Issue
- **安全限制**: 最多处理 200 页防止无限循环

## 数据模型

### GitHub Issue 模型
```typescript
interface GitHubIssue {
  number: number;
  title: string;
  user: { id: number };
  created_at: string;
}
```

### GitHub Comment 模型
```typescript
interface GitHubComment {
  id: number;
  body: string;
  created_at: string;
  user: { type: string; id: number };
}
```

### GitHub Reaction 模型
```typescript
interface GitHubReaction {
  user: { id: number };
  content: string;
}
```

### 处理状态模型
- **processedCount**: 已处理的 Issue 数量
- **candidateCount**: 符合条件的候选数量
- **triggeredCount**: 实际触发的数量（回填充脚本）

## 测试与质量

### 安全机制
- **干运行模式**: 回填充脚本默认为安全模式
- **确认检查**: 多重验证避免误关闭
- **日志记录**: 详细的调试和操作日志

### 错误处理
- **API 错误**: 完善的 GitHub API 错误处理
- **网络重试**: 对网络错误进行重试处理
- **状态跟踪**: 详细记录处理状态和结果

### 性能优化
- **分页处理**: 分批处理大量 Issue
- **延迟控制**: 回填充脚本添加 1 秒延迟避免过载
- **限制保护**: 设置合理的处理上限

## 常见问题 (FAQ)

**Q: 如何获取 GitHub Token？**
A: 在 GitHub Settings > Developer settings > Personal access tokens 中生成

**Q: 脚本会误关闭 Issue 吗？**
A: 多重安全检查：作者反应、时间阈值、活跃度验证，误关闭概率极低

**Q: 干运行模式如何测试？**
A: 默认就是干运行模式，会显示将要执行的操作而不实际执行

**Q: 如何自定义时间阈值？**
A: 修改脚本中的 `threeDaysAgo` 时间计算逻辑

**Q: 脚本可以定时运行吗？**
A: 可以通过 GitHub Actions 或 cron job 定期执行

## 相关文件清单

### 核心文件
- `auto-close-duplicates.ts` - 自动关闭重复 Issue 脚本
- `backfill-duplicate-comments.ts` - 回填充检测注释脚本

### 文件特性
- TypeScript 类型安全
- 详细的错误处理和日志
- 安全的干运行模式支持

## 变更记录 (Changelog)

### 2025-11-18 16:43:03 - 初始化文档
- 创建模块级 CLAUDE.md 文档
- 分析两个自动化脚本的功能和流程
- 记录数据模型和配置参数
- 生成导航面包屑和使用指南

---

## 模块覆盖状态

**扫描统计**：
- 总文件数：2
- 已扫描文件数：2
- 覆盖率：100%

**关键文件分析**：
- ✅ auto-close-duplicates.ts - 自动关闭功能完整，包含多重安全检查
- ✅ backfill-duplicate-comments.ts - 回填充功能完善，支持干运行模式

**功能缺口**：无，两个脚本功能完整且安全性良好。