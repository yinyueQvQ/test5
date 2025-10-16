# 权限配置指南

由于删除了Info.plist文件以解决构建冲突，你需要在Xcode项目设置中手动配置权限描述。

## 📱 在Xcode中配置权限

### 方法1：通过项目设置（推荐）

1. **打开项目设置**
   - 在Xcode中点击项目名称（test5）
   - 选择 `test5` target
   - 点击 `Info` 标签页

2. **添加权限描述**
   在 `Custom iOS Target Properties` 部分，点击 `+` 按钮添加以下键值对：

   **相机权限：**
   - Key: `Privacy - Camera Usage Description`
   - Type: `String`
   - Value: `此应用需要访问相机来拍摄照片进行AI图像分割和风格迁移`

   **相册读取权限：**
   - Key: `Privacy - Photo Library Usage Description`
   - Type: `String`  
   - Value: `此应用需要访问相册来选择照片进行AI图像分割和风格迁移`

   **相册保存权限：**
   - Key: `Privacy - Photo Library Additions Usage Description`
   - Type: `String`
   - Value: `此应用需要访问相册来保存处理后的图片`

### 方法2：直接编辑Target设置

1. 选择项目 → Target → Build Settings
2. 搜索 "Info.plist"  
3. 在 "Info.plist File" 设置中确保路径正确

## 🔧 验证配置

配置完成后：

1. **清理构建缓存**
   ```
   Product → Clean Build Folder (Cmd+Shift+K)
   ```

2. **重新构建项目**
   ```
   Product → Build (Cmd+B)
   ```

3. **测试权限**
   - 运行应用
   - 尝试点击"从相册选择"或"拍摄照片"
   - 应该会弹出权限请求对话框

## ❗ 重要提示

- **必须配置权限描述**：没有权限描述的应用无法在真机上访问相机和相册
- **描述要具体**：Apple审核要求权限描述要说明具体用途
- **支持多语言**：如果需要支持其他语言，可以添加本地化字符串

## 🐛 常见问题

**Q: 构建时提示"Multiple commands produce Info.plist"**
A: 确保项目中只有一个Info.plist文件，删除多余的文件

**Q: 权限请求不弹出**
A: 检查权限描述是否正确配置，重新安装应用

**Q: 真机测试时崩溃**
A: 确保所有权限描述都已配置，检查控制台错误信息

## 📋 完整权限列表

为了应用正常运行，需要配置以下权限：

| 权限键 | 类型 | 描述 |
|--------|------|------|
| `NSCameraUsageDescription` | String | 相机访问权限 |
| `NSPhotoLibraryUsageDescription` | String | 相册读取权限 |
| `NSPhotoLibraryAddUsageDescription` | String | 相册保存权限 |

## ✅ 配置完成检查清单

- [ ] 已添加相机使用描述
- [ ] 已添加相册读取描述  
- [ ] 已添加相册保存描述
- [ ] 项目可以正常构建
- [ ] 真机测试权限请求正常
- [ ] 权限拒绝后有合适的提示

配置完成后，应用就可以正常请求和使用权限了！
