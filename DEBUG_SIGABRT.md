# 🚨 SIGABRT 崩溃调试指南

## 问题描述
应用启动时出现 `Thread 11: signal SIGABRT` 错误，这通常是运行时崩溃。

## 🔍 可能的原因

### 1. 权限描述缺失（最可能）
即使项目能构建成功，运行时仍可能因为缺少隐私权限描述而崩溃。

### 2. CoreML模型问题
- 模型文件损坏或格式不兼容
- 模型加载路径错误

### 3. 其他运行时错误
- 内存问题
- 未处理的异常

## 🛠️ 调试步骤

### 第1步：检查控制台错误
1. 在Xcode中运行应用
2. 当崩溃发生时，查看控制台输出
3. 寻找详细的错误信息

### 第2步：确认权限配置
**在Xcode中检查：**
1. 选择项目 → `test5` target → `Info` 标签页
2. 确认是否存在以下权限：
   - `Privacy - Camera Usage Description`
   - `Privacy - Photo Library Usage Description`
   - `Privacy - Photo Library Additions Usage Description`

### 第3步：验证模型文件
检查以下文件是否存在且完整：
- `test5/animeganPaprika.mlmodel`
- `test5/is-net-genral-use.mlmodel`

## 🚀 快速修复方案

### 方案1：添加权限描述
如果还没有配置权限，在Xcode项目设置中添加：

```
Key: Privacy - Camera Usage Description
Value: 此应用需要访问相机来拍摄照片进行AI图像分割和风格迁移

Key: Privacy - Photo Library Usage Description  
Value: 此应用需要访问相册来选择照片进行AI图像分割和风格迁移

Key: Privacy - Photo Library Additions Usage Description
Value: 此应用需要访问相册来保存处理后的图片
```

### 方案2：临时禁用权限请求
如果需要快速测试，可以临时注释掉权限相关代码：

1. 打开 `ContentView.swift`
2. 找到权限请求代码
3. 临时注释掉，直接显示图片选择器

### 方案3：检查模型加载
在模型管理器中添加更多错误处理和日志。

## 📱 测试步骤

1. **清理重建**
   ```
   Product → Clean Build Folder (Cmd+Shift+K)
   Product → Build (Cmd+B)
   ```

2. **运行并观察**
   ```
   Product → Run (Cmd+R)
   ```

3. **查看控制台**
   - 在Xcode底部打开控制台
   - 查看详细错误信息

## 🔧 常见解决方案

### SIGABRT + 权限问题
```
NSPhotoLibraryUsageDescription缺失
→ 在项目Info中添加权限描述
```

### SIGABRT + 模型加载失败
```
Cannot find model file
→ 检查模型文件是否正确添加到项目
```

### SIGABRT + 内存问题
```
EXC_BAD_ACCESS
→ 检查是否有循环引用或内存泄漏
```

## 📊 收集调试信息

请提供以下信息帮助进一步诊断：

1. **完整错误信息**
   - Xcode控制台中的完整错误日志
   - 崩溃发生的具体时机

2. **权限配置状态**
   - 是否已添加权限描述
   - 权限描述的具体内容

3. **模型文件状态**
   - 模型文件大小
   - 是否正确添加到项目

## ⚡ 紧急修复

如果需要立即修复，创建一个最小化版本：

```swift
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("AI图像处理")
                .font(.title)
            Text("正在调试中...")
                .foregroundColor(.gray)
        }
        .padding()
    }
}
```

这样可以确保应用至少能启动，然后逐步添加功能。
