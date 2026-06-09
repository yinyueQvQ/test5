# 🧪 测试指南 - 远程 Stable Diffusion 合成

## ✅ 确认清单

### 1. Python 服务器运行中
```bash
# 检查服务器状态
curl http://localhost:8000/health
```

应该返回：
```json
{
  "status": "ok",
  "ssh_client_available": true,
  "server": "connect.westc.gpuhub.com"
}
```

### 2. iOS 应用配置正确
- ✅ IP地址: `192.168.31.11:8000`
- ✅ 图片叠加: 70%透明度
- ✅ Prompt生成: 自动提取素材名
- ✅ API调用: `callRemoteSDAPI()`

## 📋 测试步骤

### 步骤 1: 准备素材
1. 打开应用，进入创作页
2. 选择/拍摄图片，进行风格迁移
3. 在背包中给素材改名：
   - 素材1: "灯泡"
   - 素材2: "星星"

### 步骤 2: 进入合成台
1. 点击中间的"+"按钮
2. 选择"合成台"标签
3. 从底部素材栏选择2个素材

### 步骤 3: 配置合成
1. 选择工艺风格（如"卡通风格"）
2. （可选）输入自定义提示词
3. 点击"开始合成"按钮

### 步骤 4: 观察日志

#### iOS Xcode 控制台应该输出：
```
🎨 开始合成台 SD 生成
  - 选中素材数量: 2
  - 工艺风格: 卡通风格
  - 自定义提示词: 
✅ [合成台] 图像叠加完成：2张素材，透明度70%
  ✓ 图片合并成功
🎨 生成的完整提示词: 把灯泡和星星合成一个新的物体, cartoon style, animated, masterpiece, high quality, detailed
  ✓ 完整提示词: ...
🎨 ========================================
🎨 [SD Manager] 开始 Stable Diffusion 合成
🎨 ========================================
  - 输入素材数量: 1
  - 提示词: 把灯泡和星星合成一个新的物体...
  - 风格: 卡通风格
  - API端点: http://192.168.31.11:8000/generate
✅ 图像叠加完成：1张素材，透明度70%
🌐 ========== 开始远程 SD API 调用 ==========
📍 API 端点: http://192.168.31.11:8000/generate
🎨 提示词: 把灯泡和星星合成一个新的物体...
📦 图像大小: XXX KB
⏳ 等待远程服务器生成...
📤 请求已发送，等待响应...
📥 收到服务器响应
✅ SD 生成成功！
✅ 合成台 SD 生成成功
```

#### Python 服务器终端应该输出：
```
2025-10-26 XX:XX:XX,XXX - INFO - 127.0.0.1 - - [26/Oct/2025 XX:XX:XX] "POST /generate HTTP/1.1" 200 -
```

## 🔍 调试检查

### 如果没有看到 API 调用日志：

1. **检查代码调用链**:
   ```
   CreateView.swift (点击"开始合成")
     ↓
   CompositionManager.composeWithStableDiffusion()
     ↓
   StableDiffusionManager.generateImage()
     ↓
   StableDiffusionManager.callRemoteSDAPI()
   ```

2. **确认关键日志**:
   - ✅ "🎨 开始合成台 SD 生成"
   - ✅ "✅ [合成台] 图像叠加完成"
   - ✅ "🎨 [SD Manager] 开始 Stable Diffusion 合成"
   - ✅ "🌐 ========== 开始远程 SD API 调用 =========="

3. **检查网络连接**:
   ```bash
   # 在 Mac 终端测试
   curl -X POST http://localhost:8000/generate \
     -H "Content-Type: application/json" \
     -d '{"image":"test","prompt":"test image"}'
   ```

## ⚠️ 常见问题

### Q1: 看到"使用模拟模式生成"
**原因**: 代码调用了旧的 `simulateSDGeneration()` 方法
**解决**: 已修改为 `callRemoteSDAPI()`

### Q2: 网络超时
**原因**: 远程服务器响应慢或连接问题
**解决**: 
- 检查服务器日志
- 增加超时时间（当前300秒）

### Q3: 图片上传失败
**原因**: 图片太大或编码问题
**解决**: 
- 当前使用 JPEG 压缩率 0.9
- 自动调整为 512x512

## 📊 预期结果

- **生成时间**: 30-60秒
- **输出尺寸**: 512x512
- **输出格式**: PNG
- **效果**: 融合了2个素材的新物体

## 🎯 成功标志

1. ✅ Xcode 控制台显示完整日志链
2. ✅ Python 服务器收到 POST 请求
3. ✅ 30-60秒后返回生成的图片
4. ✅ 应用显示合成结果

## 📝 测试记录

记录每次测试：
- 素材名称: ___________
- 工艺风格: ___________
- 生成时间: ___________
- 结果质量: ⭐⭐⭐⭐⭐
- 备注: ___________





















