//
//  SettingsView.swift
//  test5
//
//  设置页
//

import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var showingFeedback = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 顶部标题
                        HStack {
                            Text("设置")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 60)
                        
                        // 下划线
                        Rectangle()
                            .fill(Color.green)
                            .frame(height: 2)
                            .padding(.horizontal, 24)
                        
                        // 消息通知开关
                        HStack(spacing: 16) {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.green)
                                .frame(width: 28)
                            
                            Text("消息通知")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Toggle("", isOn: $notificationsEnabled)
                                .tint(.green)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                        )
                        .padding(.horizontal, 24)
                        
                        // 隐私和安全
                        VStack(spacing: 0) {
                            NavigationLink(destination: PrivacyPermissionsView()) {
                                SettingsMenuItemContent(
                                    icon: "checkmark.shield.fill",
                                    title: "隐私权限",
                                    iconColor: .green
                                )
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.leading, 60)
                            
                            NavigationLink(destination: AccountSecurityView()) {
                                SettingsMenuItemContent(
                                    icon: "lock.fill",
                                    title: "数据与账户安全",
                                    iconColor: .green
                                )
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                        )
                        .padding(.horizontal, 24)
                        
                        // 帮助与支持
                        VStack(spacing: 0) {
                            NavigationLink(destination: HelpCenterView()) {
                                SettingsMenuItemContent(
                                    icon: "questionmark.circle.fill",
                                    title: "帮助中心",
                                    iconColor: .purple
                                )
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.leading, 60)
                            
                            NavigationLink(destination: TermsOfServiceView()) {
                                SettingsMenuItemContent(
                                    icon: "doc.text.fill",
                                    title: "服务条款",
                                    iconColor: .purple
                                )
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.leading, 60)
                            
                            NavigationLink(destination: PrivacyPolicyView()) {
                                SettingsMenuItemContent(
                                    icon: "doc.text.fill",
                                    title: "隐私政策",
                                    iconColor: .purple
                                )
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.leading, 60)
                            
                            SettingsMenuItem(
                                icon: "bubble.left.fill",
                                title: "意见反馈",
                                iconColor: .purple
                            ) {
                                showingFeedback = true
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.leading, 60)
                            
                            NavigationLink(destination: AboutView()) {
                                SettingsMenuItemContent(
                                    icon: "info.circle.fill",
                                    title: "关于Innoforge",
                                    iconColor: .purple
                                )
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                        )
                        .padding(.horizontal, 24)
                        
                        Spacer(minLength: 100)
                    }
                }
                .navigationBarHidden(true)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .fullScreenCover(isPresented: $showingFeedback) {
                FeedbackView()
            }
        }
    }
    
    // 设置菜单项（点击按钮版）
    struct SettingsMenuItem: View {
        let icon: String
        let title: String
        let iconColor: Color
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                HStack(spacing: 16) {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(iconColor)
                        .frame(width: 28)
                    
                    Text(title)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                    
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
    
    // 设置菜单项内容（NavigationLink版）
    struct SettingsMenuItemContent: View {
        let icon: String
        let title: String
        let iconColor: Color
        
        var body: some View {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(iconColor)
                    .frame(width: 28)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }
}
#Preview {
    SettingsView()
}

