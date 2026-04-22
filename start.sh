#!/bin/bash

# OCR 项目快速启动脚本

echo "======================================"
echo "  离线 OCR 识别工具 - 快速启动"
echo "======================================"
echo ""

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "❌ 错误: 未检测到 Node.js"
    echo "请先安装 Node.js (>= 18.0.0)"
    echo "下载地址: https://nodejs.org/"
    exit 1
fi

NODE_VERSION=$(node -v)
echo "✅ Node.js 版本: $NODE_VERSION"

# 检查包管理器
PNPM_AVAILABLE=false
NPM_AVAILABLE=false

if command -v pnpm &> /dev/null; then
    PNPM_VERSION=$(pnpm -v)
    echo "✅ pnpm 版本: $PNPM_VERSION"
    PNPM_AVAILABLE=true
elif command -v npm &> /dev/null; then
    NPM_VERSION=$(npm -v)
    echo "✅ npm 版本: $NPM_VERSION"
    NPM_AVAILABLE=true
else
    echo "❌ 错误: 未检测到 npm 或 pnpm"
    exit 1
fi

echo ""
echo "======================================"
echo "  选择操作:"
echo "======================================"
echo "1. 安装依赖"
echo "2. 启动开发模式 (Web)"
echo "3. 启动开发模式 (Electron)"
echo "4. 构建生产版本 (Web)"
echo "5. 构建 Electron 安装包"
echo "6. 退出"
echo ""

read -p "请输入选项 (1-6): " choice

case $choice in
    1)
        echo ""
        echo "📦 正在安装依赖..."
        if [ "$PNPM_AVAILABLE" = true ]; then
            pnpm install
        else
            npm install
        fi
        echo ""
        echo "✅ 依赖安装完成！"
        ;;
    2)
        echo ""
        echo "🚀 启动 Web 开发服务器..."
        if [ "$PNPM_AVAILABLE" = true ]; then
            pnpm dev
        else
            npm run dev
        fi
        ;;
    3)
        echo ""
        echo "🚀 启动 Electron 开发模式..."
        if [ "$PNPM_AVAILABLE" = true ]; then
            pnpm electron:dev
        else
            npm run electron:dev
        fi
        ;;
    4)
        echo ""
        echo "🔨 构建 Web 生产版本..."
        if [ "$PNPM_AVAILABLE" = true ]; then
            pnpm build
        else
            npm run build
        fi
        echo ""
        echo "✅ 构建完成！文件在 dist/ 目录"
        ;;
    5)
        echo ""
        echo "🔨 构建 Electron 安装包..."
        if [ "$PNPM_AVAILABLE" = true ]; then
            pnpm electron:build
        else
            npm run electron:build
        fi
        echo ""
        echo "✅ 构建完成！安装包在 release/ 目录"
        ;;
    6)
        echo "再见！👋"
        exit 0
        ;;
    *)
        echo "❌ 无效选项"
        exit 1
        ;;
esac
