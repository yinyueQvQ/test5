import Foundation
import UIKit

// MARK: - 背包素材模型

struct BackpackItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var image: Data  // 存储为 Data 以便持久化
    var createdAt: Date
    
    init(id: UUID = UUID(), name: String, image: UIImage) {
        self.id = id
        self.name = name
        
        // 尝试多种方式保存图像数据
        if let imageData = image.jpegData(compressionQuality: 0.9) {
            self.image = imageData
        } else if let pngData = image.pngData() {
            self.image = pngData
        } else {
            // 最后的降级方案：创建一个简单的纯色图
            self.image = Data()
        }
        
        self.createdAt = Date()
    }
    
    // 获取 UIImage
    var uiImage: UIImage? {
        if image.isEmpty {
            return nil
        }
        return UIImage(data: image)
    }
}

// MARK: - 背包管理器

class BackpackManager: ObservableObject {
    static let shared = BackpackManager()
    
    @Published var items: [BackpackItem] = []
    
    private let itemsKey = "BackpackItems"
    
    init() {
        loadItems()
    }
    
    /// 添加素材
    func addItem(name: String, image: UIImage) {
        let item = BackpackItem(name: name, image: image)
        items.append(item)
        persistItems()
        print("📦 添加素材到背包: \(name), ID: \(item.id)")
    }
    
    /// 删除素材
    func deleteItem(_ item: BackpackItem) {
        items.removeAll { $0.id == item.id }
        persistItems()
    }
    
    /// 重命名素材
    func renameItem(_ item: BackpackItem, newName: String) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].name = newName
            persistItems()
        }
    }
    
    /// 清空背包
    func clearAll() {
        items.removeAll()
        persistItems()
    }
    
    // MARK: - 持久化
    
    private func persistItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: itemsKey)
        }
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: itemsKey),
           let decoded = try? JSONDecoder().decode([BackpackItem].self, from: data) {
            items = decoded
            print("📦 从本地加载背包素材:")
            for (idx, item) in items.enumerated() {
                print("  [\(idx)] \(item.name) - ID: \(item.id)")
            }
        }
    }
}

// MARK: - 合成配方和风格类型

struct CraftingRecipe {
    let id: String
    let name: String
    let style: StyleType
    let requiredMaterials: Int
    let description: String
    
    // SD 风格类型
    enum StyleType: String, CaseIterable, Identifiable {
        case anime = "动漫风格"
        case realistic = "写实风格"
        case watercolor = "水彩风格"
        case oilPainting = "油画风格"
        case sketch = "素描风格"
        case cyberpunk = "赛博朋克"
        
        var id: String { rawValue }
        
        // Stable Diffusion 提示词后缀
        var sdPromptSuffix: String {
            switch self {
            case .anime:
                return "anime style"
            case .realistic:
                return "realistic"
            case .watercolor:
                return "watercolor"
            case .oilPainting:
                return "oil painting"
            case .sketch:
                return "sketch"
            case .cyberpunk:
                return "cyberpunk"
            }
        }
        
        var icon: String {
            switch self {
            case .anime: return "sparkles"
            case .realistic: return "camera.fill"
            case .watercolor: return "paintbrush.fill"
            case .oilPainting: return "paintpalette.fill"
            case .sketch: return "pencil"
            case .cyberpunk: return "bolt.fill"
            }
        }
        
        var description: String {
            switch self {
            case .anime: return "日系动漫风格，柔和色彩"
            case .realistic: return "照片级真实感"
            case .watercolor: return "水彩画风格，艺术感"
            case .oilPainting: return "经典油画质感"
            case .sketch: return "手绘素描风格"
            case .cyberpunk: return "未来科幻感，霓虹灯效果"
            }
        }
    }
}

// MARK: - 预定义配方

extension CraftingRecipe {
    static let allRecipes: [CraftingRecipe] = [
        CraftingRecipe(
            id: "anime_fusion",
            name: "动漫融合",
            style: .anime,
            requiredMaterials: 2,
            description: "将素材融合成可爱的动漫风格作品"
        ),
        CraftingRecipe(
            id: "realistic_blend",
            name: "真实混合",
            style: .realistic,
            requiredMaterials: 2,
            description: "创造逼真的照片级合成效果"
        ),
        CraftingRecipe(
            id: "watercolor_art",
            name: "水彩艺术",
            style: .watercolor,
            requiredMaterials: 2,
            description: "生成柔和的水彩画风格"
        ),
        CraftingRecipe(
            id: "oil_painting",
            name: "油画创作",
            style: .oilPainting,
            requiredMaterials: 2,
            description: "经典油画质感的艺术作品"
        ),
        CraftingRecipe(
            id: "sketch_art",
            name: "素描艺术",
            style: .sketch,
            requiredMaterials: 2,
            description: "手绘素描风格的创作"
        ),
        CraftingRecipe(
            id: "cyberpunk_fusion",
            name: "赛博融合",
            style: .cyberpunk,
            requiredMaterials: 2,
            description: "未来科幻风格的创意合成"
        )
    ]
}

