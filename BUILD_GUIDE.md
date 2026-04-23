# 离线OCR识别工具 - 打包指南

## 📦 打包命令

### Windows 平台
```bash
npm run electron:build:win
```
生成文件：
- `release/离线OCR识别工具-{version}-win-x64.exe` (NSIS 安装程序)
- `release/离线OCR识别工具-{version}-win-ia32.exe` (32位 NSIS 安装程序)
- `release/离线OCR识别工具-{version}-win-x64.exe` (便携版)
- `release/离线OCR识别工具-{version}-win-x64.zip` (压缩包)

### Linux 平台
```bash
npm run electron:build:linux
```
生成文件：
- `release/离线OCR识别工具-{version}-linux-x64.AppImage` (AppImage)
- `release/离线OCR识别工具-{version}-linux-x64.deb` (Debian/Ubuntu)
- `release/离线OCR识别工具-{version}-linux-x64.rpm` (RedHat/Fedora)

### macOS 平台
```bash
npm run electron:build:mac
```
生成文件：
- `release/离线OCR识别工具-{version}-mac-x64.dmg` (Intel Mac)
- `release/离线OCR识别工具-{version}-mac-arm64.dmg` (Apple Silicon Mac)
- `release/离线OCR识别工具-{version}-mac-x64.zip` (Intel Mac 压缩包)
- `release/离线OCR识别工具-{version}-mac-arm64.zip` (Apple Silicon Mac 压缩包)

### 所有平台（需要对应系统的构建环境）
```bash
npm run electron:build:all
```

## 🔧 前置准备

### Windows 打包
- 无需额外配置，直接在 Windows 系统上运行即可

### Linux 打包
建议在 Linux 系统上进行打包，或在 Windows/macOS 上使用 Docker：
```bash
# 使用 electron-builder 的 Docker 镜像
docker run --rm -it \
  -v ${PWD}:/project \
  -v ${PWD}/node_modules:/project/node_modules \
  electronuserland/builder:wine
```

### macOS 打包
- 必须在 macOS 系统上进行
- 需要安装 Xcode Command Line Tools
- 代码签名（可选）：配置 `CSC_LINK` 和 `CSC_KEY_PASSWORD` 环境变量

## 📝 注意事项

1. **图标文件**：确保在 `public` 目录下有以下图标文件：
   - `favicon.ico` (Windows, 256x256 或更大)
   - `favicon.icns` (macOS, 使用 iconutil 转换)
   - `favicon.png` (Linux, 512x512 或更大)

2. **构建产物**：所有打包文件将输出到 `release` 目录

3. **ASAR 压缩**：已启用 ASAR 压缩以优化应用体积和加载速度

4. **架构支持**：
   - Windows: x64, ia32
   - macOS: x64 (Intel), arm64 (Apple Silicon)
   - Linux: x64

## 🚀 快速开始

1. 安装依赖：
```bash
npm install
```

2. 构建并打包（以 Windows 为例）：
```bash
npm run electron:build:win
```

3. 查看生成的安装包：
```bash
ls release/
```

## 🔍 故障排查

### 问题：打包速度慢
- 解决：使用国内镜像源，已在 `.npmrc` 中配置

### 问题：缺少图标文件
- 解决：准备相应格式的图标文件放入 `public` 目录

### 问题：跨平台打包失败
- 解决：建议在目标平台上进行打包，或使用 CI/CD 服务（如 GitHub Actions）

## 📊 包大小优化

当前配置已启用以下优化：
- ASAR 压缩
- 最大压缩级别
- 多架构支持

如需进一步优化，可以：
1. 移除未使用的依赖
2. 使用 tree-shaking
3. 按需加载 Tesseract.js 语言数据
