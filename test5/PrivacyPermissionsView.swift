//
//  PrivacyPermissionsView.swift
//  test5
//
//  隐私权限页面
//

import SwiftUI

struct PrivacyPermissionsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var permissionManager = PermissionManager()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // 权限说明
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "hand.raised.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.green)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("权限管理")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Text("管理应用程序访问设备功能的权限")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.05))
                    )
                    .padding(.horizontal, 24)
                    
                    // 必需权限
                    VStack(alignment: .leading, spacing: 16) {
                        Text("必需权限")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        VStack(spacing: 0) {
                            PermissionCard(
                                icon: "photo.fill",
                                title: "相册访问",
                                description: "用于上传和保存图片作品",
                                status: permissionManager.photoLibraryStatus,
                                iconColor: .purple
                            ) {
                                Task {
                                    await permissionManager.requestPhotoLibraryPermission()
                                }
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.leading, 60)
                            
                            PermissionCard(
                                icon: "camera.fill",
                                title: "相机访问",
                                description: "用于拍摄照片进行创作",
                                status: permissionManager.cameraStatus,
                                iconColor: .cyan
                            ) {
                                Task {
                                    await permissionManager.requestCameraPermission()
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // 可选权限
                    VStack(alignment: .leading, spacing: 16) {
                        Text("可选权限")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        VStack(spacing: 0) {
                            PermissionCard(
                                icon: "bell.fill",
                                title: "通知权限",
                                description: "接收作品互动和系统通知",
                                status: permissionManager.notificationStatus,
                                iconColor: .orange
                            ) {
                                Task {
                                    await permissionManager.requestNotificationPermission()
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // 权限提示
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("权限说明")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text("如果权限被拒绝，某些功能可能无法正常使用。您可以在系统设置中修改权限。")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        
                        Button(action: {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            Text("前往系统设置")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(red: 0, green: 1, blue: 0.6))
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue.opacity(0.1))
                    )
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("隐私权限")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

// 权限卡片
struct PermissionCard: View {
    let icon: String
    let title: String
    let description: String
    let status: PermissionStatus
    let iconColor: Color
    let action: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(iconColor)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 8, height: 8)
                    
                    Text(statusText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(statusColor)
                }
                .padding(.top, 4)
            }
            
            Spacer()
            
            if status == .notDetermined || status == .denied {
                Button(action: action) {
                    Text(status == .notDetermined ? "授权" : "重新授权")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(red: 0, green: 1, blue: 0.6))
                        .cornerRadius(20)
                }
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
            }
        }
        .padding(16)
    }
    
    private var statusColor: Color {
        switch status {
        case .authorized:
            return .green
        case .denied, .restricted:
            return .red
        case .notDetermined:
            return .orange
        }
    }
    
    private var statusText: String {
        switch status {
        case .authorized:
            return "已授权"
        case .denied:
            return "已拒绝"
        case .restricted:
            return "受限制"
        case .notDetermined:
            return "未授权"
        }
    }
}

#Preview {
    PrivacyPermissionsView()
}

