@echo off
REM Windows 打包脚本
REM 使用方法: build-windows.bat

echo ================================
echo 开始构建 Windows 版本
echo ================================

REM 检查 Node.js
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ❌ 错误: 未找到 Node.js，请先安装 Node.js
    pause
    exit /b 1
)

echo ✓ Node.js 已安装
node --version

REM 检查依赖
if not exist "node_modules" (
    echo 📦 安装依赖...
    call npm install
)

REM 清理之前的构建
echo 🧹 清理之前的构建...
if exist "dist" rmdir /s /q dist
if exist "release" rmdir /s /q release

REM TypeScript 类型检查
echo 🔍 TypeScript 类型检查...
call npx vue-tsc -b || echo ⚠️ 类型检查有警告，继续构建...

REM 构建 Vite
echo 🏗️  构建前端资源...
call npx vite build

REM 使用 electron-builder 打包 Windows
echo 📦 打包 Windows 应用...
call npx electron-builder --win

echo.
echo ================================
echo ✅ 构建完成!
echo ================================
echo 输出目录: release\
echo.
echo 生成的文件:
dir release\*.exe 2>nul || echo 未找到 exe 文件
dir release\*.zip 2>nul || echo 未找到 zip 文件

pause
