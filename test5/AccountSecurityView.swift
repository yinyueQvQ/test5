//
//  AccountSecurityView.swift
//  test5
//
//  账号安全页面
//

import SwiftUI

struct AccountSecurityView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showingChangePassword = false
    @State private var showingBindPhone = false
    @State private var showingBindEmail = false
    @State private var phoneNumber = "138****8888" // 示例数据
    @State private var email = "user****@example.com" // 示例数据
    @State private var isTwoFactorEnabled = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // 安全等级卡片
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.green)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("账号安全等级")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                
                                Text("中等")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                        }
                        
                        // 安全进度条
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.green, .cyan]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: UIScreen.main.bounds.width * 0.6, height: 8)
                        }
                        
                        Text("建议开启双重认证以提高账号安全性")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white.opacity(0.05))
                    )
                    .padding(.horizontal, 24)
                    
                    // 登录信息
                    VStack(alignment: .leading, spacing: 16) {
                        Text("登录信息")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        VStack(spacing: 0) {
                            SecurityMenuItem(
                                icon: "lock.fill",
                                title: "登录密码",
                                subtitle: "定期更换密码可提高安全性",
                                iconColor: .cyan,
                                hasChevron: true
                            ) {
                                showingChangePassword = true
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.leading, 60)
                            
                            SecurityMenuItem(
                                icon: "phone.fill",
                                title: "手机号",
                                subtitle: phoneNumber,
                                iconColor: .purple,
                                hasChevron: true
                            ) {
                                showingBindPhone = true
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.leading, 60)
                            
                            SecurityMenuItem(
                                icon: "envelope.fill",
                                title: "邮箱",
                                subtitle: email,
                                iconColor: .orange,
                                hasChevron: true
                            ) {
                                showingBindEmail = true
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // 安全设置
                    VStack(alignment: .leading, spacing: 16) {
                        Text("安全设置")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        VStack(spacing: 0) {
                            HStack(spacing: 16) {
                                Image(systemName: "key.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.green)
                                    .frame(width: 28)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("双重认证")
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                    
                                    Text("增强账号安全性")
                                        .font(.system(size: 13))
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Toggle("", isOn: $isTwoFactorEnabled)
                                    .tint(Color(red: 0, green: 1, blue: 0.6))
                            }
                            .padding(16)
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // 设备管理
                    VStack(alignment: .leading, spacing: 16) {
                        Text("设备管理")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        VStack(spacing: 0) {
                            SecurityMenuItem(
                                icon: "iphone",
                                title: "我的设备",
                                subtitle: "管理已登录的设备",
                                iconColor: .mint,
                                hasChevron: true
                            ) {
                                // 跳转到设备列表
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.leading, 60)
                            
                            SecurityMenuItem(
                                icon: "clock.fill",
                                title: "登录历史",
                                subtitle: "查看最近的登录记录",
                                iconColor: .blue,
                                hasChevron: true
                            ) {
                                // 跳转到登录历史
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // 危险区域
                    VStack(alignment: .leading, spacing: 16) {
                        Text("账号操作")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                        
                        VStack(spacing: 0) {
                            SecurityMenuItem(
                                icon: "arrow.right.circle.fill",
                                title: "退出登录",
                                subtitle: "退出当前账号",
                                iconColor: .yellow,
                                hasChevron: false
                            ) {
                                // 退出登录
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.leading, 60)
                            
                            SecurityMenuItem(
                                icon: "trash.fill",
                                title: "注销账号",
                                subtitle: "永久删除账号及所有数据",
                                iconColor: .red,
                                hasChevron: false
                            ) {
                                // 注销账号
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
                Text("账号安全")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .sheet(isPresented: $showingChangePassword) {
            ChangePasswordView()
        }
        .sheet(isPresented: $showingBindPhone) {
            BindPhoneView()
        }
        .sheet(isPresented: $showingBindEmail) {
            BindEmailView()
        }
    }
}

// 安全设置菜单项
struct SecurityMenuItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let hasChevron: Bool
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
                
                if hasChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 修改密码视图（占位）
struct ChangePasswordView: View {
    @Environment(\.dismiss) var dismiss
    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 说明文本
                        VStack(alignment: .leading, spacing: 8) {
                            Text("设置新密码")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("密码需要包含数字、字母，长度8-20位")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 40)
                        
                        // 旧密码
                        VStack(alignment: .leading, spacing: 12) {
                            Text("原密码")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            SecureField("请输入原密码", text: $oldPassword)
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
                        
                        // 新密码
                        VStack(alignment: .leading, spacing: 12) {
                            Text("新密码")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            SecureField("请输入新密码", text: $newPassword)
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
                        
                        // 确认密码
                        VStack(alignment: .leading, spacing: 12) {
                            Text("确认密码")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            SecureField("请再次输入新密码", text: $confirmPassword)
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
                        
                        // 提交按钮
                        Button(action: {
                            // 提交修改
                            dismiss()
                        }) {
                            Text("确认修改")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color(red: 0, green: 1, blue: 0.6))
                                .cornerRadius(16)
                        }
                        .padding(.top, 20)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationTitle("修改密码")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

// 绑定手机视图（占位）
struct BindPhoneView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    Text("绑定/更换手机号")
                        .foregroundColor(.white)
                }
            }
            .navigationTitle("手机号")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

// 绑定邮箱视图（占位）
struct BindEmailView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    Text("绑定/更换邮箱")
                        .foregroundColor(.white)
                }
            }
            .navigationTitle("邮箱")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

#Preview {
    AccountSecurityView()
}

