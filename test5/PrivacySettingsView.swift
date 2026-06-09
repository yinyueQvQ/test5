//
//  PrivacySettingsView.swift
//  test5
//
//  隐私设置页面
//

import SwiftUI

struct PrivacySettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var profileVisible = true
    @State private var worksVisible = true
    @State private var allowComments = true
    @State private var allowMessages = true
    @State private var showOnlineStatus = false
    @State private var dataCollection = true
    @State private var personalized = true
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // 隐私说明卡片
                    HStack(spacing: 12) {
                        Image(systemName: "shield.lefthalf.filled")
                            .font(.system(size: 30))
                            .foregroundColor(.purple)
                        
                        Text("我们重视您的隐私，您可以自主控制个人信息的展示和数据收集")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.05))
                    )
                    .padding(.horizontal, 24)
                    
                    // 内容隐私
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "eye.fill")
                                .foregroundColor(.cyan)
                            Text("内容隐私")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 0) {
                            PrivacyToggleRow(
                                icon: "person.fill",
                                title: "个人资料可见",
                                subtitle: "其他用户可以查看您的个人资料",
                                iconColor: .purple,
                                isOn: $profileVisible
                            )
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.leading, 60)
                            
                            PrivacyToggleRow(
                                icon: "photo.fill",
                                title: "作品公开可见",
                                subtitle: "其他用户可以查看您的作品",
                                iconColor: .orange,
                                isOn: $worksVisible
                            )
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.leading, 60)
                            
                            PrivacyToggleRow(
                                icon: "bubble.left.fill",
                                title: "允许评论",
                                subtitle: "其他用户可以评论您的作品",
                                iconColor: .green,
                                isOn: $allowComments
                            )
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // 互动隐私
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(.green)
                            Text("互动隐私")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 0) {
                            PrivacyToggleRow(
                                icon: "envelope.fill",
                                title: "允许私信",
                                subtitle: "其他用户可以给您发送私信",
                                iconColor: .blue,
                                isOn: $allowMessages
                            )
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.leading, 60)
                            
                            PrivacyToggleRow(
                                icon: "circle.fill",
                                title: "显示在线状态",
                                subtitle: "让好友知道您在线",
                                iconColor: .mint,
                                isOn: $showOnlineStatus
                            )
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // 数据隐私
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.orange)
                            Text("数据隐私")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 0) {
                            PrivacyToggleRow(
                                icon: "chart.xyaxis.line",
                                title: "数据收集",
                                subtitle: "允许收集匿名使用数据以改进服务",
                                iconColor: .purple,
                                isOn: $dataCollection
                            )
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.leading, 60)
                            
                            PrivacyToggleRow(
                                icon: "sparkles",
                                title: "个性化推荐",
                                subtitle: "根据您的喜好推荐内容",
                                iconColor: .pink,
                                isOn: $personalized
                            )
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // 数据管理
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "folder.fill")
                                .foregroundColor(.yellow)
                            Text("数据管理")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 0) {
                            PrivacyActionRow(
                                icon: "square.and.arrow.down.fill",
                                title: "下载我的数据",
                                subtitle: "下载您的所有个人数据",
                                iconColor: .cyan
                            ) {
                                // 下载数据
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.leading, 60)
                            
                            PrivacyActionRow(
                                icon: "trash.fill",
                                title: "清除缓存数据",
                                subtitle: "释放存储空间",
                                iconColor: .orange
                            ) {
                                // 清除缓存
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("隐私设置")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

// 隐私开关行
struct PrivacyToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(iconColor)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(Color(red: 0, green: 1, blue: 0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}

// 隐私操作行
struct PrivacyActionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(iconColor)
                    .frame(width: 28)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PrivacySettingsView()
}

