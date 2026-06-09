//
//  ProfileManager.swift
//  test5
//
//  用户资料管理
//

import Foundation
import UIKit
import SwiftUI

class ProfileManager: ObservableObject {
    @Published var username: String {
        didSet {
            saveProfile()
        }
    }
    
    @Published var signature: String {
        didSet {
            saveProfile()
        }
    }
    
    @Published var avatarImage: UIImage? {
        didSet {
            saveAvatar()
        }
    }
    
    private let usernameKey = "UserProfile_Username"
    private let signatureKey = "UserProfile_Signature"
    private let avatarKey = "UserProfile_Avatar"
    
    init() {
        // 从UserDefaults加载数据
        self.username = UserDefaults.standard.string(forKey: usernameKey) ?? "创意设计师"
        self.signature = UserDefaults.standard.string(forKey: signatureKey) ?? "热爱创作，享受生活"
        
        // 加载头像
        if let avatarData = UserDefaults.standard.data(forKey: avatarKey),
           let image = UIImage(data: avatarData) {
            self.avatarImage = image
        }
    }
    
    // MARK: - 更新方法
    
    func updateUsername(_ newName: String) {
        username = newName
    }
    
    func updateSignature(_ newSignature: String) {
        signature = newSignature
    }
    
    func updateAvatar(_ image: UIImage) {
        avatarImage = image
    }
    
    // MARK: - 保存方法
    
    private func saveProfile() {
        UserDefaults.standard.set(username, forKey: usernameKey)
        UserDefaults.standard.set(signature, forKey: signatureKey)
    }
    
    private func saveAvatar() {
        if let image = avatarImage,
           let data = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(data, forKey: avatarKey)
        } else {
            UserDefaults.standard.removeObject(forKey: avatarKey)
        }
    }
    
    // MARK: - 辅助方法
    
    func getInitials() -> String {
        let words = username.split(separator: " ")
        if words.count >= 2 {
            let first = String(words[0].prefix(1))
            let second = String(words[1].prefix(1))
            return (first + second).uppercased()
        } else if let first = username.first {
            return String(first).uppercased()
        }
        return "U"
    }
}

