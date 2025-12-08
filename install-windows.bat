@echo off
echo Installing Claude Code Plugins for Windows...
echo.

REM Check if Claude Code is installed
where claude >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Claude Code is not installed or not in PATH
    echo Please install Claude Code first:
    echo   PowerShell: irm https://claude.ai/install.ps1 ^| iex
    echo   Or visit: https://claude.ai/code
    pause
    exit /b 1
)

echo Claude Code found. Installing plugins...

REM Create plugins directory if it doesn't exist
if not exist "%USERPROFILE%\.claude\plugins" mkdir "%USERPROFILE%\.claude\plugins"

REM Copy all plugins to user's Claude plugins directory
echo Copying plugins...
xcopy /E /I /Y ".\plugins" "%USERPROFILE%\.claude\plugins"

REM Copy marketplace configuration
copy /Y ".\.claude-plugin\marketplace.json" "%USERPROFILE%\.claude\" >nul

echo.
echo ✅ Installation completed successfully!
echo.
echo Available plugins:
echo   - agent-sdk-dev: Agent SDK development tools
echo   - code-review: Automated PR review
echo   - commit-commands: Git workflow automation
echo   - feature-dev: Feature development workflow
echo   - frontend-design: Frontend design tools
echo   - pr-review-toolkit: Comprehensive PR review
echo   - security-guidance: Security reminders
echo   - explanatory-output-style: Educational insights
echo   - learning-output-style: Interactive learning
echo.
echo Usage examples:
echo   claude /zcf:feat
echo   claude /zcf:git-commit
echo   claude /agent-sdk-dev:validate
echo.
pause