//
//  HelpCenterView.swift
//  test5
//
//  帮助中心页面
//

import SwiftUI

struct HelpCenterView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var expandedSections: Set<Int> = []
    
    let helpSections = [
        HelpSection(
            title: "快速入门",
            icon: "flag.fill",
            iconColor: .green,
            items: [
                HelpItem(question: "如何开始创作？", answer: "点击底部「创作」按钮，选择素材图片，然后应用风格转换或生成效果。您可以随时保存到草稿箱或发布作品。"),
                HelpItem(question: "如何使用AI生成图片？", answer: "在创作页面，选择「AI生成」功能，输入您的创意描述（提示词），系统会根据您的描述生成独特的图片。"),
                HelpItem(question: "什么是风格转换？", answer: "风格转换可以将您的照片转换成不同的艺术风格，如卡通、油画、像素风等。上传照片后选择喜欢的风格即可。")
            ]
        ),
        HelpSection(
            title: "创作功能",
            icon: "paintbrush.fill",
            iconColor: .purple,
            items: [
                HelpItem(question: "支持哪些图片格式？", answer: "支持 JPG、PNG、HEIC 等常见图片格式。建议上传高质量图片以获得最佳效果。"),
                HelpItem(question: "生成图片需要多长时间？", answer: "通常在10-30秒内完成。具体时间取决于服务器负载和图片复杂度。"),
                HelpItem(question: "如何保存作品？", answer: "创作完成后，点击「保存」按钮，可以选择保存到草稿箱或直接发布。已保存的作品可以在「作品」或「背包」中查看。"),
                HelpItem(question: "作品可以重新编辑吗？", answer: "可以。在作品详情页点击「编辑」，或在草稿箱中继续编辑未完成的作品。")
            ]
        ),
        HelpSection(
            title: "账号与安全",
            icon: "person.fill",
            iconColor: .cyan,
            items: [
                HelpItem(question: "如何修改个人资料？", answer: "进入「我的」页面，点击「编辑资料」，可以修改用户名、头像和个性签名。"),
                HelpItem(question: "如何保护账号安全？", answer: "建议开启双重认证、定期修改密码，并绑定手机号和邮箱。在「设置 > 账号安全」中可以管理这些选项。"),
                HelpItem(question: "忘记密码怎么办？", answer: "在登录页面点击「忘记密码」，通过绑定的手机号或邮箱重置密码。")
            ]
        ),
        HelpSection(
            title: "隐私与权限",
            icon: "lock.fill",
            iconColor: .orange,
            items: [
                HelpItem(question: "为什么需要相册权限？", answer: "相册权限用于上传创作素材和保存生成的作品。我们不会上传或存储您相册中的其他照片。"),
                HelpItem(question: "我的作品会被公开吗？", answer: "您可以在「隐私设置」中选择作品的可见性。默认情况下，只有您发布的作品会被其他用户看到，草稿箱中的作品仅您可见。"),
                HelpItem(question: "如何管理数据隐私？", answer: "在「设置 > 隐私设置」中，您可以控制个人信息展示、数据收集和个性化推荐等选项。")
            ]
        ),
        HelpSection(
            title: "常见问题",
            icon: "questionmark.circle.fill",
            iconColor: .pink,
            items: [
                HelpItem(question: "生成失败怎么办？", answer: "请检查网络连接，确保上传的图片格式正确。如果问题持续，请通过「意见反馈」联系我们。"),
                HelpItem(question: "如何获得更好的生成效果？", answer: "使用清晰、光线充足的图片；在AI生成时，提供详细、具体的描述；尝试不同的风格和参数设置。"),
                HelpItem(question: "作品可以导出吗？", answer: "可以。在作品详情页点击「保存到相册」，将作品导出到您的设备。"),
                HelpItem(question: "应用闪退或卡顿？", answer: "请尝试关闭并重新打开应用。如果问题持续，可以在「设置」中清除缓存，或重新安装应用。")
            ]
        ),
        HelpSection(
            title: "联系我们",
            icon: "envelope.fill",
            iconColor: .blue,
            items: [
                HelpItem(question: "如何反馈问题？", answer: "在「设置 > 意见反馈」中提交您遇到的问题，可以添加截图说明。我们会尽快回复您。"),
                HelpItem(question: "有新功能建议？", answer: "我们非常欢迎您的建议！请通过「意见反馈」告诉我们，您的想法可能会在下个版本中实现。"),
                HelpItem(question: "商务合作", answer: "请发送邮件至 business@innoforge.com 与我们联系。")
            ]
        )
    ]
    
    var filteredSections: [HelpSection] {
        if searchText.isEmpty {
            return helpSections
        }
        return helpSections.map { section in
            let filteredItems = section.items.filter { item in
                item.question.localizedCaseInsensitiveContains(searchText) ||
                item.answer.localizedCaseInsensitiveContains(searchText)
            }
            return HelpSection(
                title: section.title,
                icon: section.icon,
                iconColor: section.iconColor,
                items: filteredItems
            )
        }.filter { !$0.items.isEmpty }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 搜索栏
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("搜索帮助内容", text: $searchText)
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(12)
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal, 24)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(Array(filteredSections.enumerated()), id: \.offset) { index, section in
                            HelpSectionView(
                                section: section,
                                sectionIndex: index,
                                isExpanded: expandedSections.contains(index)
                            ) {
                                if expandedSections.contains(index) {
                                    expandedSections.remove(index)
                                } else {
                                    expandedSections.insert(index)
                                }
                            }
                        }
                        
                        // 底部联系卡片
                        VStack(spacing: 16) {
                            Image(systemName: "questionmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.green)
                            
                            Text("还有其他问题？")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("我们随时为您提供帮助")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                // 打开反馈页面
                            }) {
                                Text("联系客服")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Color(red: 0, green: 1, blue: 0.6))
                                    .cornerRadius(12)
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.05))
                        )
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.top, 10)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("帮助中心")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

// 帮助主题
struct HelpSection {
    let title: String
    let icon: String
    let iconColor: Color
    var items: [HelpItem]
}

// 帮助条目
struct HelpItem {
    let question: String
    let answer: String
}

// 帮助主题视图
struct HelpSectionView: View {
    let section: HelpSection
    let sectionIndex: Int
    let isExpanded: Bool
    let toggleExpand: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 主题标题
            Button(action: toggleExpand) {
                HStack(spacing: 16) {
                    Image(systemName: section.icon)
                        .font(.system(size: 24))
                        .foregroundColor(section.iconColor)
                        .frame(width: 28)
                    
                    Text(section.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(16)
            }
            .buttonStyle(PlainButtonStyle())
            
            // 展开的内容
            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(Array(section.items.enumerated()), id: \.offset) { index, item in
                        if index > 0 {
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.leading, 60)
                        }
                        
                        HelpItemView(item: item)
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
        )
        .padding(.horizontal, 24)
    }
}

// 帮助条目视图
struct HelpItemView: View {
    let item: HelpItem
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 20))
                        .foregroundColor(.cyan)
                    
                    Text(item.question)
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.green)
                    
                    Text(item.answer)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 14)
                .padding(.leading, 32)
            }
        }
    }
}

#Preview {
    HelpCenterView()
}

