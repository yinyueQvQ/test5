//
//  DraftManager.swift
//  test5
//
//  管理草稿和已发布作品
//

import SwiftUI
import UIKit

// 作品数据模型
struct Artwork: Identifiable, Codable {
    let id: String
    let title: String
    let imageData: Data
    let createdDate: Date
    var isPublished: Bool
    var publishedDate: Date?
    var description: String?
    var tags: [String]
    
    init(id: String = UUID().uuidString,
         title: String,
         image: UIImage,
         isPublished: Bool = false,
         description: String? = nil,
         tags: [String] = []) {
        self.id = id
        self.title = title
        self.imageData = image.jpegData(compressionQuality: 0.8) ?? Data()
        self.createdDate = Date()
        self.isPublished = isPublished
        self.publishedDate = isPublished ? Date() : nil
        self.description = description
        self.tags = tags
    }
    
    var image: UIImage? {
        UIImage(data: imageData)
    }
}

// 草稿和作品管理器
class DraftManager: ObservableObject {
    @Published var artworks: [Artwork] = []
    
    private let userDefaultsKey = "SavedArtworks"
    
    init() {
        loadArtworks()
    }
    
    // MARK: - 草稿管理
    
    /// 保存作品到草稿
    func saveDraft(title: String, image: UIImage, description: String? = nil, tags: [String] = []) {
        let artwork = Artwork(
            title: title,
            image: image,
            isPublished: false,
            description: description,
            tags: tags
        )
        artworks.insert(artwork, at: 0)
        saveArtworks()
    }
    
    /// 获取所有草稿
    var drafts: [Artwork] {
        artworks.filter { !$0.isPublished }
            .sorted { $0.createdDate > $1.createdDate }
    }
    
    /// 获取已发布作品
    var publishedWorks: [Artwork] {
        artworks.filter { $0.isPublished }
            .sorted { ($0.publishedDate ?? $0.createdDate) > ($1.publishedDate ?? $1.createdDate) }
    }
    
    // MARK: - 发布管理
    
    /// 发布草稿
    func publishDraft(id: String) {
        if let index = artworks.firstIndex(where: { $0.id == id }) {
            artworks[index].isPublished = true
            artworks[index].publishedDate = Date()
            saveArtworks()
        }
    }
    
    /// 取消发布
    func unpublish(id: String) {
        if let index = artworks.firstIndex(where: { $0.id == id }) {
            artworks[index].isPublished = false
            artworks[index].publishedDate = nil
            saveArtworks()
        }
    }
    
    // MARK: - 删除
    
    /// 删除作品
    func deleteArtwork(id: String) {
        artworks.removeAll { $0.id == id }
        saveArtworks()
    }
    
    /// 删除多个作品
    func deleteArtworks(ids: [String]) {
        artworks.removeAll { ids.contains($0.id) }
        saveArtworks()
    }
    
    // MARK: - 编辑
    
    /// 更新作品信息
    func updateArtwork(id: String, title: String? = nil, description: String? = nil, tags: [String]? = nil) {
        if let index = artworks.firstIndex(where: { $0.id == id }) {
            var updatedArtwork = artworks[index]
            if let title = title {
                updatedArtwork = Artwork(
                    id: updatedArtwork.id,
                    title: title,
                    image: updatedArtwork.image ?? UIImage(),
                    isPublished: updatedArtwork.isPublished,
                    description: description ?? updatedArtwork.description,
                    tags: tags ?? updatedArtwork.tags
                )
            }
            artworks[index] = updatedArtwork
            saveArtworks()
        }
    }
    
    // MARK: - 持久化
    
    private func saveArtworks() {
        if let encoded = try? JSONEncoder().encode(artworks) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadArtworks() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([Artwork].self, from: data) {
            artworks = decoded
        }
    }
    
    // MARK: - 统计
    
    var totalDrafts: Int {
        drafts.count
    }
    
    var totalPublished: Int {
        publishedWorks.count
    }
    
    var totalArtworks: Int {
        artworks.count
    }
}

