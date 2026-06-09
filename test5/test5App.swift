//
//  test5App.swift
//  test5
//
//  Created by zhuojin li on 2025/10/15.
//

import SwiftUI

@main
struct test5App: App {
    
    init() {
        // 🔄 强制重新初始化预置作品（调试用，正式版可删除）
        WorksManager.shared.reinitializePresetWorks()
    }
    
    var body: some Scene {
        WindowGroup {
            // 使用 AppCoordinator 管理启动流程
            // 顺序：加载动画 → 引导页 → 主应用
            AppCoordinator()
        }
    }
}

// MARK: - 调试用：重置引导页
// 如果想重新看引导页，在 Xcode Console 执行：
// AppCoordinator.resetOnboarding()
