#!/bin/bash

# Linux 打包脚本 (在 WSL2 中运行)
# 使用方法: ./build-linux.sh

set -e

echo "================================"
echo "开始构建 Linux 版本"
echo "================================"

# 检查是否在 WSL 环境中
if grep -qEi "(Microsoft|WSL)" /proc/version; then
    echo "✓ 检测到 WSL 环境"
else
    echo "⚠ 警告: 可能不在 WSL 环境中"
fi

# 进入项目目录
cd "$(dirname "$0")"

# 检查依赖
if [ ! -d "node_modules" ]; then
    echo "📦 安装依赖..."
    npm install
fi

# 清理之前的构建
echo "🧹 清理之前的构建..."
rm -rf dist release

# TypeScript 类型检查
echo "🔍 TypeScript 类型检查..."
npm run vue-tsc -b || true

# 构建 Vite
echo "🏗️  构建前端资源..."
npx vite build

# 使用 electron-builder 打包 Linux
echo "📦 打包 Linux 应用..."
npx electron-builder --linux

echo ""
echo "================================"
echo "✅ 构建完成!"
echo "================================"
echo "输出目录: release/"
echo ""
echo "生成的文件:"
ls -lh release/ 2>/dev/null || echo "未找到输出文件"
