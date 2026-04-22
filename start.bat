@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: OCR 项目快速启动脚本 (Windows)

echo ======================================
echo   离线 OCR 识别工具 - 快速启动
echo ======================================
echo.

:: 检查 Node.js
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ 错误: 未检测到 Node.js
    echo 请先安装 Node.js (^>= 18.0.0^)
    echo 下载地址: https://nodejs.org/
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('node -v') do set NODE_VERSION=%%i
echo ✅ Node.js 版本: %NODE_VERSION%

:: 检查包管理器
set PNPM_AVAILABLE=false
set NPM_AVAILABLE=false

where pnpm >nul 2>nul
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('pnpm -v') do set PNPM_VERSION=%%i
    echo ✅ pnpm 版本: !PNPM_VERSION!
    set PNPM_AVAILABLE=true
) else (
    where npm >nul 2>nul
    if %errorlevel% equ 0 (
        for /f "tokens=*" %%i in ('npm -v') do set NPM_VERSION=%%i
        echo ✅ npm 版本: !NPM_VERSION!
        set NPM_AVAILABLE=true
    ) else (
        echo ❌ 错误: 未检测到 npm 或 pnpm
        pause
        exit /b 1
    )
)

echo.
echo ======================================
echo   选择操作:
echo ======================================
echo 1. 安装依赖
echo 2. 启动开发模式 ^(Web^)
echo 3. 启动开发模式 ^(Electron^)
echo 4. 构建生产版本 ^(Web^)
echo 5. 构建 Electron 安装包
echo 6. 退出
echo.

set /p choice="请输入选项 (1-6): "

if "%choice%"=="1" goto install
if "%choice%"=="2" goto dev_web
if "%choice%"=="3" goto dev_electron
if "%choice%"=="4" goto build_web
if "%choice%"=="5" goto build_electron
if "%choice%"=="6" goto exit
goto invalid

:install
echo.
echo 📦 正在安装依赖...
if "%PNPM_AVAILABLE%"=="true" (
    call pnpm install
) else (
    call npm install
)
echo.
echo ✅ 依赖安装完成！
pause
exit /b 0

:dev_web
echo.
echo 🚀 启动 Web 开发服务器...
if "%PNPM_AVAILABLE%"=="true" (
    call pnpm dev
) else (
    call npm run dev
)
exit /b 0

:dev_electron
echo.
echo 🚀 启动 Electron 开发模式...
if "%PNPM_AVAILABLE%"=="true" (
    call pnpm electron:dev
) else (
    call npm run electron:dev
)
exit /b 0

:build_web
echo.
echo 🔨 构建 Web 生产版本...
if "%PNPM_AVAILABLE%"=="true" (
    call pnpm build
) else (
    call npm run build
)
echo.
echo ✅ 构建完成！文件在 dist\ 目录
pause
exit /b 0

:build_electron
echo.
echo 🔨 构建 Electron 安装包...
if "%PNPM_AVAILABLE%"=="true" (
    call pnpm electron:build
) else (
    call npm run electron:build
)
echo.
echo ✅ 构建完成！安装包在 release\ 目录
pause
exit /b 0

:exit
echo.
echo 再见！👋
exit /b 0

:invalid
echo.
echo ❌ 无效选项
pause
exit /b 1
