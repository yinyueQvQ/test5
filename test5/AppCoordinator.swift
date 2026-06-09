//
//  AppCoordinator.swift
//  test5
//
//  管理应用启动流程：加载动画 → 引导页 → 主应用
//

import SwiftUI

struct AppCoordinator: View {
    @State private var launchFinished = false
    @State private var onboardingCompleted = false
    @State private var showMainApp = false
    
    var body: some View {
        ZStack {
            if !launchFinished {
                // 阶段1：加载动画
                LaunchView(isFinished: $launchFinished)
                    .transition(.opacity)
            } else if !onboardingCompleted {
                // 阶段2：引导页（每次启动都显示）
                OnboardingView(isCompleted: $onboardingCompleted)
                    .transition(.opacity)
            } else {
                // 阶段3：主应用（使用新的Tab导航系统）
                MainTabView()
                    .transition(.opacity)
                    .onAppear {
                        showMainApp = true
                    }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: launchFinished)
        .animation(.easeInOut(duration: 0.3), value: onboardingCompleted)
    }
    
    // 检查是否已完成引导页
    private func hasCompletedOnboarding() -> Bool {
        return UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    }
}

// 用于测试和重置引导页状态的辅助方法
extension AppCoordinator {
    static func resetOnboarding() {
        UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
    }
}

#Preview {
    AppCoordinator()
}

