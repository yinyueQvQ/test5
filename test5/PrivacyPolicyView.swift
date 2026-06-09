//
//  PrivacyPolicyView.swift
//  test5
//
//  隐私政策页面
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                        // 更新日期
                        Text("最后更新：2025年10月29日")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                        
                        // 引言
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 12) {
                                Image(systemName: "lock.shield.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.green)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("我们重视您的隐私")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("您的信任对我们至关重要")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Text("本隐私政策说明了 Innoforge 如何收集、使用、存储和保护您的个人信息。使用我们的服务即表示您同意本政策中描述的做法。")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 8)
                        }
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.green.opacity(0.1))
                        )
                        
                        // 隐私政策内容
                        PrivacySection(
                            icon: "info.circle.fill",
                            iconColor: .blue,
                            title: "我们收集哪些信息",
                            content: """
                            我们可能收集以下类型的信息：
                            
                            • 账号信息：用户名、邮箱地址、手机号码、头像
                            • 创作内容：您上传的图片、生成的作品、提示词
                            • 使用数据：应用使用情况、功能偏好、设备信息
                            • 技术信息：IP地址、设备型号、操作系统版本
                            • 位置信息：仅在您授权时收集（可选）
                            """
                        )
                        
                        PrivacySection(
                            icon: "gear.circle.fill",
                            iconColor: .purple,
                            title: "我们如何使用信息",
                            content: """
                            我们使用收集的信息用于：
                            
                            • 提供和改进服务：处理您的创作请求，优化功能体验
                            • 个性化推荐：根据您的偏好推荐内容和功能
                            • 账号管理：验证身份、恢复账号、发送通知
                            • 安全保护：检测和防止欺诈、滥用等行为
                            • 数据分析：了解用户行为，改进产品设计
                            • 客户支持：响应您的咨询和反馈
                            """
                        )
                        
                        PrivacySection(
                            icon: "lock.circle.fill",
                            iconColor: .orange,
                            title: "信息存储与安全",
                            content: """
                            • 加密传输：所有数据传输均采用 SSL/TLS 加密
                            • 安全存储：服务器采用行业标准的安全措施
                            • 访问控制：严格限制员工对用户数据的访问权限
                            • 定期审计：定期进行安全审计和漏洞修复
                            • 备份机制：定期备份数据以防止丢失
                            
                            尽管我们采取了合理的安全措施，但无法保证绝对安全。
                            """
                        )
                        
                        PrivacySection(
                            icon: "person.2.fill",
                            iconColor: .cyan,
                            title: "信息共享与披露",
                            content: """
                            我们不会出售您的个人信息。在以下情况下，我们可能会共享您的信息：
                            
                            • 征得您的同意：在获得您明确同意的情况下
                            • 服务提供商：与协助我们运营的第三方服务商（如云存储）
                            • 法律要求：根据法律、法规或政府要求
                            • 权利保护：保护我们或他人的合法权益
                            • 业务转让：在合并、收购等业务变更情况下
                            
                            我们会要求第三方遵守本隐私政策和相关法律法规。
                            """
                        )
                        
                        PrivacySection(
                            icon: "hand.raised.fill",
                            iconColor: .green,
                            title: "您的权利",
                            content: """
                            您对自己的个人信息享有以下权利：
                            
                            • 访问权：查看我们持有的关于您的信息
                            • 更正权：更正不准确或不完整的信息
                            • 删除权：要求删除您的个人信息
                            • 限制权：限制我们处理您的信息
                            • 可携权：以常用格式接收您的数据
                            • 反对权：反对某些类型的数据处理
                            
                            您可以在「设置 > 隐私设置」中管理这些权利。
                            """
                        )
                        
                        PrivacySection(
                            icon: "photo.circle.fill",
                            iconColor: .pink,
                            title: "您的创作内容",
                            content: """
                            • 所有权：您对创作的内容拥有完整权利
                            • 可见性：您可以控制作品的公开或私密状态
                            • 删除权：您可以随时删除自己的作品
                            • 使用授权：您授权我们展示您的公开作品以宣传服务
                            • 自动删除：草稿箱中超过180天的草稿将被自动删除
                            """
                        )
                        
                        PrivacySection(
                            icon: "person.badge.shield.checkmark.fill",
                            iconColor: .indigo,
                            title: "未成年人保护",
                            content: """
                            • 我们的服务面向13岁及以上用户
                            • 我们不会故意收集13岁以下儿童的个人信息
                            • 如发现收集了儿童信息，我们将立即删除
                            • 家长或监护人如发现相关情况，请及时联系我们
                            """
                        )
                        
                        PrivacySection(
                            icon: "globe",
                            iconColor: .blue,
                            title: "跨境数据传输",
                            content: """
                            您的信息可能会被传输到您所在国家/地区以外的服务器。我们会确保这些传输符合适用的数据保护法律，并采取适当的保护措施。
                            """
                        )
                        
                        PrivacySection(
                            icon: "app.badge.fill",
                            iconColor: .teal,
                            title: "Cookie 和追踪技术",
                            content: """
                            我们使用 Cookie 和类似技术来：
                            
                            • 记住您的偏好设置
                            • 分析应用使用情况
                            • 优化用户体验
                            
                            您可以在设备设置中管理这些技术的使用。
                            """
                        )
                        
                        PrivacySection(
                            icon: "arrow.triangle.2.circlepath.circle.fill",
                            iconColor: .yellow,
                            title: "政策更新",
                            content: """
                            我们可能会不时更新本隐私政策。更新后的政策将在应用内发布，重大变更会通过通知或邮件告知您。继续使用服务即表示接受更新后的政策。
                            """
                        )
                        
                        PrivacySection(
                            icon: "envelope.circle.fill",
                            iconColor: .red,
                            title: "联系我们",
                            content: """
                            如果您对本隐私政策有任何疑问、意见或投诉，请通过以下方式联系我们：
                            
                            • 邮箱：privacy@innoforge.com
                            • 应用内反馈：设置 > 意见反馈
                            • 邮寄地址：[公司地址]
                            
                            我们会在收到您的请求后15个工作日内回复。
                            """
                        )
                        
                        // 底部声明
                        VStack(alignment: .leading, spacing: 12) {
                            Divider()
                                .background(Color.white.opacity(0.2))
                            
                            Text("您的隐私和信任对我们至关重要。感谢您选择 Innoforge！")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.green)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.top, 20)
                        
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("隐私政策")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

// 隐私政策章节
struct PrivacySection: View {
    let icon: String
    let iconColor: Color
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(iconColor)
                    .frame(width: 32)
                
                Text(title)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text(content)
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
    }
}

#Preview {
    PrivacyPolicyView()
}


