@echo off
REM 上传 Windows 构建产物到 GitHub Release
REM 使用前需要先安装 GitHub CLI (gh)

echo ================================
echo 上传 Windows 包到 GitHub Release
echo ================================
echo.

REM 检查 gh 是否安装
where gh >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ 错误: 未找到 GitHub CLI (gh)
    echo.
    echo 请先安装 GitHub CLI:
    echo 1. 访问 https://cli.github.com/
    echo 2. 下载并安装
    echo 3. 运行 gh auth login 进行认证
    echo.
    pause
    exit /b 1
)

echo ✓ GitHub CLI 已安装
echo.

REM 检查是否已登录
gh auth status >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ⚠️  未登录 GitHub,请先运行: gh auth login
    pause
    exit /b 1
)

echo ✓ 已登录 GitHub
echo.

REM 检查 release 目录中的文件
if not exist "release\*.exe" (
    echo ❌ 错误: 未找到 Windows 安装包
    echo 请先运行: npm run electron:build:win
    pause
    exit /b 1
)

echo 📦 准备上传以下文件:
echo.
dir /b release\离线OCR识别工具-*.exe
dir /b release\离线OCR识别工具-*.zip
echo.

echo 开始创建 GitHub Release...
echo.

REM 创建 Release 并上传文件
gh release create v1.0.0 ^
    --title "v1.0.0 - 离线OCR识别工具" ^
    --notes "## 离线OCR识别工具 v1.0.0

### ✨ 功能特性
- 📝 单张图片OCR识别
- 📚 批量图片OCR识别  
- 🌍 支持26国语言自动识别
- 🔍 智能语种检测
- ⚡ 高性能识别引擎
- 💻 完全离线运行
- 🎨 现代化 UI 界面

### 📦 Windows 安装包
- **离线OCR识别工具-1.0.0-win.exe** - NSIS 安装程序(推荐)
- **离线OCR识别工具-1.0.0-win-x64.exe** - 64位独立安装包
- **离线OCR识别工具-1.0.0-win-ia32.exe** - 32位独立安装包
- **离线OCR识别工具-1.0.0-win-x64.zip** - 便携版(免安装)

### 🔧 技术栈
- Vue 3 + TypeScript
- Electron 41
- Tesseract.js 7.0
- Vite 8.0

### 📖 使用说明
1. 下载安装包并运行
2. 选择或拖拽图片
3. 点击开始识别
4. 复制识别结果

完整文档请查看 README.md" ^
    --draft ^
    release\离线OCR识别工具-1.0.0-win.exe ^
    release\离线OCR识别工具-1.0.0-win-x64.exe ^
    release\离线OCR识别工具-1.0.0-win-ia32.exe ^
    release\离线OCR识别工具-1.0.0-win-x64.zip

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Release 创建成功!
    echo.
    echo 请访问以下链接查看和发布 Release:
    echo https://github.com/dabaiInJesus/offline-ocr/releases/tag/v1.0.0
    echo.
    echo 注意: Release 已创建为草稿状态,请手动发布
) else (
    echo.
    echo ❌ Release 创建失败
    echo.
    echo 可能原因:
    echo 1. Release v1.0.0 已存在
    echo 2. 网络连接问题
    echo 3. 权限不足
    echo.
    echo 可以尝试手动上传或使用 GitHub 网页界面
)

echo.
pause
