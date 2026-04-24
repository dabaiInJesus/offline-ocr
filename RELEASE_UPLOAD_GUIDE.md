# GitHub Release 上传指南

## 📦 已生成的 Windows 安装包

以下文件位于 `release/` 目录:

1. **离线OCR识别工具-1.0.0-win.exe** (180MB) - NSIS 安装程序,支持 x64 和 ia32
2. **离线OCR识别工具-1.0.0-win-x64.exe** (97MB) - 64位独立安装包
3. **离线OCR识别工具-1.0.0-win-ia32.exe** (84MB) - 32位独立安装包
4. **离线OCR识别工具-1.0.0-win-x64.zip** (134MB) - 便携版(免安装)

## 🚀 上传方法

### 方法一:使用 GitHub CLI (推荐)

1. **安装 GitHub CLI**
   ```bash
   # Windows (使用 winget)
   winget install --id GitHub.cli
   
   # 或访问 https://cli.github.com/ 下载安装
   ```

2. **登录 GitHub**
   ```bash
   gh auth login
   ```
   按照提示完成认证

3. **运行上传脚本**
   ```bash
   upload-release.bat
   ```

### 方法二:手动上传 (最简单)

1. **访问 Release 页面**
   ```
   https://github.com/dabaiInJesus/offline-ocr/releases/tag/v1.0.0
   ```

2. **编辑 Release**
   - 点击 "Edit" 按钮
   - 滚动到 "Attach binaries by dropping them here or selecting them" 区域

3. **上传文件**
   - 拖拽以下文件到上传区域:
     - `release/离线OCR识别工具-1.0.0-win.exe`
     - `release/离线OCR识别工具-1.0.0-win-x64.exe`
     - `release/离线OCR识别工具-1.0.0-win-ia32.exe`
     - `release/离线OCR识别工具-1.0.0-win-x64.zip`

4. **发布 Release**
   - 等待所有文件上传完成
   - 点击 "Update release" 按钮

### 方法三:使用 GitHub Actions (自动化)

已配置自动化工作流,当推送 tag 时会自动打包并发布:

```bash
# 推送 tag 触发自动打包
git push origin v1.0.0
```

或在 GitHub 网页端手动触发:
1. 访问: https://github.com/dabaiInJesus/offline-ocr/actions
2. 选择 "Build and Release" 工作流
3. 点击 "Run workflow"
4. 输入版本号 (如 v1.0.0)
5. 点击 "Run workflow"

## 📝 Release 说明模板

```markdown
## 离线OCR识别工具 v1.0.0

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
```

## 🌐 Linux 和 macOS 打包

由于当前在 Windows 系统上,需要其他方式打包 Linux 和 macOS:

### Linux 打包
```bash
# 使用 WSL2
npm run electron:build:linux

# 或使用 Docker
docker run --rm -it \
  -v ${PWD}:/project \
  electronuserland/builder:wine \
  npm run electron:build:linux
```

### macOS 打包
需要在 macOS 系统上运行:
```bash
npm run electron:build:mac
```

### 使用 GitHub Actions (推荐)
推送 tag 后,GitHub Actions 会自动在三个平台上打包:
```bash
git tag v1.0.1
git push origin v1.0.1
```

## ✅ 验证上传

上传完成后,访问:
```
https://github.com/dabaiInJesus/offline-ocr/releases
```

确认:
- [ ] Release 标题正确
- [ ] 描述信息完整
- [ ] 所有文件已上传
- [ ] 文件大小正确
- [ ] 可以正常下载

## 📊 当前状态

- ✅ 代码已推送到 GitHub
- ✅ Tag v1.0.0 已创建
- ✅ Windows 包已编译完成
- ⏳ 等待上传到 Release

## 🔗 相关链接

- GitHub 仓库: https://github.com/dabaiInJesus/offline-ocr
- Releases 页面: https://github.com/dabaiInJesus/offline-ocr/releases
- Actions 页面: https://github.com/dabaiInJesus/offline-ocr/actions
