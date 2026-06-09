//
//  MaterialView.swift
//  test5
//
//  资料页 - 用户个人信息和统计
//

import SwiftUI

struct MaterialView: View {
    @EnvironmentObject var draftManager: DraftManager
    @StateObject private var worksManager = WorksManager.shared
    @State private var showingEditProfile = false
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingImageSourcePicker = false
    @StateObject private var permissionManager = PermissionManager()
    @StateObject private var profileManager = ProfileManager()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 顶部标题
                        Text("我的资料")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 60)
                        
                        // 用户信息卡片
                        ZStack(alignment: .topTrailing) {
                            // 卡片背景渐变
                            RoundedRectangle(cornerRadius: 24)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color.green.opacity(0.3),
                                            Color.green.opacity(0.1)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: 200)
                            
                            VStack(spacing: 16) {
                                // 头像和编辑按钮
                                ZStack(alignment: .bottomTrailing) {
                                    if let avatarImage = profileManager.avatarImage {
                                        Image(uiImage: avatarImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 80, height: 80)
                                            .clipShape(Circle())
                                    } else {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [.green, .mint]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 80, height: 80)
                                            .overlay(
                                                Text(profileManager.getInitials())
                                                    .font(.system(size: 32, weight: .bold))
                                                    .foregroundColor(.black)
                                            )
                                    }
                                    
                                    // 编辑头像按钮
                                    Button(action: {
                                        showingImageSourcePicker = true
                                    }) {
                                        Circle()
                                            .fill(Color.green)
                                            .frame(width: 28, height: 28)
                                            .overlay(
                                                Image(systemName: "camera.fill")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.black)
                                            )
                                    }
                                }
                                
                                // 用户名和签名
                                VStack(spacing: 4) {
                                    Text(profileManager.username)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text(profileManager.signature)
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 30)
                        }
                        .padding(.horizontal, 24)
                        
                        // 账号设置标题
                        HStack {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.green)
                            
                            Text("账号设置")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                        
                        // 设置选项
                        VStack(spacing: 0) {
                            SettingRow(
                                icon: "person.circle.fill",
                                title: "编辑资料",
                                iconColor: .purple
                            ) {
                                showingEditProfile = true
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.leading, 60)
                            
                            NavigationLink(destination: AccountSecurityView()) {
                                SettingRowContent(
                                    icon: "checkmark.shield.fill",
                                    title: "账号安全",
                                    iconColor: .cyan
                                )
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.leading, 60)
                            
                            NavigationLink(destination: PrivacySettingsView()) {
                                SettingRowContent(
                                    icon: "eye.slash.fill",
                                    title: "隐私设置",
                                    iconColor: .orange
                                )
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                        )
                        .padding(.horizontal, 24)
                        
                        // 创作统计标题
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(.green)
                            
                            Text("创作统计")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                        
                        // 统计卡片（使用 WorksManager）
                        HStack(spacing: 12) {
                            StatsCard(
                                icon: "photo.fill",
                                count: "\(worksManager.publishedCount)",
                                label: "已发布",
                                color: .green
                            )
                            
                            StatsCard(
                                icon: "doc.fill",
                                count: "\(worksManager.draftCount)",
                                label: "草稿",
                                color: .orange
                            )
                            
                            StatsCard(
                                icon: "square.stack.fill",
                                count: "\(worksManager.totalCount)",
                                label: "总作品",
                                color: .cyan
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        // 我的收藏标题
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.pink)
                            
                            Text("我的收藏")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 10)
                        
                        // 收藏入口
                        NavigationLink(destination: FavoritesView()) {
                            HStack(spacing: 16) {
                                Image(systemName: "heart.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.pink)
                                    .frame(width: 28)
                                
                                Text("查看我的收藏")
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
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(profileManager: profileManager)
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePickerView(selectedImage: Binding(
                    get: { profileManager.avatarImage },
                    set: { image in
                        if let img = image {
                            profileManager.updateAvatar(img)
                        }
                    }
                ), sourceType: .photoLibrary)
            }
            .sheet(isPresented: $showingCamera) {
                ImagePickerView(selectedImage: Binding(
                    get: { profileManager.avatarImage },
                    set: { image in
                        if let img = image {
                            profileManager.updateAvatar(img)
                        }
                    }
                ), sourceType: .camera)
            }
            .confirmationDialog("选择头像来源", isPresented: $showingImageSourcePicker) {
                Button("相册选择") {
                    Task {
                        let hasPermission = await permissionManager.requestPhotoLibraryPermission()
                        if hasPermission {
                            showingImagePicker = true
                        }
                    }
                }
                Button("拍摄照片") {
                    Task {
                        let hasPermission = await permissionManager.requestCameraPermission()
                        if hasPermission {
                            showingCamera = true
                        }
                    }
                }
                Button("取消", role: .cancel) {}
            }
        }
    }
    
    // 设置行组件（按钮版）
    struct SettingRow: View {
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
    
    // 设置行内容（NavigationLink版）
    struct SettingRowContent: View {
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
    
    // 统计卡片
    struct StatsCard: View {
        let icon: String
        let count: String
        let label: String
        let color: Color
        
        var body: some View {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(color)
                
                Text(count)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(color)
                
                Text(label)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
            )
        }
    }
}

#Preview {
    MaterialView()
}

