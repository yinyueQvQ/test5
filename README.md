# Innoforge

<p align="center">
  <strong>创意锻造，智绘未来</strong><br>
  一款端云协同的 AI 图像创作 iOS 应用
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-iOS%2018.1+-blue" alt="iOS">
  <img src="https://img.shields.io/badge/SwiftUI-5.0-orange" alt="SwiftUI">
  <img src="https://img.shields.io/badge/CoreML-Vision-green" alt="CoreML">
  <img src="https://img.shields.io/badge/Stable%20Diffusion-img2img-purple" alt="SD">
</p>

---

## 简介

**Innoforge** 是一款创新的 AI 创意工具，帮助用户完成从「选图 → 智能抠图 → 风格迁移 → 素材管理 → AI 合成」的完整创作流程。

- **端侧推理**：CoreML 运行 IS-Net 分割 + AnimeGAN 动漫风格迁移，低延迟、可离线
- **云端生成**：Flask API 对接 Stable Diffusion，完成多素材融合创作
- **产品化体验**：自定义 Tab 导航、素材背包、作品管理、引导页与权限体系

## 功能特性

| 模块 | 说明 |
|------|------|
| 智能抠图 | IS-Net 语义分割，支持多区域选取与高亮预览 |
| 风格迁移 | AnimeGAN 端侧推理，透明背景抠图后风格化 |
| 素材背包 | 风格化素材自动入库，UserDefaults 本地持久化 |
| AI 合成台 | 最多 3 张素材 + 6 种工艺风格 + 自定义 Prompt |
| Stable Diffusion | HTTP API 调用云端 img2img 生成 |
| 作品管理 | 草稿、发布、收藏等完整创作闭环 |

## 技术栈

**iOS 客户端**
- Swift · SwiftUI · MVVM
- CoreML · Vision · URLSession
- AVFoundation · Photos（相机/相册权限）

**后端 / 工具链**
- Python · Flask · Flask-CORS
- Stable Diffusion（img2img）
- ngrok（开发阶段公网穿透）
- Paramiko（SSH 远程调用，可选）

## 项目结构

```
innoforge/
├── innoforge.xcodeproj/      # Xcode 工程（主入口）
├── test5/                    # iOS 应用源码
│   ├── *.swift               # SwiftUI 视图与 Manager
│   ├── Assets.xcassets/      # 图片资源
│   ├── animeganPaprika.mlmodel
│   ├── server_api.py         # Flask SD 服务（本地/GPU 服务器）
│   ├── server_api_remote.py  # 远程部署版 API
│   └── client_sd_remote.py   # SSH 远程调用客户端
├── innoforge-stablediff/     # SD 远程调用工具与文档
├── test5Tests/               # 单元测试
├── test5UITests/             # UI 测试
├── docs/
│   └── MODEL_SETUP.md        # CoreML 模型获取说明
└── deploy_to_cloud.sh        # 云服务器部署脚本
```

## 快速开始

### 环境要求

- macOS + Xcode 16+
- iOS 18.1+ 真机或模拟器
- Python 3.10+（仅运行 SD 后端时需要）
- GPU 云服务器（仅完整 SD 合成功能需要）

### 1. 克隆仓库

```bash
git clone https://github.com/<your-username>/innoforge.git
cd innoforge
```

### 2. 配置 CoreML 模型

AnimeGAN 模型已包含在仓库中。IS-Net 分割模型体积较大（~168 MB），需按 [docs/MODEL_SETUP.md](docs/MODEL_SETUP.md) 自行获取并放入 `test5/` 目录。

### 3. 运行 iOS 应用

1. 用 Xcode 打开 `innoforge.xcodeproj`
2. 选择 `innoforge` Target，连接 iPhone 或选择模拟器
3. `Cmd + R` 运行

> 分割与风格迁移功能可在无后端情况下使用；AI 合成功能需配置 SD 服务。

### 4. 配置 Stable Diffusion 后端（可选）

**安装 Python 依赖：**

```bash
cd innoforge-stablediff
pip install -r requirements.txt
```

**启动 Flask API（在 GPU 服务器上）：**

```bash
python test5/server_api.py
# 默认监听 http://0.0.0.0:8000
```

**配置 iOS 客户端 API 地址：**

编辑 `test5/StableDiffusionManager.swift`，修改 `apiEndpoint`：

```swift
// 局域网开发
private let localEndpoint = "http://<你的电脑IP>:8000/generate"

// 公网访问（ngrok）
private let publicEndpoint = "https://<你的ngrok地址>/generate"
```

**开发阶段使用 ngrok：**

```bash
ngrok http 8000
# 将生成的 HTTPS 地址填入 publicEndpoint
```

详细部署步骤见仓库内 `Flask服务云部署指南.md`（中文）。

## 创作流程

```
选图/拍照 → IS-Net 分割 → 选取区域 → AnimeGAN 风格迁移
    → 素材入背包 → 合成台选素材+工艺+Prompt → SD 生成 → 保存/发布
```

## 截图

<!-- 上传截图后取消注释
<p align="center">
  <img src="docs/screenshots/home.png" width="200">
  <img src="docs/screenshots/create.png" width="200">
  <img src="docs/screenshots/compose.png" width="200">
</p>
-->

## 注意事项

- **模型版权**：请确保 CoreML 模型来源合法，遵守原模型许可证
- **API 安全**：勿将服务器密码、ngrok 地址等敏感信息提交到公开仓库
- **ATS 配置**：`Info.plist` 中已开启 `NSAllowsArbitraryLoads` 以支持 HTTP 开发调试，上架前建议收紧
- **GitHub 体积**：`is-net-genral-use.mlmodel` 超过 100 MB，需 Git LFS 或外部下载

## 许可证

本项目仅供学习与交流使用。第三方模型（IS-Net、AnimeGAN、Stable Diffusion）请遵循各自的开源协议。

## 作者

zhuojinli · Innoforge v1.0.0
