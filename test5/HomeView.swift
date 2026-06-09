//
//  HomeView.swift
//  test5
//
//  首页 - AIGC灵感、作品展示
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var draftManager: DraftManager
    @StateObject private var worksManager = WorksManager.shared
    @StateObject private var profileManager = ProfileManager()
    @State private var showingProfile = false
    @State private var showingWorksView = false
    @State private var selectedWorksTab: WorksView.WorkTab = .published
    @State private var showingCreateView = false
    @State private var selectedInspirationImage: String? = nil
    @State private var selectedInspirationTitle: String = ""
    @State private var selectedInspirationSubtitle: String = ""
    
    var body: some View {
        ZStack {
            // 背景
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // 顶部用户卡片
                    UserProfileCard(showingProfile: $showingProfile, profileManager: profileManager)
                        .padding(.horizontal, 16)
                        .padding(.top, 60)
                    
                    // AIGC灵感标题
                    HStack {
                        Text("AIGC")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.green)
                        + Text("灵感")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.purple)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    
                    // AIGC灵感卡片横向滚动
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            InspirationCard(
                                imageName: "WechatIMG14736",
                                title: "未来主义艺术",
                                subtitle: "探索科技与艺术的完美融合"
                            ) {
                                selectedInspirationImage = "WechatIMG14736"
                                selectedInspirationTitle = "未来主义艺术"
                                selectedInspirationSubtitle = "探索科技与艺术的完美融合"
                            }
                            
                            InspirationCard(
                                imageName: "WechatIMG14735",
                                title: "数字幻境",
                                subtitle: "用算法创造视觉奇观"
                            ) {
                                selectedInspirationImage = "WechatIMG14735"
                                selectedInspirationTitle = "数字幻境"
                                selectedInspirationSubtitle = "用算法创造视觉奇观"
                            }
                            
                            InspirationCard(
                                imageName: "WechatIMG14737",
                                title: "赛博朋克城市",
                                subtitle: "霓虹灯下的未来世界"
                            ) {
                                selectedInspirationImage = "WechatIMG14737"
                                selectedInspirationTitle = "赛博朋克城市"
                                selectedInspirationSubtitle = "霓虹灯下的未来世界"
                            }
                            
                    
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // 我的作品和草稿卡片（使用 WorksManager）
                    HStack(spacing: 16) {
                        // 我的作品
                        WorkStatsCard(
                            icon: "photo.fill",
                            title: "已发布",
                            count: "\(worksManager.publishedCount) 件作品",
                            color: .purple
                        ) {
                            selectedWorksTab = .published
                            showingWorksView = true
                        }
                        
                        // 草稿
                        WorkStatsCard(
                            icon: "doc.fill",
                            title: "草稿箱",
                            count: "\(worksManager.draftCount) 个草稿",
                            color: .orange
                        ) {
                            selectedWorksTab = .drafts
                            showingWorksView = true
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    
                    Spacer(minLength: 100)
                }
            }
        }
        .sheet(isPresented: $showingProfile) {
            MaterialView()
        }
        .sheet(isPresented: $showingWorksView) {
            WorksViewWithTab(initialTab: selectedWorksTab)
        }
        .fullScreenCover(isPresented: $showingCreateView) {
            CreateView()
                .environmentObject(draftManager)
        }
        .sheet(item: Binding(
            get: { selectedInspirationImage.map { InspirationDetail(imageName: $0, title: selectedInspirationTitle, subtitle: selectedInspirationSubtitle) } },
            set: { selectedInspirationImage = $0?.imageName }
        )) { detail in
            InspirationDetailView(imageName: detail.imageName, title: detail.title, subtitle: detail.subtitle)
        }
    }
}

// 用户信息卡片
struct UserProfileCard: View {
    @Binding var showingProfile: Bool
    @ObservedObject var profileManager: ProfileManager
    
    var body: some View {
        Button(action: {
            showingProfile = true
        }) {
            HStack(spacing: 16) {
                // 头像
                if let avatarImage = profileManager.avatarImage {
                    Image(uiImage: avatarImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
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
                        .frame(width: 60, height: 60)
                        .overlay(
                            Text(profileManager.getInitials())
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.black)
                        )
                }
                
                // 用户信息
                VStack(alignment: .leading, spacing: 4) {
                    Text(profileManager.username)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(profileManager.signature)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // 设置图标（装饰性）
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 灵感卡片
struct InspirationCard: View {
    let imageName: String
    let title: String
    let subtitle: String
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // 图片区域 - 使用实际图片
                if let uiImage = UIImage(named: imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 300, height: 200)
                        .clipped()
                        .cornerRadius(16)
                        .overlay(
                            LinearGradient(
                                colors: [Color.black.opacity(0.6), Color.clear],
                                startPoint: .bottom,
                                endPoint: .center
                            )
                            .cornerRadius(16)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [.purple.opacity(0.6), .blue.opacity(0.4)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 300, height: 200)
                        .overlay(
                            Image(systemName: "photo.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white.opacity(0.3))
                        )
                }
                
                // 标题和描述
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(16)
                .frame(width: 300, alignment: .leading)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 作品统计卡片
struct WorkStatsCard: View {
    let icon: String
    let title: String
    let count: String
    let color: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 40))
                    .foregroundColor(color)
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(count)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView()
}

// WorksView 包装器（支持初始 Tab）
struct WorksViewWithTab: View {
    let initialTab: WorksView.WorkTab
    
    var body: some View {
        WorksView()
    }
}

// 灵感详情数据结构
struct InspirationDetail: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let subtitle: String
}

// 灵感图片详情视图
struct InspirationDetailView: View {
    let imageName: String
    let title: String
    let subtitle: String
    @Environment(\.dismiss) var dismiss
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    @State private var isFavorited: Bool = false
    @State private var showingShareSheet = false
    @State private var showingCreateView = false
    @State private var showingSuccessMessage = false
    @State private var successMessage = ""
    
    var body: some View {
        ZStack {
            // 背景
            Color.black.opacity(0.95)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        scale = 0.8
                        opacity = 0
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        dismiss()
                    }
                }
            
            VStack(spacing: 0) {
                // 顶部关闭按钮
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            scale = 0.8
                            opacity = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            dismiss()
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.8))
                            .shadow(color: .black.opacity(0.3), radius: 10)
                    }
                    .padding()
                }
                .padding(.top, 50)
                
                Spacer()
                
                // 图片卡片
                VStack(spacing: 0) {
                    // 放大的图片
                    if let uiImage = UIImage(named: imageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: UIScreen.main.bounds.height * 0.6)
                            .cornerRadius(24)
                            .shadow(color: .purple.opacity(0.5), radius: 30, x: 0, y: 10)
                    }
                    
                    // 信息卡片
                    VStack(spacing: 16) {
                        // 标题
                        Text(title)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                        
                        // 副标题
                        Text(subtitle)
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        // 分隔线
                        Rectangle()
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 1)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 8)
                        
                        // 操作按钮
                        HStack(spacing: 20) {
                            // 收藏按钮
                            ActionButton(
                                icon: isFavorited ? "heart.fill" : "heart",
                                text: isFavorited ? "已收藏" : "收藏",
                                color: .pink
                            ) {
                                handleFavorite()
                            }
                            
                            // 分享按钮
                            ActionButton(
                                icon: "square.and.arrow.up.fill",
                                text: "分享",
                                color: .blue
                            ) {
                                handleShare()
                            }
                            
                            // 创作按钮
                            ActionButton(
                                icon: "wand.and.stars",
                                text: "开始创作",
                                color: .green
                            ) {
                                handleCreate()
                            }
                        }
                        .padding(.top, 8)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.white.opacity(0.1))
                            .background(
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(.ultraThinMaterial)
                            )
                    )
                    .padding(.top, 20)
                }
                .padding(.horizontal, 20)
                .scaleEffect(scale)
                .opacity(opacity)
                
                Spacer()
            }
            
            // 成功提示
            if showingSuccessMessage {
                VStack {
                    Spacer()
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.green)
                        
                        Text(successMessage)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.8))
                            .shadow(color: .green.opacity(0.3), radius: 20)
                    )
                    .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let image = UIImage(named: imageName) {
                ShareSheet(items: [image, title, subtitle])
            }
        }
        .fullScreenCover(isPresented: $showingCreateView) {
            CreateView()
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            // 检查是否已收藏
            loadFavoriteStatus()
        }
    }
    
    // MARK: - 功能函数
    
    /// 处理收藏
    private func handleFavorite() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            isFavorited.toggle()
        }
        
        if isFavorited {
            // 保存到收藏
            saveFavorite()
            showSuccess(message: "已添加到收藏")
        } else {
            // 取消收藏
            removeFavorite()
            showSuccess(message: "已取消收藏")
        }
    }
    
    /// 处理分享
    private func handleShare() {
        showingShareSheet = true
    }
    
    /// 处理开始创作
    private func handleCreate() {
        // 关闭当前详情页
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            scale = 0.8
            opacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            dismiss()
            // 延迟一下再打开创作页面，让关闭动画完成
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showingCreateView = true
            }
        }
    }
    
    /// 显示成功提示
    private func showSuccess(message: String) {
        successMessage = message
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            showingSuccessMessage = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showingSuccessMessage = false
            }
        }
    }
    
    /// 保存收藏
    private func saveFavorite() {
        let favorite = FavoriteInspiration(
            imageName: imageName,
            title: title,
            subtitle: subtitle,
            timestamp: Date()
        )
        UnifiedFavoriteManager.shared.addInspirationFavorite(favorite)
    }
    
    /// 取消收藏
    private func removeFavorite() {
        UnifiedFavoriteManager.shared.removeInspirationFavorite(imageName: imageName)
    }
    
    /// 加载收藏状态
    private func loadFavoriteStatus() {
        isFavorited = UnifiedFavoriteManager.shared.isInspirationFavorited(imageName: imageName)
    }
}

// 操作按钮组件
struct ActionButton: View {
    let icon: String
    let text: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // 触觉反馈
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            action()
        }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                
                Text(text)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(isPressed ? 0.4 : 0.2))
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
    }
}

// 按钮按压效果扩展
extension View {
    func pressEvents(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged({ _ in
                    onPress()
                })
                .onEnded({ _ in
                    onRelease()
                })
        )
    }
}

// MARK: - 收藏相关

/// 收藏的灵感数据模型
struct FavoriteInspiration: Codable, Identifiable {
    let id: String
    let imageName: String
    let title: String
    let subtitle: String
    let timestamp: Date
    
    init(imageName: String, title: String, subtitle: String, timestamp: Date) {
        self.id = UUID().uuidString
        self.imageName = imageName
        self.title = title
        self.subtitle = subtitle
        self.timestamp = timestamp
    }
}

/// 统一收藏管理器 - 管理AIGC灵感和作品的收藏
class UnifiedFavoriteManager: ObservableObject {
    static let shared = UnifiedFavoriteManager()
    
    @Published private(set) var favoriteInspirations: [FavoriteInspiration] = []
    @Published private(set) var favoriteWorks: [Work] = []
    
    private let inspirationsKey = "savedFavoriteInspirations"
    private let worksKey = "savedFavoriteWorks"
    
    init() {
        loadFavorites()
    }
    
    // MARK: - AIGC灵感收藏
    
    /// 添加灵感收藏
    func addInspirationFavorite(_ favorite: FavoriteInspiration) {
        if !favoriteInspirations.contains(where: { $0.imageName == favorite.imageName }) {
            favoriteInspirations.append(favorite)
            saveInspirationFavorites()
        }
    }
    
    /// 移除灵感收藏
    func removeInspirationFavorite(imageName: String) {
        favoriteInspirations.removeAll { $0.imageName == imageName }
        saveInspirationFavorites()
    }
    
    /// 检查灵感是否已收藏
    func isInspirationFavorited(imageName: String) -> Bool {
        return favoriteInspirations.contains { $0.imageName == imageName }
    }
    
    // MARK: - 作品收藏
    
    /// 添加作品收藏
    func addWorkFavorite(_ work: Work) {
        if !favoriteWorks.contains(where: { $0.id == work.id }) {
            favoriteWorks.append(work)
            saveWorkFavorites()
        }
    }
    
    /// 移除作品收藏
    func removeWorkFavorite(workId: UUID) {
        favoriteWorks.removeAll { $0.id == workId }
        saveWorkFavorites()
    }
    
    /// 检查作品是否已收藏
    func isWorkFavorited(workId: UUID) -> Bool {
        return favoriteWorks.contains { $0.id == workId }
    }
    
    // MARK: - 计数
    
    var inspirationCount: Int {
        favoriteInspirations.count
    }
    
    var worksCount: Int {
        favoriteWorks.count
    }
    
    var totalCount: Int {
        inspirationCount + worksCount
    }
    
    // MARK: - 持久化
    
    private func saveInspirationFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteInspirations) {
            UserDefaults.standard.set(encoded, forKey: inspirationsKey)
        }
    }
    
    private func saveWorkFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteWorks) {
            UserDefaults.standard.set(encoded, forKey: worksKey)
        }
    }
    
    private func loadFavorites() {
        // 加载灵感收藏
        if let data = UserDefaults.standard.data(forKey: inspirationsKey),
           let decoded = try? JSONDecoder().decode([FavoriteInspiration].self, from: data) {
            favoriteInspirations = decoded
        }
        
        // 加载作品收藏
        if let data = UserDefaults.standard.data(forKey: worksKey),
           let decoded = try? JSONDecoder().decode([Work].self, from: data) {
            favoriteWorks = decoded
        }
    }
}

/// 兼容旧代码的 FavoriteManager（指向统一管理器）
typealias FavoriteManager = UnifiedFavoriteManager

