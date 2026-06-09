# 🎨 图文融合提示词示例

## 📝 完整提示词模板

```
A detailed anime-style illustration of a unique object, 
keeping the overall structure while enhancing details. 
Refined lines, vibrant colors, glowing highlights, 
fantasy atmosphere, isolated on a pure white background. 
A new item created by fusing [素材名称1] and [素材名称2] into one coherent design. 
The fusion should incorporate the visual characteristics and symbolic meaning of both [素材名称1] and [素材名称2]. 
The colors should be soft, gentle, and aesthetically pleasing. 
Combine the visual elements from the input image with the conceptual essence of [素材名称1] and [素材名称2]. 
Create a harmonious blend that maintains the recognizable features of [素材名称1] and [素材名称2] while forming a completely new, innovative object. 
The result should be a seamless integration where both [素材名称1] and [素材名称2] contribute their unique qualities to create something entirely new and beautiful.
```

## 🔥 具体示例

### 示例1：灯泡 + 星星
```
A detailed anime-style illustration of a unique object, 
keeping the overall structure while enhancing details. 
Refined lines, vibrant colors, glowing highlights, 
fantasy atmosphere, isolated on a pure white background. 
A new item created by fusing lightbulb and star into one coherent design. 
The fusion should incorporate the visual characteristics and symbolic meaning of both lightbulb and star. 
The colors should be soft, gentle, and aesthetically pleasing. 
Combine the visual elements from the input image with the conceptual essence of lightbulb and star. 
Create a harmonious blend that maintains the recognizable features of lightbulb and star while forming a completely new, innovative object. 
The result should be a seamless integration where both lightbulb and star contribute their unique qualities to create something entirely new and beautiful.
```

### 示例2：花朵 + 蝴蝶
```
A detailed anime-style illustration of a unique object, 
keeping the overall structure while enhancing details. 
Refined lines, vibrant colors, glowing highlights, 
fantasy atmosphere, isolated on a pure white background. 
A new item created by fusing flower and butterfly into one coherent design. 
The fusion should incorporate the visual characteristics and symbolic meaning of both flower and butterfly. 
The colors should be soft, gentle, and aesthetically pleasing. 
Combine the visual elements from the input image with the conceptual essence of flower and butterfly. 
Create a harmonious blend that maintains the recognizable features of flower and butterfly while forming a completely new, innovative object. 
The result should be a seamless integration where both flower and butterfly contribute their unique qualities to create something entirely new and beautiful.
```

### 示例3：月亮 + 猫
```
A detailed anime-style illustration of a unique object, 
keeping the overall structure while enhancing details. 
Refined lines, vibrant colors, glowing highlights, 
fantasy atmosphere, isolated on a pure white background. 
A new item created by fusing moon and cat into one coherent design. 
The fusion should incorporate the visual characteristics and symbolic meaning of both moon and cat. 
The colors should be soft, gentle, and aesthetically pleasing. 
Combine the visual elements from the input image with the conceptual essence of moon and cat. 
Create a harmonious blend that maintains the recognizable features of moon and cat while forming a completely new, innovative object. 
The result should be a seamless integration where both moon and cat contribute their unique qualities to create something entirely new and beautiful.
```

## 🎯 提示词结构解析

### 1. 基础描述
- `A detailed anime-style illustration of a unique object` - 指定风格和类型
- `keeping the overall structure while enhancing details` - 保持结构，增强细节

### 2. 视觉特征
- `Refined lines, vibrant colors, glowing highlights` - 精致线条，鲜艳色彩，发光高光
- `fantasy atmosphere, isolated on a pure white background` - 奇幻氛围，纯白背景

### 3. 融合概念
- `A new item created by fusing [素材名称] into one coherent design` - 融合素材创建新物品
- `incorporate the visual characteristics and symbolic meaning` - 结合视觉特征和象征意义

### 4. 图文结合
- `Combine the visual elements from the input image with the conceptual essence` - 结合输入图像的视觉元素和概念本质
- `Create a harmonious blend` - 创建和谐融合

### 5. 质量要求
- `high quality, detailed, sharp focus, single object, masterpiece` - 高质量，详细，锐利焦点，单一对象，杰作

## 🔧 技术实现

### iOS App 中的实现
```swift
private func buildPrompt() -> String {
    let materialNames = selectedMaterials.map { $0.name }.joined(separator: " and ")
    
    var fullPrompt = "A detailed anime-style illustration of a unique object, "
    fullPrompt += "keeping the overall structure while enhancing details. "
    fullPrompt += "Refined lines, vibrant colors, glowing highlights, "
    fullPrompt += "fantasy atmosphere, isolated on a pure white background. "
    fullPrompt += "A new item created by fusing \(materialNames) into one coherent design. "
    fullPrompt += "The fusion should incorporate the visual characteristics and symbolic meaning of both \(materialNames). "
    fullPrompt += "The colors should be soft, gentle, and aesthetically pleasing. "
    fullPrompt += "Combine the visual elements from the input image with the conceptual essence of \(materialNames). "
    fullPrompt += "Create a harmonious blend that maintains the recognizable features of \(materialNames) while forming a completely new, innovative object. "
    fullPrompt += "The result should be a seamless integration where both \(materialNames) contribute their unique qualities to create something entirely new and beautiful."
    
    return fullPrompt
}
```

### Python 服务器调用
```bash
python scripts/img2img.py \
  --prompt "A detailed anime-style illustration of a unique object, keeping the overall structure while enhancing details. Refined lines, vibrant colors, glowing highlights, fantasy atmosphere, isolated on a pure white background. A new item created by fusing lightbulb and star into one coherent design. The fusion should incorporate the visual characteristics and symbolic meaning of both lightbulb and star. The colors should be soft, gentle, and aesthetically pleasing. Combine the visual elements from the input image with the conceptual essence of lightbulb and star. Create a harmonious blend that maintains the recognizable features of lightbulb and star while forming a completely new, innovative object. The result should be a seamless integration where both lightbulb and star contribute their unique qualities to create something entirely new and beautiful." \
  --init-img "path/to/input/image.jpg" \
  --ckpt "path/to/model.ckpt"
```

## 💡 使用建议

1. **素材命名要具体**：使用具体的名词，如"灯泡"、"星星"、"花朵"等
2. **避免抽象概念**：不要使用过于抽象的名称，如"美丽"、"创意"等
3. **保持简洁**：素材名称应该简洁明了，便于AI理解
4. **图文结合**：确保输入图像与素材名称相关，这样融合效果更好
5. **风格一致**：选择与目标风格匹配的素材名称和图像

