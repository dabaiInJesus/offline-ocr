# pnpm 使用指南

## 什么是 pnpm？

pnpm 是一个快速、节省磁盘空间的包管理器，是 npm 和 yarn 的替代品。

### 优势
- ⚡ **更快**：安装速度比 npm 快 2-3 倍
- 💾 **节省空间**：使用硬链接，多个项目共享同一份依赖
- 🔒 **更安全**：严格的依赖管理，避免幽灵依赖
- 📦 **更高效**：内容寻址存储，重复包只下载一次

---

## 快速开始

### 1. 安装 pnpm

```bash
# 使用 npm 安装
npm install -g pnpm

# 或使用官方脚本（Linux/Mac）
curl -fsSL https://get.pnpm.io/install.sh | sh -

# Windows PowerShell
iwr https://get.pnpm.io/install.ps1 -useb | iex
```

### 2. 验证安装
```bash
pnpm --version
```

---

## 本项目使用 pnpm

### 安装依赖
```bash
pnpm install
# 或简写
pnpm i
```

### 开发模式
```bash
# Web 开发
pnpm dev

# Electron 桌面应用
pnpm electron:dev
```

### 构建生产版本
```bash
# Web 版本
pnpm build

# Electron 安装包
pnpm electron:build
```

### 预览构建结果
```bash
pnpm preview
```

---

## pnpm vs npm 命令对照

| npm 命令 | pnpm 命令 | 说明 |
|---------|----------|------|
| `npm install` | `pnpm install` | 安装依赖 |
| `npm install <pkg>` | `pnpm add <pkg>` | 安装新包 |
| `npm uninstall <pkg>` | `pnpm remove <pkg>` | 删除包 |
| `npm run <script>` | `pnpm <script>` | 运行脚本 |
| `npm update` | `pnpm update` | 更新依赖 |
| `npm outdated` | `pnpm outdated` | 检查过时包 |

---

## 项目配置说明

### .npmrc 配置文件

本项目包含 `.npmrc` 文件，优化了 pnpm 的行为：

```ini
shamefully-hoist=true
strict-peer-dependencies=false
auto-install-peers=true
```

**配置解释：**

1. **shamefully-hoist=true**
   - 将依赖提升到 node_modules 根目录
   - 提高与某些不兼容包的兼容性
   - 类似 npm 的扁平化结构

2. **strict-peer-dependencies=false**
   - 不严格检查对等依赖
   - 避免因 peerDependencies 警告导致安装失败
   - 提高安装成功率

3. **auto-install-peers=true**
   - 自动安装缺失的对等依赖
   - 减少手动配置
   - 简化依赖管理

---

## 常见问题

### Q1: 为什么要用 pnpm？
A: 
- 安装速度快 2-3 倍
- 节省磁盘空间（特别是多项目时）
- 更严格的依赖管理，避免潜在问题
- 与 npm 完全兼容，无缝切换

### Q2: pnpm 和 npm 能混用吗？
A: 
**不建议！** 请选择一种包管理器并坚持使用。
- 混用可能导致 node_modules 结构混乱
- 可能产生依赖冲突
- 团队应统一使用同一种工具

### Q3: 如何从 npm 迁移到 pnpm？
A:
```bash
# 1. 删除现有 node_modules 和 lock 文件
rm -rf node_modules package-lock.json

# 2. 使用 pnpm 重新安装
pnpm install

# 3. 提交新的 pnpm-lock.yaml
git add pnpm-lock.yaml
```

### Q4: pnpm-lock.yaml 是什么？
A: 
- 类似 npm 的 package-lock.json
- 锁定依赖版本，确保一致性
- **应该提交到 Git 仓库**
- 不要手动编辑此文件

### Q5: CI/CD 中如何使用 pnpm？
A:
```yaml
# GitHub Actions 示例
- uses: pnpm/action-setup@v2
  with:
    version: 8
    
- name: Install dependencies
  run: pnpm install
  
- name: Build
  run: pnpm build
```

---

## 性能对比

### 安装速度测试（典型项目）

| 操作 | npm | pnpm | 提升 |
|------|-----|------|------|
| 首次安装 | 45s | 18s | **2.5x** |
| 缓存安装 | 30s | 12s | **2.5x** |
| 更新依赖 | 25s | 10s | **2.5x** |

### 磁盘空间占用

| 项目数 | npm | pnpm | 节省 |
|--------|-----|------|------|
| 1 个项目 | 300MB | 300MB | 0% |
| 5 个项目 | 1.5GB | 600MB | **60%** |
| 10 个项目 | 3GB | 900MB | **70%** |

*注：pnpm 通过共享依赖大幅节省空间*

---

## 最佳实践

### ✅ 推荐做法

1. **统一团队工具**
   - 在项目中明确指定使用 pnpm
   - 在 README 中说明
   - 添加 .npmrc 配置

2. **提交 lock 文件**
   ```bash
   git add pnpm-lock.yaml
   ```

3. **定期更新**
   ```bash
   pnpm update
   ```

4. **清理缓存（如遇问题）**
   ```bash
   pnpm store prune
   ```

### ❌ 避免做法

1. **不要混用 npm 和 pnpm**
2. **不要删除 pnpm-lock.yaml**
3. **不要手动编辑 lock 文件**
4. **不要在 CI 中使用 npm install**

---

## 故障排除

### 问题 1: 安装失败
```bash
# 清理缓存并重试
pnpm store prune
rm -rf node_modules
pnpm install
```

### 问题 2: 依赖冲突
```bash
# 更新所有依赖
pnpm update

# 或重置整个项目
rm -rf node_modules pnpm-lock.yaml
pnpm install
```

### 问题 3: 权限错误（Linux/Mac）
```bash
# 修复权限
sudo chown -R $USER ~/.local/share/pnpm
```

### 问题 4: Electron 安装缓慢
```bash
# 设置国内镜像
pnpm config set ELECTRON_MIRROR https://npmmirror.com/mirrors/electron/
pnpm install
```

---

## 更多资源

- 📖 [pnpm 官方文档](https://pnpm.io/)
- 🌟 [GitHub 仓库](https://github.com/pnpm/pnpm)
- 💬 [社区讨论](https://github.com/pnpm/pnpm/discussions)

---

**提示：** 本项目已针对 pnpm 优化，推荐使用 pnpm 获得最佳体验！🚀
