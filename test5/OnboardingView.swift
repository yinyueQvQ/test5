//
//  OnboardingView.swift
//  test5
//
//  引导页（3页：智能提取 → 无限组合 → AIGC赋能）
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isCompleted: Bool
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            // 背景色
            Color.black
                .ignoresSafeArea()
            
            VStack {
                // 跳过按钮
                HStack {
                    Spacer()
                    Button(action: {
                        skipOnboarding()
                    }) {
                        Text("跳过")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                    }
                }
                .padding(.top, 20)
                
                // 页面内容
                TabView(selection: $currentPage) {
                    // 第1页：智能提取
                    OnboardingPage(
                        imageName: "cube.transparent", // 替换为您的图片
                        title: "智能提取",
                        subtitle: "释放创意潜能",
                        description: "从任意图片中精准分离元素，一键获取创作素材。AI智能识别，让灵感不再受限于素材束缚。",
                        accentColor: .green
                    )
                    .tag(0)
                    
                    // 第2页：无限组合
                    OnboardingPage(
                        imageName: "square.on.square", // 替换为您的图片
                        title: "无限组合",
                        subtitle: "构建奇幻世界",
                        description: "自由拖拽、缩放、旋转你的素材，层层叠加创造独特视觉。多维度编辑，让想象力无界限延伸。",
                        accentColor: .cyan
                    )
                    .tag(1)
                    
                    // 第3页：AIGC赋能
                    OnboardingPage(
                        imageName: "wand.and.stars", // 替换为您的图片
                        title: "AIGC赋能",
                        subtitle: "一念生成万象",
                        description: "输入你的想象，让人工智能为你生成震撼的艺术作品。前沿技术驱动，探索创作的无限可能。",
                        accentColor: .purple
                    )
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                // 页面指示器
                HStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        Capsule()
                            .fill(currentPage == index ? getPageColor() : Color.gray.opacity(0.3))
                            .frame(width: currentPage == index ? 24 : 8, height: 8)
                            .animation(.spring(), value: currentPage)
                    }
                }
                .padding(.bottom, 20)
                
                // 底部按钮
                if currentPage < 2 {
                    // 下一步按钮
                    Button(action: {
                        withAnimation {
                            currentPage += 1
                        }
                    }) {
                        Text("下一步")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(getPageColor())
                            .cornerRadius(28)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                } else {
                    // 开始体验按钮
                    Button(action: {
                        completeOnboarding()
                    }) {
                        Text("开始体验")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.purple, Color.purple.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(28)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                }
            }
        }
    }
    
    private func getPageColor() -> Color {
        switch currentPage {
        case 0: return .green
        case 1: return .cyan
        case 2: return .purple
        default: return .mint
        }
    }
    
    private func skipOnboarding() {
        withAnimation {
            isCompleted = true
        }
        saveOnboardingStatus()
    }
    
    private func completeOnboarding() {
        withAnimation {
            isCompleted = true
        }
        saveOnboardingStatus()
    }
    
    private func saveOnboardingStatus() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
    }
}

// 单个引导页组件
struct OnboardingPage: View {
    let imageName: String
    let title: String
    let subtitle: String
    let description: String
    let accentColor: Color
    
    @State private var imageScale: CGFloat = 0.8
    @State private var imageOpacity: Double = 0
    @State private var textOffset: CGFloat = 50
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // 图片/图标区域 - 您替换为实际的图片素材
            ZStack {
                // 背景光晕效果
                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [accentColor.opacity(0.3), Color.clear]),
                            center: .center,
                            startRadius: 50,
                            endRadius: 150
                        )
                    )
                    .frame(width: 300, height: 300)
                
                // 内容卡片
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 280, height: 280)
                    .overlay(
                        Image(systemName: imageName) // 临时占位图标，替换为您的实际图片
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180, height: 180)
                            .foregroundColor(accentColor)
                    )
            }
            .scaleEffect(imageScale)
            .opacity(imageOpacity)
            
            Spacer()
            
            // 文字内容
            VStack(spacing: 16) {
                Text(title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(accentColor)
                
                Text(subtitle)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(accentColor.opacity(0.8))
                
                Text(description)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 40)
                    .padding(.top, 10)
            }
            .offset(y: textOffset)
            .opacity(imageOpacity)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                imageScale = 1.0
                imageOpacity = 1.0
                textOffset = 0
            }
        }
    }
}

#Preview {
    OnboardingView(isCompleted: .constant(false))
}

