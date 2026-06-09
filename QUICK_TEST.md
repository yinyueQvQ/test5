# ⚡ 快速测试 - 5分钟验证流程

## ✅ 当前配置状态

### 代码调用链（已确认）
```
CreateView
    ↓ 点击"开始合成"
CompositionManager.composeWithStableDiffusion()
    ↓ 素材叠加 + 提示词构建
StableDiffusionManager.generateImage()
    ↓ 图像处理
StableDiffusionManager.callRemoteSDAPI()
    ↓ HTTP POST
Python Flask Server (localhost:8000)
    ↓ SSH连接
远程 GPU 服务器 (connect.westc.gpuhub.com:42742)
    ↓ Stable Diffusion 模型
返回生成图像 ✨
```

## 🚀 3步快速测试

### 1️⃣ 确认服务器（5秒）
```bash
curl http://localhost:8000/health
```
看到 `"status": "ok"` ✅

### 2️⃣ 在应用中测试（2分钟）
1. 打开应用
2. 创作 → 风格迁移 → 保存素材
3. 背包 → 长按素材改名（"灯泡"、"星星"）
4. 点击中间"+" → 合成台
5. 选择2个素材
6. 选择卡通风格
7. 点击"开始合成"

### 3️⃣ 观察日志（等待60秒）
**Xcode 控制台必须看到：**
```
🎨 开始合成台 SD 生成
✅ [合成台] 图像叠加完成：2张素材，透明度70%
🎨 [SD Manager] 开始 Stable Diffusion 合成
🌐 ========== 开始远程 SD API 调用 ==========
📍 API 端点: http://192.168.31.11:8000/generate
📦 图像大小: XXX KB
⏳ 等待远程服务器生成...
📤 请求已发送，等待响应...
```

**Python 终端必须看到：**
```
127.0.0.1 - - [26/Oct/2025 XX:XX:XX] "POST /generate HTTP/1.1" 200 -
```

## ⚠️ 如果没有看到 API 调用

### 检查1: 确认使用的是 CreateView
在 `CreateView.swift` 第749行：
```swift
compositionManager.composeWithStableDiffusion()
```

### 检查2: 确认 StableDiffusionManager 调用链
在 `StableDiffusionManager.swift` 第44行应该是：
```swift
callRemoteSDAPI(inputImage: combinedImage, prompt: fullPrompt, completion: completion)
```

**不应该是**：
```swift
simulateSDGeneration(...)  // ❌ 旧代码
```

### 检查3: 确认网络可达
```bash
ping 192.168.31.11
```

## 📊 成功标志

- ✅ Xcode: "🌐 开始远程 SD API 调用"
- ✅ Python: "POST /generate HTTP/1.1 200"
- ✅ 等待30-60秒
- ✅ 显示合成结果

## 🎯 立即测试！

按照上面3步执行，如果看到完整日志链，说明已经成功连接到远程服务器！

---

**提示**: 
- 首次生成可能需要60秒
- 确保Mac和iPhone在同一WiFi
- 服务器后台运行中（port 8000）





















