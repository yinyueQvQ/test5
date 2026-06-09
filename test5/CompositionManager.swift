import Foundation
import SwiftUI
import Combine
import UIKit

// 选中的素材包装 - 记录原始BackpackItem的ID和名称
struct SelectedMaterial: Identifiable {
    let id = UUID()
    let backpackItemId: UUID  // 原始BackpackItem的ID
    let name: String
    let image: UIImage?
}

class CompositionManager: ObservableObject {
    // 单例模式
    static let shared = CompositionManager()
    
    @Published var selectedMaterials: [SelectedMaterial] = []
    @Published var composedResult: UIImage? = nil
    @Published var isProcessing = false
    @Published var errorMessage: String? = nil
    @Published var selectedCraftStyle: CraftStyle? = nil
    @Published var prompt: String = ""
    
    let maxMaterialsCount = 3
    
    // 使用 StableDiffusionManager 来处理 SD 生成
    private let sdManager = StableDiffusionManager()
    
    // 私有初始化，确保只能通过shared访问
    private init() {}
    
    // MARK: - 素材选择（使用BackpackItem）
    func toggleMaterialFromBackpack(_ backpackItem: BackpackItem) {
        print("🔍 点击素材: \(backpackItem.name), BackpackItem ID: \(backpackItem.id)")
        
        // 检查是否已选中此BackpackItem
        if let index = selectedMaterials.firstIndex(where: { $0.backpackItemId == backpackItem.id }) {
            // 已选中 → 取消
            selectedMaterials.remove(at: index)
            print("❌ 取消选择素材: \(backpackItem.name), ID: \(backpackItem.id)")
        } else {
            // 未选中 → 添加
            if selectedMaterials.count < maxMaterialsCount {
                let material = SelectedMaterial(
                    backpackItemId: backpackItem.id,
                    name: backpackItem.name,
                    image: backpackItem.uiImage
                )
                selectedMaterials.append(material)
                print("✅ 选择素材: \(backpackItem.name), BackpackItem ID: \(backpackItem.id), SelectedMaterial ID: \(material.id)")
            } else {
                errorMessage = "最多选择\(maxMaterialsCount)个素材"
            }
        }
        
        // 打印当前所有选中素材
        print("📋 当前选中素材:")
        for (idx, mat) in selectedMaterials.enumerated() {
            print("  [\(idx)] \(mat.name) - BackpackItem ID: \(mat.backpackItemId)")
        }
    }
    
    // 删除选中的素材
    func removeSelectedMaterial(_ material: SelectedMaterial) {
        selectedMaterials.removeAll(where: { $0.id == material.id })
        print("🗑️ 删除选中素材: \(material.name), SelectedMaterial ID: \(material.id)")
    }
    
    // 检查BackpackItem是否被选中
    func isBackpackItemSelected(_ backpackItem: BackpackItem) -> Bool {
        selectedMaterials.contains(where: { $0.backpackItemId == backpackItem.id })
    }
    
    // 兼容旧的InventoryItem接口
    func toggleMaterial(_ item: InventoryItem) {
        if let index = selectedMaterials.firstIndex(where: { $0.backpackItemId == item.id }) {
            selectedMaterials.remove(at: index)
        } else {
            if selectedMaterials.count < maxMaterialsCount {
                let material = SelectedMaterial(
                    backpackItemId: item.id,
                    name: "素材",
                    image: item.image
                )
                selectedMaterials.append(material)
            } else {
                errorMessage = "最多选择\(maxMaterialsCount)个素材"
            }
        }
    }
    
    func isMaterialSelected(_ item: InventoryItem) -> Bool {
        selectedMaterials.contains(where: { $0.backpackItemId == item.id })
    }
    
    func clearSelection() {
        selectedMaterials.removeAll()
    }
    
    // MARK: - 合成功能
    func composeWithStableDiffusion() {
        guard !selectedMaterials.isEmpty else {
            errorMessage = "请先选择素材"
            return
        }
        
        isProcessing = true
        errorMessage = nil
        composedResult = nil
        
        print("🔥🔥🔥 开始合成台 SD 生成")
        print("  - 选中素材数量: \(selectedMaterials.count)")
        print("  - 工艺风格: \(selectedCraftStyle?.rawValue ?? "无")")
        print("  - 自定义提示词: '\(prompt)'")
        
        // 打印所有素材名称（用于调试）
        print("  📋 素材列表:")
        for (index, material) in selectedMaterials.enumerated() {
            print("    [\(index)] '\(material.name)'")
        }
        
        print("\n🔍 开始检测是否有预设组合...")
        
        // 🌟 特殊处理：检查是否是灯泡+星星的组合
        if isLightBulbAndStarCombination() {
            print("  ⭐ 检测到灯泡+星星组合，使用预设精美图片")
            useSpecialCombinationResult(imageSet: ["00003", "00004", "00009", "00010", "WechatIMG14792", "WechatIMG14793", "WechatIMG14794", "WechatIMG14795"])
            return
        }
        
        // 🌸 特殊处理：检查是否是杯子+花的组合
        if isCupAndFlowerCombination() {
            print("  🌸 检测到杯子+花组合，使用预设精美图片")
            useSpecialCombinationResult(imageSet: ["WechatIMG14797", "WechatIMG14798", "WechatIMG14799", "WechatIMG14834", "WechatIMG14835", "WechatIMG14836"])
            return
        }
        
        // 🍋 特殊处理：检查是否是柠檬组合（柠檬+瓶子/树叶）
        if isBottleLemonAndLeafCombination() {
            print("  🍋 检测到柠檬组合，使用预设精美图片")
            useSpecialCombinationResult(imageSet: ["WechatIMG14801", "WechatIMG14802", "WechatIMG14803", "WechatIMG14805"])
            return
        }
        
        // 🛁 特殊处理：检查是否是浴球+花的组合
        if isBathBombAndFlowerCombination() {
            print("  🛁 检测到浴球+花组合，使用预设精美图片")
            useSpecialCombinationResult(imageSet: ["WechatIMG14807", "WechatIMG14808", "WechatIMG14809"])
            return
        }
        
        // 🌺 特殊处理：检查是否是瓶子+花的组合
        if isBottleAndFlowerCombination() {
            print("  🌺 检测到瓶子+花组合，使用预设精美图片")
            useSpecialCombinationResult(imageSet: ["WechatIMG14811", "WechatIMG14812", "WechatIMG14813", "WechatIMG14814"])
            return
        }
        
        // ❄️ 特殊处理：检查是否是雪花+星星的组合
        if isSnowflakeAndStarCombination() {
            print("  ❄️ 检测到雪花+星星组合，使用预设精美图片")
            useSpecialCombinationResult(imageSet: ["WechatIMG14830", "WechatIMG14831", "WechatIMG14832", "WechatIMG14833"])
            return
        }
        
        print("✅✅✅ 没有匹配任何预设组合，进入【真实AI合成】流程")
        print("  🔄 开始合并图片...")
        
        // 合并图片（支持多种尺寸）
        guard let mergedImage = mergeImages() else {
            print("  ❌❌❌ 图片合并失败！")
            errorMessage = "图片合并失败"
            isProcessing = false
            return
        }
        
        print("  ✅ 图片合并成功: \(mergedImage.size.width)x\(mergedImage.size.height)")
        
        // 构建提示词
        let materialNames = selectedMaterials.map { $0.name }
        print("  📝 构建提示词，素材名称: \(materialNames)")
        
        // 使用 StableDiffusionManager 生成
        print("  🚀🚀🚀 准备调用 StableDiffusionManager.generateImage()...")
        // 注意：这里传入单张合并后的图片
        sdManager.generateImage(
            inputImages: [mergedImage],
            materialNames: materialNames, // 传递素材名称
            prompt: self.prompt, // 使用 self.prompt 作为 basePrompt
            styleType: mapCraftStyleToSDStyle(selectedCraftStyle)
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isProcessing = false
                
                switch result {
                case .success(let image):
                    print("✅ 合成台 SD 生成成功")
                    self.composedResult = image
                    self.errorMessage = nil
                    
                case .failure(let error):
                    print("❌ 合成台 SD 生成失败: \(error.localizedDescription)")
                    self.errorMessage = "生成失败: \(error.localizedDescription)"
                    self.composedResult = nil
                }
            }
        }
    }
    
    private func mergeImages() -> UIImage? {
        guard !selectedMaterials.isEmpty else { return nil }
        
        if selectedMaterials.count == 1 {
            return selectedMaterials[0].image
        }
        
        let images = selectedMaterials.compactMap { $0.image }
        let finalSize = CGSize(width: 512, height: 512)
        let drawRect = CGRect(origin: .zero, size: finalSize)
        let opacity: CGFloat = 0.7
        
        print("  🎨 合成方式: 透明度叠加 (\(opacity * 100)%)")
        print("  📐 最终尺寸: \(finalSize.width)x\(finalSize.height)")
        
        UIGraphicsBeginImageContextWithOptions(finalSize, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // 填充白色背景
        context.setFillColor(UIColor.white.cgColor)
        context.fill(drawRect)
        
        // 将每个图像以70%透明度重叠绘制
        for image in images {
            image.draw(in: drawRect, blendMode: .normal, alpha: opacity)
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    // MARK: - 特殊组合检测
    
    /// 检查是否是灯泡和星星的组合（不区分顺序）
    private func isLightBulbAndStarCombination() -> Bool {
        let materialNames = selectedMaterials.map { $0.name.lowercased() }
        
        print("  🔍 检查素材名称:")
        for (idx, name) in materialNames.enumerated() {
            print("    [\(idx)] \(name)")
        }
        
        // 检查是否包含"灯泡"和"星星"（支持各种可能的名称）
        let hasLightBulb = materialNames.contains { name in
            name.contains("灯泡") || name.contains("lightbulb") || name.contains("light bulb") || name.contains("灯")
        }
        
        let hasStar = materialNames.contains { name in
            name.contains("星星") || name.contains("star") || name.contains("星")
        }
        
        print("  🔍 检测结果: 灯泡=\(hasLightBulb), 星星=\(hasStar)")
        
        let result = hasLightBulb && hasStar
        if result {
            print("  ⭐⭐⭐ 检测到灯泡+星星组合！使用预设精美图片")
        } else {
            print("  ℹ️ 未检测到灯泡+星星组合，使用真实AI生成")
            if !hasLightBulb && !hasStar {
                print("  💡 提示：要触发预设图片，请将素材重命名为包含'灯泡'和'星星'的名称")
            }
        }
        
        return result
    }
    
    /// 检查是否是杯子和花的组合
    private func isCupAndFlowerCombination() -> Bool {
        let materialNames = selectedMaterials.map { $0.name.lowercased() }
        
        let hasCup = materialNames.contains { name in
            name.contains("杯子") || name.contains("杯") || name.contains("cup") || name.contains("glass")
        }
        
        let hasFlower = materialNames.contains { name in
            name.contains("花") || name.contains("flower") || name.contains("blossom") || name.contains("bloom")
        }
        
        let result = hasCup && hasFlower
        if result {
            print("  🌸🌸🌸 检测到杯子+花组合！使用预设精美图片")
        }
        
        return result
    }
    
    /// 检查是否是柠檬组合（柠檬+瓶子/树叶）
    private func isBottleLemonAndLeafCombination() -> Bool {
        let materialNames = selectedMaterials.map { $0.name.lowercased() }
        
        let hasBottle = materialNames.contains { name in
            name.contains("瓶子") || name.contains("瓶") || name.contains("bottle")
        }
        
        let hasLemon = materialNames.contains { name in
            name.contains("柠檬") || name.contains("lemon")
        }
        
        let hasLeaf = materialNames.contains { name in
            name.contains("树叶") || name.contains("叶子") || name.contains("叶") || name.contains("leaf") || name.contains("leaves")
        }
        
        // 新逻辑：必须有柠檬，且瓶子或树叶至少有一个
        let result = hasLemon && (hasBottle || hasLeaf)
        if result {
            print("  🍋🍋🍋 检测到柠檬组合（柠檬+瓶子/树叶）！使用预设精美图片")
            print("  📝 检测详情: 柠檬=\(hasLemon), 瓶子=\(hasBottle), 树叶=\(hasLeaf)")
        }
        
        return result
    }
    
    /// 检查是否是浴球和花的组合
    private func isBathBombAndFlowerCombination() -> Bool {
        let materialNames = selectedMaterials.map { $0.name.lowercased() }
        
        let hasBathBomb = materialNames.contains { name in
            name.contains("浴球") || name.contains("bath bomb") || name.contains("bathbomb") || name.contains("泡泡球")
        }
        
        let hasFlower = materialNames.contains { name in
            name.contains("花") || name.contains("flower") || name.contains("blossom") || name.contains("bloom")
        }
        
        let result = hasBathBomb && hasFlower
        if result {
            print("  🛁🛁🛁 检测到浴球+花组合！使用预设精美图片")
        }
        
        return result
    }
    
    /// 检查是否是瓶子和花的组合
    private func isBottleAndFlowerCombination() -> Bool {
        let materialNames = selectedMaterials.map { $0.name.lowercased() }
        
        let hasBottle = materialNames.contains { name in
            name.contains("瓶子") || name.contains("瓶") || name.contains("bottle")
        }
        
        let hasFlower = materialNames.contains { name in
            name.contains("花") || name.contains("flower") || name.contains("blossom") || name.contains("bloom")
        }
        
        let result = hasBottle && hasFlower
        if result {
            print("  🌺🌺🌺 检测到瓶子+花组合！使用预设精美图片")
        }
        
        return result
    }
    
    /// 检查是否是雪花和星星的组合
    private func isSnowflakeAndStarCombination() -> Bool {
        let materialNames = selectedMaterials.map { $0.name.lowercased() }
        
        let hasSnowflake = materialNames.contains { name in
            name.contains("雪花") || name.contains("snowflake") || name.contains("雪")
        }
        
        let hasStar = materialNames.contains { name in
            name.contains("星星") || name.contains("star") || name.contains("星")
        }
        
        let result = hasSnowflake && hasStar
        if result {
            print("  ❄️❄️❄️ 检测到雪花+星星组合！使用预设精美图片")
        }
        
        return result
    }
    
    /// 使用预设的组合结果图片（带真实感延迟）
    private func useSpecialCombinationResult(imageSet: [String]) {
        // 使用随机索引来选择图片，确保真正的均匀随机
        let randomIndex = Int.random(in: 0..<imageSet.count)
        let randomImageName = imageSet[randomIndex]
        
        print("  🎲 随机选择过程:")
        print("    - 可用图片: \(imageSet)")
        print("    - 随机索引: \(randomIndex)")
        print("    - 选中图片: \(randomImageName)")
        
        // 模拟真实的AI生成过程（28-32秒随机延迟）
        let randomDelay = Double.random(in: 28.0...32.0)
        print("  ⏱️ 模拟生成时间: \(String(format: "%.1f", randomDelay))秒")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + randomDelay) { [weak self] in
            guard let self = self else { return }
            
            if let image = UIImage(named: randomImageName) {
                print("  ✅ 加载精美预设图片成功: \(randomImageName)")
                self.composedResult = image
                self.isProcessing = false
                self.errorMessage = nil
            } else {
                print("  ❌ 加载预设图片失败: \(randomImageName)")
                // 如果预设图片加载失败，提示错误
                self.errorMessage = "图片加载失败，请重试"
                self.isProcessing = false
            }
        }
    }
    
    // 将 CraftStyle 映射到 StableDiffusionManager 使用的 StyleType
    private func mapCraftStyleToSDStyle(_ craftStyle: CraftStyle?) -> CraftingRecipe.StyleType {
        guard let craftStyle = craftStyle else {
            return .anime  // 默认动漫风格
        }
        
        switch craftStyle {
        case .realistic:
            return .realistic
        case .cartoon:
            return .anime
        case .watercolor:
            return .watercolor
        case .oilPainting:
            return .oilPainting
        case .sketch:
            return .sketch
        case .cyberpunk:
            return .cyberpunk
        }
    }
    
    func reset() {
        selectedMaterials.removeAll()
        composedResult = nil
        isProcessing = false
        errorMessage = nil
        selectedCraftStyle = nil
        prompt = ""
    }
}

