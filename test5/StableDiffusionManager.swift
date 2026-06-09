import Foundation
import UIKit

class StableDiffusionManager: ObservableObject {
    @Published var isGenerating = false
    @Published var progress: String = ""
    @Published var generatedImage: UIImage?
    @Published var errorMessage: String?
    
    // MARK: - 配置
    
    // 🌐 服务器地址配置
    // 选项1：局域网访问（开发用，速度快）
    private let localEndpoint = "http://192.168.31.11:8000/generate"
    
    // 选项2：公网访问（使用ngrok）
    // ⚠️ 每次启动 ngrok 都需要更新这个地址！
    // 运行: ngrok http 8000，然后复制 Forwarding 地址，记得加 /generate
    private let publicEndpoint = "https://percurrent-sub-lavette.ngrok-free.dev/generate"
    
    // 🔧 切换这里来选择使用哪个地址
    private var apiEndpoint: String {
    // return localEndpoint   // 使用局域网地址
        return publicEndpoint      // 使用公网地址
    }
    
    // MARK: - 生成图像
    func generateImage(
        inputImages: [UIImage],
        materialNames: [String], // 添加素材名称参数
        prompt: String,
        styleType: CraftingRecipe.StyleType,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        isGenerating = true
        errorMessage = nil
        progress = "准备合成..."
        
        print("🎨🎨🎨 【StableDiffusionManager】开始 Stable Diffusion 合成")
        print("  - 输入素材数量: \(inputImages.count)")
        print("  - 素材名称: \(materialNames.joined(separator: ", "))")
        print("  - 基础提示词: '\(prompt)'")
        print("  - 风格: \(styleType.rawValue)")
        
        // 检查输入图像
        for (index, image) in inputImages.enumerated() {
            print("  - 输入图像[\(index)]: \(image.size.width)x\(image.size.height)")
        }
        
        // 组合所有输入图像
        print("  🔄 开始合并图像...")
        guard let combinedImage = combineImages(inputImages) else {
            let error = NSError(domain: "SD", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法组合输入图像"])
            print("  ❌❌❌ 图像合并失败！")
            errorMessage = error.localizedDescription
            isGenerating = false
            completion(.failure(error))
            return
        }
        
        print("  ✅ 图像合并成功: \(combinedImage.size.width)x\(combinedImage.size.height)")
        
        // 构建完整的提示词
        print("  📝 构建提示词...")
        let fullPrompt = buildPrompt(
            basePrompt: prompt,
            styleType: styleType,
            materialNames: materialNames
        )
        print("  ✅ 完整提示词: \(fullPrompt.prefix(200))...")
        
        // ✨ 使用真实 HTTP API 调用（通过隧道）
        print("  🌐 准备调用 HTTP API...")
        callSDAPI(inputImage: combinedImage, prompt: fullPrompt, completion: completion)
    }
    
    // MARK: - 组合多个图像
    private func combineImages(_ images: [UIImage]) -> UIImage? {
        guard !images.isEmpty else { return nil }
        
        if images.count == 1 {
            return images[0]
        }
        
        // 计算网格布局
        let gridSize = Int(ceil(sqrt(Double(images.count))))
        let imageSize: CGFloat = 512
        let totalSize = CGSize(width: imageSize * CGFloat(gridSize), height: imageSize * CGFloat(gridSize))
        
        UIGraphicsBeginImageContextWithOptions(totalSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // 填充白色背景
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: totalSize))
        
        // 绘制每个图像
        for (index, image) in images.enumerated() {
            let row = index / gridSize
            let col = index % gridSize
            let x = CGFloat(col) * imageSize
            let y = CGFloat(row) * imageSize
            
            image.draw(in: CGRect(x: x, y: y, width: imageSize, height: imageSize))
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    // MARK: - 构建提示词
    private func buildPrompt(basePrompt: String, styleType: CraftingRecipe.StyleType, materialNames: [String]) -> String {
        // 核心概念：融合两个素材成为一个新物品
        let fusionConcept = "a single creative fusion object that seamlessly merges \(materialNames.joined(separator: " and "))"
        
        // 通用的高质量描述（不限定风格）
        let qualityDescription = "highly detailed, creative design, harmonious fusion, recognizable elements from both materials, innovative product design, isolated on pure white background"
        
        // 根据工艺风格选择对应的风格描述
        let styleDescription: String
        switch styleType {
        case .anime:
            styleDescription = "anime style illustration, vibrant colors, magical atmosphere, glowing effects, soft lighting, Studio Ghibli aesthetic"
        case .realistic:
            styleDescription = "photorealistic render, 8k, professional product photography, studio lighting, ultra sharp focus, physically accurate materials"
        case .watercolor:
            styleDescription = "watercolor painting style, soft colors, artistic brushstrokes, elegant and delicate, traditional art"
        case .oilPainting:
            styleDescription = "oil painting style, rich textures, classical art, dramatic lighting, masterful brushwork"
        case .sketch:
            styleDescription = "detailed pencil sketch, hand-drawn, artistic linework, shading and depth, traditional drawing"
        case .cyberpunk:
            styleDescription = "cyberpunk style, futuristic design, neon accents, high-tech materials, sci-fi aesthetic, blade runner inspired"
        }
        
        // 组合提示词（移除冲突的 anime-style 描述）
        if basePrompt.isEmpty {
            return "\(fusionConcept), \(styleDescription), \(qualityDescription)"
        } else {
            return "\(basePrompt), \(fusionConcept), \(styleDescription), \(qualityDescription)"
        }
    }
    
    // MARK: - 模拟 SD 生成（开发/测试用）
    private func simulateSDGeneration(
        inputImage: UIImage,
        prompt: String,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        progress = "正在连接服务器..."
        
        print("⚠️  使用模拟模式生成（非真实 SD）")
        
        // 模拟网络延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.progress = "正在生成图像..."
            
            // 模拟生成过程
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                guard let self = self else { return }
                
                // 创建模拟结果
                let resultImage = self.createPlaceholderResult(inputImage: inputImage, prompt: prompt)
                
                self.generatedImage = resultImage
                self.isGenerating = false
                self.progress = "生成完成！"
                
                completion(.success(resultImage))
                
                print("✅ SD 合成完成（模拟）")
            }
        }
    }
    
    // MARK: - 创建占位符结果（用于演示）
    private func createPlaceholderResult(inputImage: UIImage, prompt: String) -> UIImage {
        let size = CGSize(width: 512, height: 512)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return inputImage }
        
        // 创建渐变背景
        let colors = [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor, UIColor.systemPink.cgColor]
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0.0, 0.5, 1.0])!
        
        context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: 0), end: CGPoint(x: size.width, y: size.height), options: [])
        
        // 绘制输入图像作为水印
        let watermarkSize = CGSize(width: size.width * 0.3, height: size.height * 0.3)
        let watermarkRect = CGRect(
            x: (size.width - watermarkSize.width) / 2,
            y: (size.height - watermarkSize.height) / 2,
            width: watermarkSize.width,
            height: watermarkSize.height
        )
        
        context.setAlpha(0.3)
        inputImage.draw(in: watermarkRect)
        context.setAlpha(1.0)
        
        // 添加装饰性元素
        context.setFillColor(UIColor.white.withAlphaComponent(0.8).cgColor)
        context.fillEllipse(in: CGRect(x: 50, y: 50, width: 80, height: 80))
        context.fillEllipse(in: CGRect(x: size.width - 130, y: size.height - 130, width: 60, height: 60))
        
        // 添加提示词信息
        let text = "AI 生成结果\n\(prompt.prefix(30))..."
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 20),
            .foregroundColor: UIColor.white,
            .strokeColor: UIColor.black,
            .strokeWidth: -2
        ]
        let textSize = text.size(withAttributes: attributes)
        let textRect = CGRect(
            x: (size.width - textSize.width) / 2,
            y: size.height - 80,
            width: textSize.width,
            height: textSize.height
        )
        text.draw(in: textRect, withAttributes: attributes)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? inputImage
    }
    
    // MARK: - HTTP API 调用（真实 SD 服务器）
    private func callSDAPI(
        inputImage: UIImage,
        prompt: String,
        completion: @escaping (Result<UIImage, Error>) -> Void
    ) {
        print("🌐 ========== 开始 API 调用 ==========")
        print("📍 API 端点: \(apiEndpoint)")
        
        progress = "正在上传图像..."
        
        // 优化：降低压缩质量以加快上传速度（0.6-0.7 通常足够且更快）
        guard let imageData = inputImage.jpegData(compressionQuality: 0.6) else {
            let error = NSError(domain: "SD", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法编码图像"])
            print("❌ 图像编码失败")
            completion(.failure(error))
            return
        }
        
        print("📦 图像大小: \(imageData.count / 1024) KB (压缩后)")
        
        let base64Image = imageData.base64EncodedString()
        
        // 构建请求
        guard let url = URL(string: apiEndpoint) else {
            let error = NSError(domain: "SD", code: -1, userInfo: [NSLocalizedDescriptionKey: "无效的 API 端点"])
            print("❌ 无效的 URL: \(apiEndpoint)")
            completion(.failure(error))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 300  // 5分钟超时（考虑到模型加载和HuggingFace警告）
        
        // 添加随机种子确保每次生成结果不同
        let randomSeed = Int.random(in: 1...999999999)
        
        let requestBody: [String: Any] = [
            "prompt": prompt,
            "image_base64": base64Image,
            "steps": 25,           // 降低步数以加快速度
            "strength": 0.75,      // 增加强度让AI更积极地融合素材
            "cfg_scale": 10.0,     // 略微降低以允许更多创造性
            "seed": randomSeed
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            print("✅ 请求体已构建")
            print("📝 提示词: \(prompt)")
        } catch {
            print("❌ 请求体构建失败: \(error)")
            completion(.failure(error))
            return
        }
        
        progress = "正在生成..."
        print("🚀 发送 HTTP 请求...")
        
        // 发送请求
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ 网络错误: \(error.localizedDescription)")
                    print("   错误代码: \((error as NSError).code)")
                    print("   错误域: \((error as NSError).domain)")
                    
                    // 检查是否是超时错误
                    if (error as NSError).code == -1001 {
                        self?.errorMessage = "请求超时，请检查网络连接或稍后重试"
                    } else {
                        self?.errorMessage = "连接失败: \(error.localizedDescription)"
                    }
                    
                    self?.isGenerating = false
                    completion(.failure(error))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("📡 HTTP 状态码: \(httpResponse.statusCode)")
                }
                
                guard let data = data else {
                    let error = NSError(domain: "SD", code: -1, userInfo: [NSLocalizedDescriptionKey: "无响应数据"])
                    print("❌ 无响应数据")
                    self?.errorMessage = error.localizedDescription
                    self?.isGenerating = false
                    completion(.failure(error))
                    return
                }
                
                print("📥 收到响应: \(data.count) 字节")
                
                // 解析响应
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        print("📄 响应 JSON: \(json.keys.joined(separator: ", "))")
                        
                        let success = json["success"] as? Bool ?? false
                        print("   success: \(success)")
                        
                        if success,
                           let images = json["images"] as? [String],
                           let firstImage = images.first {
                            print("✅ 成功获取 \(images.count) 张图像")
                            print("   Base64 长度: \(firstImage.count)")
                            
                            guard let imageData = Data(base64Encoded: firstImage),
                                  let resultImage = UIImage(data: imageData) else {
                                throw NSError(domain: "SD", code: -1, userInfo: [NSLocalizedDescriptionKey: "图像解码失败"])
                            }
                            
                            print("✅ 图像解码成功: \(resultImage.size.width)x\(resultImage.size.height)")
                            print("🌐 ========== API 调用成功 ==========")
                            
                            self?.generatedImage = resultImage
                            self?.isGenerating = false
                            self?.progress = "生成完成！"
                            completion(.success(resultImage))
                        } else {
                            let errorMsg = json["error"] as? String ?? "未知错误"
                            print("❌ 服务器返回失败: \(errorMsg)")
                            throw NSError(domain: "SD", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMsg])
                        }
                    } else {
                        throw NSError(domain: "SD", code: -1, userInfo: [NSLocalizedDescriptionKey: "解析响应失败"])
                    }
                } catch {
                    print("❌ 解析错误: \(error.localizedDescription)")
                    print("🌐 ========== API 调用失败 ==========")
                    self?.errorMessage = error.localizedDescription
                    self?.isGenerating = false
                    completion(.failure(error))
                }
            }
        }.resume()
        
        print("⏳ 等待服务器响应（最多 5 分钟）...")
    }
    
    // MARK: - 重置
    func reset() {
        isGenerating = false
        progress = ""
        generatedImage = nil
        errorMessage = nil
    }
}


