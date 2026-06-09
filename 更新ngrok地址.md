# 更新 ngrok 地址

## 🔧 步骤

### 1. 启动 ngrok

在新终端运行：
```bash
ngrok http 5000
```

### 2. 复制 URL

从 ngrok 输出中复制 `Forwarding` 那一行的 URL，比如：
```
https://abc123-def-456.ngrok-free.app
```

### 3. 更新 Swift 代码

打开 `test5/StableDiffusionManager.swift`

找到第 17 行：
```swift
private let publicEndpoint = "https://percurrent-sub-lavette.ngrok-free.dev/generate"
```

修改为你的新 URL：
```swift
private let publicEndpoint = "https://你的ngrok地址.ngrok-free.app/generate"
```

**注意：一定要加 `/generate` 后缀！**

### 4. 重新运行 App

在 Xcode 按 `Cmd+R`

### 5. 拔掉数据线测试

- 拔掉数据线
- 在手机上打开 App
- 测试合成功能

---

## ✅ 成功标志

- 拔掉数据线也能生成图像
- 速度可能稍慢（通过公网）

---

## 🔍 测试 ngrok 连接

在浏览器或终端测试：
```bash
curl https://你的ngrok地址.ngrok-free.app/health
```

应该返回：
```json
{"status": "ok"}
```



