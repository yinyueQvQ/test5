# 🧪 完整测试步骤 - 无线模式

## ✅ 配置确认（已完成）

- ✅ ngrok 运行在 8000 端口
- ✅ URL: https://percurrent-sub-lavette.ngrok-free.dev
- ✅ Swift 使用 publicEndpoint
- ✅ URL 可以访问（HTTP 200）

**你的配置完全正确！**

---

## 🚀 测试步骤

### 第 1 步：Clean Build（重要！）

在 Xcode 中：
```
Product → Clean Build Folder (Cmd+Shift+K)
```

然后重新运行：
```
Product → Run (Cmd+R)
```

**为什么要 Clean：** 确保使用最新的代码，不是缓存的旧版本

---

### 第 2 步：连着数据线先测试一次

1. **保持数据线连接**
2. **在 App 中选择 2 个素材**（避免预设组合）
3. **点击"开始合成"**
4. **观察 Xcode 控制台**

**应该看到：**
```
✅✅✅ 没有匹配任何预设组合，进入【真实AI合成】流程
🌐 ========== 开始 API 调用 ==========
📍 API 端点: https://percurrent-sub-lavette.ngrok-free.dev/generate
🚀 发送 HTTP 请求...
📡 HTTP 状态码: 200
✅ 合成台 SD 生成成功
```

**如果这步失败：** 把 Xcode 控制台的错误发给我

---

### 第 3 步：拔掉数据线测试

1. **拔掉数据线**
2. **确认手机有网络**
   - 打开 Safari 随便访问一个网站
   - 确认 Wi-Fi 或蜂窝数据正常
3. **在 App 中测试合成**

**注意：** 
- 拔掉数据线后看不到 Xcode 日志了
- 所以要在第 2 步确认能工作

---

### 第 4 步：如果失败，重新连数据线查看日志

1. **重新连上数据线**
2. **在 Xcode 中查看日志**
3. **搜索 `❌` 找到错误信息**

---

## 🔍 常见错误和解决方案

### 错误 1：The resource could not be loaded (NSURLErrorDomain -1009)

**症状：**
```
❌ 网络错误: The Internet connection appears to be offline
```

**原因：** 手机没有网络连接

**解决：**
- 打开设置 → Wi-Fi，确认已连接
- 打开设置 → 蜂窝网络，确认已启用
- 在 Safari 测试能否上网

---

### 错误 2：SSL error (NSURLErrorDomain -1200)

**症状：**
```
❌ 网络错误: An SSL error has occurred
```

**原因：** iOS 的 App Transport Security (ATS) 阻止了连接

**解决：** 检查 Info.plist 中的网络权限

---

### 错误 3：Request timeout (NSURLErrorDomain -1001)

**症状：**
```
❌ 网络错误: The request timed out
```

**原因：** 
- ngrok 停止运行了
- 网络太慢
- 服务器没响应

**解决：**
- 检查 ngrok 进程：`ps aux | grep ngrok`
- 测试 URL：`curl https://percurrent-sub-lavette.ngrok-free.dev/health`

---

### 错误 4：ngrok 浏览器拦截页面

**症状：** 第一次访问 ngrok URL 时可能会显示一个确认页面

**解决：**
1. 在电脑浏览器打开：https://percurrent-sub-lavette.ngrok-free.dev/health
2. 如果看到 ngrok 警告页面，点击 "Visit Site"
3. 之后就不会再弹出了

---

## 📱 检查 iOS 网络权限

打开 `test5/Info.plist`，确认有这些配置：

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

**如果没有：** 需要添加这个配置

---

## 🧪 手动测试 ngrok URL

在电脑上测试：

### 测试 1：健康检查
```bash
curl https://percurrent-sub-lavette.ngrok-free.dev/health
```

应该返回：
```json
{"status": "ok"}
```

---

### 测试 2：完整请求（模拟 App）
```bash
curl -X POST https://percurrent-sub-lavette.ngrok-free.dev/generate \
  -H "Content-Type: application/json" \
  -d '{
    "prompt": "test object",
    "image_base64": "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
    "steps": 25,
    "strength": 0.75
  }' \
  --max-time 300
```

如果成功，应该返回包含 `"success": true` 的 JSON。

---

## 🎯 最可能的问题

### 如果连数据线能用，不连就不行

**99% 是以下原因之一：**

#### 1. App 没有重新编译
- **解决：** Clean Build (Cmd+Shift+K) 然后重新运行 (Cmd+R)

#### 2. 手机没有网络
- **解决：** 检查 Wi-Fi/蜂窝数据设置

#### 3. ngrok 浏览器拦截
- **解决：** 在浏览器先访问一次 ngrok URL，点击 "Visit Site"

#### 4. iOS 缓存了错误结果
- **解决：** 删除 App 重新安装（在 Xcode 中长按 Stop 按钮选择 "Clean"）

---

## 🔧 高级排查

如果上述都不行，添加更详细的网络日志：

在 `StableDiffusionManager.swift` 的 `callSDAPI` 函数开头添加：

```swift
print("🌐 【网络配置】")
print("  - URL: \(apiEndpoint)")
print("  - 完整 URL: \(url.absoluteString)")
print("  - 是否使用公网地址: \(apiEndpoint == publicEndpoint)")
print("  - 网络可达性: \(UIApplication.shared.canOpenURL(url) ? "是" : "否")")
```

---

## ✅ 成功标志

**连数据线时：**
- ✅ Xcode 显示 "HTTP 状态码: 200"
- ✅ App 显示生成的图像

**不连数据线时：**
- ✅ App 显示生成的图像
- ✅ 时间可能稍长（通过公网）

---

## 📞 下一步

1. **Clean Build + 重新运行**
2. **连数据线测试一次**（确认能工作）
3. **拔数据线测试**
4. **如果失败，重新连上数据线查看 Xcode 日志**
5. **把错误信息发给我**

---

更新时间：2025-11-02 01:25



