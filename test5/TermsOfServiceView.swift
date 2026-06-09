//
//  TermsOfServiceView.swift
//  test5
//
//  服务条款页面
//

import SwiftUI

struct TermsOfServiceView: View {
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
                        
                        // 欢迎语
                        VStack(alignment: .leading, spacing: 12) {
                            Text("欢迎使用 Innoforge")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("感谢您选择 Innoforge！在使用我们的服务之前，请仔细阅读以下服务条款。使用本应用即表示您同意遵守这些条款。")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        // 条款内容
                        TermsSection(
                            number: "1",
                            title: "服务说明",
                            content: """
                            1.1 Innoforge 是一款基于人工智能技术的创意设计工具，为用户提供图像生成、风格转换等功能。
                            
                            1.2 我们致力于提供高质量的服务，但不保证服务始终不中断、及时、安全或无错误。
                            
                            1.3 我们保留随时修改、暂停或终止服务的权利，恕不另行通知。
                            """
                        )
                        
                        TermsSection(
                            number: "2",
                            title: "用户责任",
                            content: """
                            2.1 您有责任保护账号的安全性，不得与他人共享账号信息。
                            
                            2.2 您同意不使用本服务从事任何非法、侵权或违反公序良俗的行为。
                            
                            2.3 您上传的内容必须符合法律法规，不得包含色情、暴力、仇恨言论等不当内容。
                            
                            2.4 您对使用本服务创作的内容承担全部责任。
                            """
                        )
                        
                        TermsSection(
                            number: "3",
                            title: "知识产权",
                            content: """
                            3.1 Innoforge 及其所有内容的知识产权归我们所有，受版权法和其他知识产权法保护。
                            
                            3.2 您通过本服务创作的内容，其知识产权归您所有。但您授予我们在全球范围内使用、展示这些内容的权利，以改进和宣传我们的服务。
                            
                            3.3 您不得复制、修改、分发本应用的任何部分，除非获得我们的明确授权。
                            """
                        )
                        
                        TermsSection(
                            number: "4",
                            title: "隐私保护",
                            content: """
                            4.1 我们非常重视您的隐私。关于我们如何收集、使用和保护您的个人信息，请参阅我们的《隐私政策》。
                            
                            4.2 我们承诺不会出售或出租您的个人信息给第三方。
                            
                            4.3 您的创作内容将按照您的隐私设置进行展示和分享。
                            """
                        )
                        
                        TermsSection(
                            number: "5",
                            title: "免责声明",
                            content: """
                            5.1 本服务按"现状"提供，我们不对服务的适用性、准确性或可靠性做出任何明示或暗示的保证。
                            
                            5.2 我们不对因使用或无法使用本服务而导致的任何直接、间接、偶然或后果性损害承担责任。
                            
                            5.3 AI生成的内容可能存在不可预测性，我们不对生成结果的质量或适用性承担责任。
                            """
                        )
                        
                        TermsSection(
                            number: "6",
                            title: "服务变更与终止",
                            content: """
                            6.1 我们保留随时修改本服务条款的权利。修改后的条款将在应用内公布，继续使用服务即表示接受修改。
                            
                            6.2 我们有权在不事先通知的情况下，暂停或终止违反本条款的用户账号。
                            
                            6.3 您可以随时停止使用本服务并删除账号。
                            """
                        )
                        
                        TermsSection(
                            number: "7",
                            title: "争议解决",
                            content: """
                            7.1 本条款受中华人民共和国法律管辖。
                            
                            7.2 因本条款引起的任何争议，双方应首先通过友好协商解决。
                            
                            7.3 协商不成的，任何一方可向我们所在地有管辖权的人民法院提起诉讼。
                            """
                        )
                        
                        TermsSection(
                            number: "8",
                            title: "联系我们",
                            content: """
                            如果您对本服务条款有任何疑问或建议，请通过以下方式联系我们：
                            
                            邮箱：support@innoforge.com
                            应用内反馈：设置 > 意见反馈
                            """
                        )
                        
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("服务条款")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

// 条款章节
struct TermsSection: View {
    let number: String
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color(red: 0, green: 1, blue: 0.6))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(number)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                    )
                
                Text(title)
                    .font(.system(size: 18, weight: .bold))
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
    TermsOfServiceView()
}


