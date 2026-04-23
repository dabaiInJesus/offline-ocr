# WSL2 Linux 打包环境配置指南

## 📋 前置要求

1. **Windows 10/11** 已安装 WSL2
2. **WSL2 Ubuntu** 或其他 Linux 发行版
3. **Node.js** 在 WSL2 中安装

## 🔧 WSL2 环境设置

### 1. 安装 Node.js（在 WSL2 中）

```bash
# 进入 WSL2
wsl

# 使用 nvm 安装 Node.js（推荐）
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 18
nvm use 18

# 或者使用 apt 安装
sudo apt update
sudo apt install -y curl
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
```

### 2. 验证安装

```bash
node --version   # 应该显示 v18.x.x 或更高
npm --version    # 应该显示 9.x.x 或更高
```

### 3. 访问 Windows 项目文件

WSL2 可以访问 Windows 文件系统，路径映射规则：
- Windows: `D:\code\offline-ocr`
- WSL2: `/mnt/d/code/offline-ocr`

## 🚀 打包方法

### 方法一：自动调用（推荐）

在 Windows 的 Git Bash 或 CMD 中运行：

```bash
npm run electron:build:linux
```

这会自动：
1. 调用 WSL2
2. 转换路径
3. 执行 Linux 打包命令

### 方法二：手动在 WSL2 中运行

```bash
# 1. 进入 WSL2
wsl

# 2. 进入项目目录
cd /mnt/d/code/offline-ocr

# 3. 安装依赖（首次需要）
npm install

# 4. 运行打包脚本
./build-linux.sh

# 或使用 npm 命令
npm run electron:build:linux:wsl
```

### 方法三：使用快捷脚本

在 Git Bash 中：
```bash
./build-linux.sh
```

## ⚙️ 优化建议

### 1. 提升 WSL2 性能

编辑 WSL2 配置文件 `~/.wslconfig`（在 Windows 用户目录下）：

```ini
[wsl2]
memory=4GB
processors=4
swap=2GB
localhostForwarding=true
```

### 2. 加速 npm 安装（在 WSL2 中）

```bash
# 使用淘宝镜像
npm config set registry https://registry.npmmirror.com

# 或使用 pnpm（更快）
npm install -g pnpm
pnpm install
```

### 3. 避免跨文件系统性能问题

**不推荐**：在 WSL2 中访问 Windows 文件系统（`/mnt/d/...`）
- 原因：I/O 性能较差

**推荐方案**：将项目复制到 WSL2 文件系统

```bash
# 在 WSL2 中
cd ~
git clone <your-repo-url>
cd offline-ocr
npm install
npm run electron:build:linux:wsl

# 构建完成后，从 WSL2 复制回 Windows
cp -r release/* /mnt/d/code/offline-ocr/release/
```

### 4. 缓存 node_modules

为了避免重复安装，可以在 WSL2 中创建符号链接：

```bash
# 在 WSL2 中
cd /mnt/d/code/offline-ocr
ln -s /home/<your-username>/offline-ocr-node_modules node_modules
```

## 🐛 常见问题

### Q1: 权限错误

```bash
# 修复脚本执行权限
chmod +x build-linux.sh

# 如果遇到 node_modules 权限问题
sudo chown -R $USER:$USER node_modules
```

### Q2: 找不到命令

```bash
# 确保在正确的目录
pwd
ls -la

# 检查 Node.js 是否安装
which node
which npm
```

### Q3: 打包失败

```bash
# 清理并重新构建
rm -rf dist release node_modules
npm install
npm run electron:build:linux:wsl
```

### Q4: WSL2 路径转换问题

```bash
# 测试路径转换
wslpath -u "D:\code\offline-ocr"
# 应该输出: /mnt/d/code/offline-ocr
```

## 📊 性能对比

| 方式 | 速度 | 便利性 | 推荐场景 |
|------|------|--------|----------|
| Windows 直接打包 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Windows 版本 |
| WSL2 自动调用 | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | 快速测试 |
| WSL2 本地项目 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | 正式打包 |
| Docker | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | CI/CD |

## 💡 最佳实践

1. **开发时**：使用 `npm run electron:build:linux` 快速测试
2. **正式发布**：将项目克隆到 WSL2 文件系统，获得最佳性能
3. **CI/CD**：考虑使用 GitHub Actions 或 Docker 进行自动化打包
4. **依赖管理**：在 WSL2 中使用 pnpm 加速安装

## 🔗 相关资源

- [WSL2 官方文档](https://docs.microsoft.com/en-us/windows/wsl/)
- [Electron Builder Linux 打包](https://www.electron.build/configuration/linux)
- [Node.js 安装指南](https://github.com/nvm-sh/nvm)
