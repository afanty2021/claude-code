# Claude Code Plugins - Windows Packaging Script
# Creates a Windows-ready distribution package

param(
    [string]$OutputPath = ".\dist",
    [switch]$IncludeScripts = $false
)

Write-Host "🚀 Creating Windows distribution package..." -ForegroundColor Green

# Create output directory
if (Test-Path $OutputPath) {
    Remove-Item $OutputPath -Recurse -Force
}
New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null

# Copy essential files
Write-Host "📦 Copying plugin files..." -ForegroundColor Blue
Copy-Item ".\plugins" -Destination "$OutputPath\plugins" -Recurse -Force
Copy-Item ".\.claude-plugin" -Destination "$OutputPath\.claude-plugin" -Recurse -Force
Copy-Item ".\examples" -Destination "$OutputPath\examples" -Recurse -Force

# Copy documentation
Copy-Item ".\README.md" -Destination "$OutputPath\" -Force
Copy-Item ".\CLAUDE.md" -Destination "$OutputPath\" -Force
Copy-Item ".\LICENSE.md" -Destination "$OutputPath\" -Force

# Copy scripts if requested
if ($IncludeScripts) {
    Write-Host "📜 Including automation scripts..." -ForegroundColor Blue
    Copy-Item ".\scripts" -Destination "$OutputPath\scripts" -Recurse -Force

    # Create Bun installation note
    @"
# Bun Runtime Required

The automation scripts in this package require Bun runtime to execute on Windows.

## Installation Options

### Option 1: PowerShell (Recommended)
```powershell
irm bun.sh/install.ps1 | iex
```

### Option 2: Using npm
```bash
npm install -g bun
```

### Option 3: Download Binary
Visit https://bun.sh/docs/installation#download-binary

## Usage Examples

After installing Bun, you can run:

```powershell
# Auto-close duplicate issues
env:GITHUB_TOKEN="your_token" bun run scripts\auto-close-duplicates.ts

# Backfill duplicate comments (dry run)
env:GITHUB_TOKEN="your_token" bun run scripts\backfill-duplicate-comments.ts
```
"@ | Out-File -FilePath "$OutputPath\scripts\README.md" -Encoding UTF8
}

# Copy Windows installer
Copy-Item ".\install-windows.bat" -Destination "$OutputPath\" -Force

# Create Windows-specific README
$windowsReadme = @"
# Claude Code Plugins for Windows

## 🎯 Quick Start

1. **Install Claude Code** (if not already installed):
   ```powershell
   irm https://claude.ai/install.ps1 | iex
   ```

2. **Install Plugins**:
   ```batch
   install-windows.bat
   ```

3. **Verify Installation**:
   ```batch
   claude --help
   ```

## 📋 Included Plugins

### Development Tools
- **agent-sdk-dev**: Agent SDK development kit
- **feature-dev**: Complete feature development workflow
- **frontend-design**: High-quality frontend interface design

### Productivity Tools
- **code-review**: Automated PR review with confidence scoring
- **commit-commands**: Git workflow automation (`/zcf:git-commit`, `/zcf:git-cleanBranches`, etc.)
- **pr-review-toolkit**: Specialized PR review agents

### Learning & Security
- **learning-output-style**: Interactive learning mode
- **explanatory-output-style**: Educational code insights
- **security-guidance**: Security reminders and warnings

## 🚀 Usage Examples

```bash
# Feature development workflow
claude /zcf:feat

# Git automation
claude /zcf:git-commit --all
claude /zcf:git-cleanBranches --dry-run

# Code review
claude /code-review:pr

# Frontend design
claude /frontend-design:component

# Security check
claude /security-guidance:scan
```

## 🔧 Configuration

Plugins are automatically configured after installation. You can customize individual plugins in:
```
%USERPROFILE%\.claude\plugins\
```

## 📚 Documentation

- **Main Documentation**: `CLAUDE.md`
- **Plugin Details**: See individual `CLAUDE.md` files in each plugin directory
- **Examples**: Check the `examples/` directory

## 💡 Tips

1. **First Time**: Run `claude` in your project directory to initialize
2. **Help**: Use `claude --help` to see all available commands
3. **Updates**: Re-run the installer to update plugins
4. **Issues**: Report problems at https://github.com/anthropics/claude-code/issues

## 🖥️ Windows Compatibility

- ✅ Windows 10/11
- ✅ PowerShell 5.1+
- ✅ Windows Terminal recommended
- ✅ Git for Windows (for git commands)
"@

$windowsReadme | Out-File -FilePath "$OutputPath\README-Windows.md" -Encoding UTF8

# Create version info
$versionInfo = @{
    Version = "1.0.0"
    BuildDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Platform = "Windows"
    Plugins = @(
        "agent-sdk-dev", "code-review", "commit-commands",
        "feature-dev", "frontend-design", "pr-review-toolkit",
        "security-guidance", "explanatory-output-style", "learning-output-style"
    )
    Files = (Get-ChildItem $OutputPath -Recurse).Count
}

$versionInfo | ConvertTo-Json | Out-File -FilePath "$OutputPath\version.json" -Encoding UTF8

# Create ZIP package
$zipPath = ".\claude-code-plugins-windows-v1.0.0.zip"
Write-Host "🗜️  Creating ZIP package: $zipPath" -ForegroundColor Blue

# Use PowerShell's compression
Compress-Archive -Path "$OutputPath\*" -DestinationPath $zipPath -Force

# Calculate file size
$zipSize = [math]::Round((Get-Item $zipPath).Length / 1MB, 2)

Write-Host "✅ Package created successfully!" -ForegroundColor Green
Write-Host "📍 Location: $zipPath" -ForegroundColor Cyan
Write-Host "📊 Size: $zipSize MB" -ForegroundColor Cyan
Write-Host "📁 Files included: $((Get-ChildItem $OutputPath -Recurse).Count)" -ForegroundColor Cyan

Write-Host ""
Write-Host "🎉 Ready for Windows distribution!" -ForegroundColor Magenta
Write-Host ""
Write-Host "Next steps:"
Write-Host "1. Copy the ZIP file to your Windows machine"
Write-Host "2. Extract to a folder"
Write-Host "3. Run install-windows.bat as administrator"
Write-Host "4. Start using Claude Code plugins!"
"@

$windowsReadme | Out-File -FilePath "$OutputPath\README-Windows.md" -Encoding UTF8

# Execute the script
powershell -ExecutionPolicy Bypass -File ".\package-for-windows.ps1" -IncludeScripts