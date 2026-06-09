import Foundation
import UIKit

// MARK: - 作品模型
struct Work: Identifiable, Codable {
    let id: UUID
    var title: String
    var image: Data  // 存储为 Data 以便持久化
    var createdAt: Date
    var isPublished: Bool  // true = 已发布, false = 草稿
    var usedMaterials: [String]  // 使用的素材名称列表
    
    init(id: UUID = UUID(), title: String, image: UIImage, isPublished: Bool = false, usedMaterials: [String] = []) {
        self.id = id
        self.title = title
        self.image = image.jpegData(compressionQuality: 0.8) ?? Data()
        self.createdAt = Date()
        self.isPublished = isPublished
        self.usedMaterials = usedMaterials
    }
    
    // 获取 UIImage
    var uiImage: UIImage? {
        return UIImage(data: image)
    }
}

// MARK: - 作品管理器
class WorksManager: ObservableObject {
    static let shared = WorksManager()
    
    @Published var works: [Work] = []
    
    private let worksKey = "SavedWorks"
    private let presetWorksInitializedKey = "PresetWorksInitialized"
    
    init() {
        loadWorks()
        initializePresetWorksIfNeeded()
    }
    
    // MARK: - 预置作品初始化
    
    /// 首次启动时添加预置精美作品
    private func initializePresetWorksIfNeeded() {
        // 检查是否已经初始化过预置作品
        let isInitialized = UserDefaults.standard.bool(forKey: presetWorksInitializedKey)
        
        if !isInitialized {
            print("🎨 首次启动，初始化预置精美作品...")
            
            // 预置作品数据（新图片名称 + 备用图片名称）
            let presetWorks: [(imageName: String, fallbackImage: String, title: String, materials: [String])] = [
                ("WechatIMG14731", "WechatIMG14731", "星光灯泡 - 木质星形灯", ["灯泡", "星星"]),
                ("WechatIMG14732", "WechatIMG14732", "月光瓶 - 梦幻发光瓶", ["灯泡", "月亮"]),
                ("WechatIMG14733", "WechatIMG14733", "雪花灯泡 - 冰晶灯", ["灯泡", "雪花"]),
                ("WechatIMG14734", "WechatIMG14734", "生命之树灯瓶", ["灯泡", "树木"])
            ]
            
            // 添加预置作品（支持备用图片）
            for preset in presetWorks {
                // 尝试加载新图片，如果失败则使用备用图片
                var image = UIImage(named: preset.imageName)
                var imageSource = "新图片"
                
                if image == nil {
                    print("  ℹ️ 新图片 \(preset.imageName) 未找到，使用备用图片 \(preset.fallbackImage)")
                    image = UIImage(named: preset.fallbackImage)
                    imageSource = "备用图片"
                }
                
                if let finalImage = image {
                    let work = Work(
                        title: preset.title,
                        image: finalImage,
                        isPublished: true,  // 默认已发布
                        usedMaterials: preset.materials
                    )
                    works.append(work)
                    print("  ✅ 添加预置作品: \(preset.title) (使用\(imageSource))")
                } else {
                    print("  ❌ 无法加载图片: \(preset.imageName) 和备用图片 \(preset.fallbackImage)")
                }
            }
            
            // 保存并标记已初始化
            persistWorks()
            UserDefaults.standard.set(true, forKey: presetWorksInitializedKey)
            print("✨ 预置作品初始化完成！共添加 \(presetWorks.count) 个作品")
        }
    }
    
    // MARK: - 计算属性
    
    /// 草稿列表
    var drafts: [Work] {
        works.filter { !$0.isPublished }.sorted { $0.createdAt > $1.createdAt }
    }
    
    /// 已发布列表
    var published: [Work] {
        works.filter { $0.isPublished }.sorted { $0.createdAt > $1.createdAt }
    }
    
    /// 总作品数
    var totalCount: Int {
        works.count
    }
    
    /// 草稿数
    var draftCount: Int {
        drafts.count
    }
    
    /// 已发布数
    var publishedCount: Int {
        published.count
    }
    
    // MARK: - 作品操作
    
    /// 保存新作品（默认为草稿）
    func saveWork(title: String, image: UIImage, usedMaterials: [String] = []) {
        let work = Work(title: title, image: image, isPublished: false, usedMaterials: usedMaterials)
        works.append(work)
        persistWorks()
    }
    
    /// 发布作品
    func publishWork(_ work: Work) {
        if let index = works.firstIndex(where: { $0.id == work.id }) {
            works[index].isPublished = true
            persistWorks()
        }
    }
    
    /// 取消发布（变回草稿）
    func unpublishWork(_ work: Work) {
        if let index = works.firstIndex(where: { $0.id == work.id }) {
            works[index].isPublished = false
            persistWorks()
        }
    }
    
    /// 删除作品
    func deleteWork(_ work: Work) {
        works.removeAll { $0.id == work.id }
        persistWorks()
    }
    
    /// 重命名作品
    func renameWork(_ work: Work, newTitle: String) {
        if let index = works.firstIndex(where: { $0.id == work.id }) {
            works[index].title = newTitle
            persistWorks()
        }
    }
    
    /// 强制重新初始化预置作品（用于测试或重置）
    func reinitializePresetWorks() {
        print("🔄 强制重新初始化预置作品...")
        
        // 删除所有现有预置作品（通过标题识别）
        let presetTitles = ["星光灯泡 - 木质星形灯", "月光瓶 - 梦幻发光瓶", "雪花灯泡 - 冰晶灯", "生命之树灯瓶"]
        works.removeAll { work in
            presetTitles.contains { work.title.contains($0) }
        }
        
        // 重置初始化标志
        UserDefaults.standard.set(false, forKey: presetWorksInitializedKey)
        
        // 重新初始化
        initializePresetWorksIfNeeded()
        
        print("✅ 预置作品重新初始化完成")
    }
    
    // MARK: - 持久化
    
    private func persistWorks() {
        if let encoded = try? JSONEncoder().encode(works) {
            UserDefaults.standard.set(encoded, forKey: worksKey)
        }
    }
    
    private func loadWorks() {
        if let data = UserDefaults.standard.data(forKey: worksKey),
           let decoded = try? JSONDecoder().decode([Work].self, from: data) {
            works = decoded
        }
    }
}

