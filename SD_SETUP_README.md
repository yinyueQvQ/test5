# Stable Diffusion 远程服务器配置说明

## 📋 已完成的修改

### 1. **图片输入方式改进** ✅
- **文件**: `StableDiffusionManager.swift`
- **修改**: `combineImages()` 方法
- **效果**: 
  - 所有素材以 70% 透明度叠加
  - 居中保持宽高比
  - 输出固定 512x512 尺寸
  - 白色背景

### 2. **Prompt 生成优化** ✅
- **文件**: `CompositionManager.swift`
- **修改**: `buildPrompt()` 方法
- **效果**:
  - 自动提取素材名字（如"灯泡"和"星星"）
  - 生成格式：`"把灯泡和星星合成一个新的物体, [工艺风格], masterpiece, high quality, detailed"`
  - **已去除白底要求** - 测试看效果更好

### 3. **真实 API 调用** ✅
- **文件**: `StableDiffusionManager.swift`
- **修改**: 新增 `callRemoteSDAPI()` 方法
- **配置**:
  - API 端点: `http://192.168.31.14:8000/generate`
  - 超时: 300秒（5分钟）
  - 参数:
    - `num_inference_steps`: 50
    - `guidance_scale`: 7.5

## 🚀 启动步骤

### 1. 首次安装依赖（只需一次）

```bash
cd /Users/zhuojinli/Desktop/test5
source venv/bin/activate
pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org flask flask-cors pillow paramiko
```

### 2. 启动 Python API 服务器

```bash
cd /Users/zhuojinli/Desktop/test5/test5
source ../venv/bin/activate
python3 server_api_remote.py
```

**✅ 服务器已成功启动！**

服务器状态：
- 监听地址: `http://0.0.0.0:8000`
- 远程服务器: `connect.westc.gpuhub.com:42742`
- SSH客户端: ✅ 可用
- 健康检查: `http://localhost:8000/health`

### 2. 确认 Mac IP 地址

如果 Mac IP 变化，需要更新 `StableDiffusionManager.swift` 第13行：

```swift
private let apiEndpoint = "http://YOUR_MAC_IP:8000/generate"
```

当前配置: `http://192.168.31.14:8000/generate`

### 3. 运行 iOS 应用

在 Xcode 中运行应用，测试合成功能。

## 📝 提示词示例

### 输入素材改名后的效果：

**素材1**: "可爱的灯泡"
**素材2**: "金色星星"
**工艺**: 卡通风格

**生成的完整 Prompt**:
```
把可爱的灯泡和金色星星合成一个新的物体, cartoon style, animated, masterpiece, high quality, detailed
```

## 🔍 调试日志

查看 Xcode 控制台，会打印：

```
🎨 开始 Stable Diffusion 合成
  - 输入素材数量: 2
  - 提示词: 把灯泡和星星合成一个新的物体...
  - 风格: 卡通风格
✅ 图像叠加完成：2张素材，透明度70%
🎨 生成的完整提示词: 把灯泡和星星合成一个新的物体...
🌐 ========== 开始远程 SD API 调用 ==========
📦 图像大小: XXX KB
⏳ 等待远程服务器生成...
📤 请求已发送，等待响应...
📥 收到服务器响应
✅ SD 生成成功！
```

## ⚙️ 参数调整

如果需要调整生成质量，修改 `StableDiffusionManager.swift` 第227-228行：

```swift
let requestBody: [String: Any] = [
    "image": base64Image,
    "prompt": prompt,
    "num_inference_steps": 50,    // 增加步数 = 更细腻但更慢
    "guidance_scale": 7.5         // 增加 = 更贴合提示词
]
```

## 🎨 白底 vs 有背景

**当前配置**: 不强制白底，让 AI 自由发挥

如果想要白底独立物体，在 `buildPrompt()` 中添加：
```swift
fullPrompt += ", white background, isolated object, product photo"
```

测试看哪种效果更好！

## ❓ 常见问题

### Q: 连接超时
- 检查 Python 服务是否运行
- 检查 Mac IP 是否正确
- 检查防火墙设置

### Q: 生成失败
- 查看 Xcode 控制台错误信息
- 查看 Python 服务器日志
- 检查远程服务器连接状态

### Q: 生成时间太长
- 正常情况 30-60 秒
- 取决于远程服务器负载
- 可以调整 `num_inference_steps` 减少步数

## 📊 性能建议

- **素材数量**: 建议 2-3 个，太多会混乱
- **素材大小**: 自动压缩到 512x512
- **图片质量**: JPEG 压缩率 0.9（高质量）
- **生成步数**: 50步（平衡质量和速度）

