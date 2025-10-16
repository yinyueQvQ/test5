# 修复Info.plist权限配置问题

## 🚨 问题说明
应用崩溃是因为缺少隐私权限描述。我已经重新创建了`Info.plist`文件，但需要在Xcode中正确配置。

## ✅ 解决步骤

### 方法1：在Xcode中配置（推荐）

1. **打开Xcode项目**
   - 打开 `test5.xcodeproj`

2. **选择项目设置**
   - 点击左侧导航栏中的项目名称 `test5`
   - 选择 `test5` target（不是项目）
   - 点击 `Build Settings` 标签页

3. **配置Info.plist路径**
   - 搜索 "Info.plist"
   - 找到 `Info.plist File` 设置
   - 确保值为 `test5/Info.plist`

4. **验证权限描述**
   - 点击 `Info` 标签页
   - 在 `Custom iOS Target Properties` 中应该看到：
     - `Privacy - Camera Usage Description`
     - `Privacy - Photo Library Usage Description`  
     - `Privacy - Photo Library Additions Usage Description`

### 方法2：手动添加到项目

1. **添加文件到项目**
   - 右键点击 `test5` 文件夹
   - 选择 `Add Files to "test5"`
   - 选择刚创建的 `Info.plist` 文件
   - 确保 `Add to target` 选中了 `test5`

2. **配置构建设置**
   - 按照方法1的步骤3配置路径

## 🔧 验证步骤

完成配置后：

1. **清理构建**
   ```
   Product → Clean Build Folder (Cmd+Shift+K)
   ```

2. **重新构建**
   ```
   Product → Build (Cmd+B)
   ```

3. **测试应用**
   - 运行应用
   - 尝试访问相册功能
   - 应该弹出权限请求对话框而不是崩溃

## 📋 Info.plist内容

已创建的`test5/Info.plist`文件包含：

```xml
<key>NSCameraUsageDescription</key>
<string>此应用需要访问相机来拍摄照片进行AI图像分割和风格迁移</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>此应用需要访问相册来选择照片进行AI图像分割和风格迁移</string>

<key>NSPhotoLibraryAddUsageDescription</key>
<string>此应用需要访问相册来保存处理后的图片</string>
```

## ❗ 重要提示

- 确保Info.plist文件在Xcode项目中正确引用
- 权限描述必须准确说明使用目的
- 如果仍然崩溃，检查控制台错误信息
- 可能需要删除应用重新安装以清除权限缓存

## 🐛 故障排除

**问题：构建时提示"Multiple commands produce Info.plist"**
- 检查是否有多个Info.plist文件
- 确保Build Settings中只配置了一个Info.plist路径

**问题：权限仍然不工作**
- 删除设备上的应用
- 重新安装并测试
- 检查模拟器设置中的隐私权限

**问题：找不到Info.plist文件**
- 确保文件在正确位置 (`test5/Info.plist`)
- 在Xcode文件导航器中应该能看到该文件
- 如果看不到，需要手动添加到项目中
