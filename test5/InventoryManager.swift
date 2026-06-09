//
//  InventoryManager.swift
//  test5
//
//  Created by AI Assistant on 2025/10/21.
//

import Foundation
import UIKit
import SwiftUI

// 素材工艺类型
enum CraftStyle: String, CaseIterable, Identifiable {
    case realistic = "写实风格"
    case cartoon = "卡通风格"
    case watercolor = "水彩风格"
    case oilPainting = "油画风格"
    case sketch = "素描风格"
    case cyberpunk = "赛博朋克"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .realistic: return "camera.fill"
        case .cartoon: return "face.smiling"
        case .watercolor: return "paintbrush.fill"
        case .oilPainting: return "paintpalette.fill"
        case .sketch: return "pencil"
        case .cyberpunk: return "bolt.fill"
        }
    }
    
    var description: String {
        switch self {
        case .realistic: return "照片级真实感"
        case .cartoon: return "可爱卡通效果"
        case .watercolor: return "水彩画风格"
        case .oilPainting: return "经典油画质感"
        case .sketch: return "手绘素描风格"
        case .cyberpunk: return "未来科幻感"
        }
    }
}

// 背包素材
struct InventoryItem: Identifiable, Codable {
    let id: UUID
    let imageData: Data
    let createdAt: Date
    var selectedCraft: CraftStyle?
    
    init(image: UIImage) {
        self.id = UUID()
        self.imageData = image.pngData() ?? Data()
        self.createdAt = Date()
        self.selectedCraft = nil
    }
    
    var image: UIImage? {
        return UIImage(data: imageData)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, imageData, createdAt, selectedCraft
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        imageData = try container.decode(Data.self, forKey: .imageData)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        if let craftString = try? container.decode(String.self, forKey: .selectedCraft) {
            selectedCraft = CraftStyle(rawValue: craftString)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(imageData, forKey: .imageData)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(selectedCraft?.rawValue, forKey: .selectedCraft)
    }
}

class InventoryManager: ObservableObject {
    @Published var items: [InventoryItem] = []
    
    private let storageKey = "InventoryItems"
    
    init() {
        loadItems()
    }
    
    // MARK: - 添加素材
    
    func addItem(_ image: UIImage) {
        let item = InventoryItem(image: image)
        items.insert(item, at: 0) // 最新的放在最前面
        saveItems()
        print("✅ [DEBUG] 素材已添加到背包，当前数量: \(items.count)")
    }
    
    // MARK: - 删除素材
    
    func removeItem(_ item: InventoryItem) {
        items.removeAll { $0.id == item.id }
        saveItems()
        print("🗑️ [DEBUG] 素材已从背包移除，剩余数量: \(items.count)")
    }
    
    func removeItem(at index: Int) {
        guard index >= 0 && index < items.count else { return }
        items.remove(at: index)
        saveItems()
    }
    
    // MARK: - 清空背包
    
    func clearAll() {
        items.removeAll()
        saveItems()
        print("🗑️ [DEBUG] 背包已清空")
    }
    
    // MARK: - 持久化
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([InventoryItem].self, from: data) {
            items = decoded
            print("✅ [DEBUG] 从本地加载了 \(items.count) 个素材")
        }
    }
}

