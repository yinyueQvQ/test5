//
//  AboutView.swift
//  test5
//
//  关于Innoforge页面
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    let appVersion = "1.0.0"
    let buildNumber = "2025.10.29"
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                        // Logo和标语
                        VStack(spacing: 20) {
                            // App Logo
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0, green: 1, blue: 0.6),
                                                Color.purple
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "sparkles")
                                    .font(.system(size: 50, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            
                            VStack(spacing: 8) {
                                Text("Innoforge")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("创意锻造，智绘未来")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                            }
                            
                            // 版本信息
                            VStack(spacing: 4) {
                                Text("版本 \(appVersion)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                
                                Text("Build \(buildNumber)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray.opacity(0.6))
                            }
                        }
                        .padding(.top, 20)
                        
                        // 应用介绍
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.cyan)
                                Text("关于我们")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            Text("""
                            Innoforge 是一款创新的 AI 创意工具，旨在帮助每个人释放创造力。通过先进的人工智能技术，我们让艺术创作变得简单而有趣。
                            
                            无论您是专业设计师还是创意爱好者，Innoforge 都能助您轻松实现创意想法，创作出令人惊艳的视觉作品。
                            """)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(6)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))
                        )
                        
                        // 核心功能
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                Text("核心功能")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 12) {
                                FeatureRow(
                                    icon: "wand.and.stars",
                                    title: "AI图像生成",
                                    description: "基于文字描述生成独特的艺术作品",
                                    color: .purple
                                )
                                
                                FeatureRow(
                                    icon: "paintbrush.pointed.fill",
                                    title: "风格转换",
                                    description: "将照片转换成多种艺术风格",
                                    color: .pink
                                )
                                
                                FeatureRow(
                                    icon: "scissors",
                                    title: "智能抠图",
                                    description: "精准识别并分离图像主体",
                                    color: .cyan
                                )
                                
                                FeatureRow(
                                    icon: "square.stack.3d.up.fill",
                                    title: "创意合成",
                                    description: "多素材组合创作独特作品",
                                    color: .green
                                )
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))
                        )
                        
                        // 团队信息
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "person.3.fill")
                                    .foregroundColor(.orange)
                                Text("开发团队")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            Text("""
                            Innoforge 由一支充满激情的团队打造，我们来自设计、工程和人工智能领域，致力于创造最佳的用户体验。
                            
                            我们相信技术应该服务于创造力，让每个人都能成为艺术家。
                            """)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(6)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))
                        )
                        
                        // 联系方式
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(.blue)
                                Text("联系我们")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 12) {
                                ContactRow(
                                    icon: "envelope.fill",
                                    title: "邮箱",
                                    value: "support@innoforge.com",
                                    color: .red
                                )
                                
                                ContactRow(
                                    icon: "globe",
                                    title: "官网",
                                    value: "www.innoforge.com",
                                    color: .blue
                                )
                                
                                ContactRow(
                                    icon: "bubble.left.fill",
                                    title: "反馈",
                                    value: "设置 > 意见反馈",
                                    color: .green
                                )
                            }
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))
                        )
                        
                        // 法律信息
                        VStack(spacing: 12) {
                            AboutLinkButton(
                                icon: "doc.text.fill",
                                title: "服务条款",
                                color: .purple
                            ) {
                                // 打开服务条款
                            }
                            
                            AboutLinkButton(
                                icon: "lock.shield.fill",
                                title: "隐私政策",
                                color: .orange
                            ) {
                                // 打开隐私政策
                            }
                            
                            AboutLinkButton(
                                icon: "checkmark.seal.fill",
                                title: "开源许可",
                                color: .cyan
                            ) {
                                // 打开开源许可
                            }
                        }
                        
                        // 社交媒体（可选）
                        VStack(spacing: 16) {
                            Text("关注我们")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 24) {
                                SocialButton(icon: "message.fill", color: .green)
                                SocialButton(icon: "camera.fill", color: .pink)
                                SocialButton(icon: "play.rectangle.fill", color: .red)
                                SocialButton(icon: "link", color: .blue)
                            }
                        }
                        .padding(.vertical, 20)
                        
                        // 版权信息
                        VStack(spacing: 8) {
                            Text("© 2025 Innoforge Team")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                            
                            Text("All Rights Reserved")
                                .font(.system(size: 12))
                                .foregroundColor(.gray.opacity(0.6))
                            
                            HStack(spacing: 4) {
                                Text("Made with")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.red)
                                
                                Text("in China")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.top, 10)
                        
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("关于Innoforge")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

// 功能行
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// 联系行
struct ContactRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                
                Text(value)
                    .font(.system(size: 15))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
    }
}

// 关于链接按钮
struct AboutLinkButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 24)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 社交媒体按钮
struct SocialButton: View {
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {
            // 打开社交媒体链接
        }) {
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(color)
                )
        }
    }
}

#Preview {
    AboutView()
}


