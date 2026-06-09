//
//  EditProfileView.swift
//  test5
//
//  编辑资料界面
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var profileManager: ProfileManager
    
    @State private var tempUsername: String
    @State private var tempSignature: String
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingImageSourcePicker = false
    @StateObject private var permissionManager = PermissionManager()
    
    init(profileManager: ProfileManager) {
        self.profileManager = profileManager
        _tempUsername = State(initialValue: profileManager.username)
        _tempSignature = State(initialValue: profileManager.signature)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 头像预览
                        VStack(spacing: 16) {
                            Button(action: {
                                showingImageSourcePicker = true
                            }) {
                                ZStack(alignment: .bottomTrailing) {
                                    if let avatarImage = profileManager.avatarImage {
                                        Image(uiImage: avatarImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 100, height: 100)
                                            .clipShape(Circle())
                                            .overlay(
                                                Circle()
                                                    .stroke(Color(red: 0, green: 1, blue: 0.6), lineWidth: 3)
                                            )
                                    } else {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    gradient: Gradient(colors: [.green, .mint]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 100, height: 100)
                                            .overlay(
                                                Text(profileManager.getInitials())
                                                    .font(.system(size: 40, weight: .bold))
                                                    .foregroundColor(.black)
                                            )
                                            .overlay(
                                                Circle()
                                                    .stroke(Color(red: 0, green: 1, blue: 0.6), lineWidth: 3)
                                            )
                                    }
                                    
                                    // 编辑头像按钮
                                    Circle()
                                        .fill(Color(red: 0, green: 1, blue: 0.6))
                                        .frame(width: 32, height: 32)
                                        .overlay(
                                            Image(systemName: "camera.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(.black)
                                        )
                                }
                            }
                            
                            Text("点击头像更换")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 40)
                        
                        // 用户名输入
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(Color(red: 0, green: 1, blue: 0.6))
                                Text("用户名")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            TextField("请输入用户名", text: $tempUsername)
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .padding(.horizontal, 24)
                        
                        // 个性签名输入
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "text.quote")
                                    .foregroundColor(Color(red: 0, green: 1, blue: 0.6))
                                Text("个性签名")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            ZStack(alignment: .topLeading) {
                                // 背景
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                
                                // 占位符
                                if tempSignature.isEmpty {
                                    Text("分享你的心情...")
                                        .font(.system(size: 16))
                                        .foregroundColor(.gray)
                                        .padding(.horizontal, 12)
                                        .padding(.top, 16)
                                }
                                
                                // 输入框
                                TextEditor(text: $tempSignature)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white)
                                    .scrollContentBackground(.hidden)
                                    .background(Color.clear)
                                    .padding(8)
                            }
                            .frame(height: 100)
                            
                            Text("\(tempSignature.count)/50")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .padding(.horizontal, 24)
                        
                        // 保存按钮
                        Button(action: {
                            saveProfile()
                        }) {
                            Text("保存修改")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(red: 0, green: 1, blue: 0.6))
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("编辑资料")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
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
    
    private func saveProfile() {
        // 限制签名长度
        let limitedSignature = String(tempSignature.prefix(50))
        
        profileManager.updateUsername(tempUsername)
        profileManager.updateSignature(limitedSignature)
        
        dismiss()
    }
}

#Preview {
    EditProfileView(profileManager: ProfileManager())
}

