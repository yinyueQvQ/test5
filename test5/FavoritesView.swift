//
//  FavoritesView.swift
//  test5
//
//  收藏页面 - 显示AIGC灵感和作品的收藏
//

import SwiftUI

struct FavoritesView: View {
    @StateObject private var favoriteManager = UnifiedFavoriteManager.shared
    @State private var selectedCategory: FavoriteCategory = .inspiration
    @State private var selectedInspiration: FavoriteInspiration?
    @State private var selectedWork: Work?
    
    enum FavoriteCategory: String, CaseIterable {
        case inspiration = "AIGC灵感"
        case works = "作品收藏"
        
        var icon: String {
            switch self {
            case .inspiration: return "sparkles"
            case .works: return "photo.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .inspiration: return .purple
            case .works: return .pink
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                categoryTabsView
                contentView
            }
        }
        .sheet(item: inspirationBinding) { detail in
            InspirationDetailView(imageName: detail.imageName, title: detail.title, subtitle: detail.subtitle)
        }
        .sheet(item: $selectedWork) { work in
            WorkDetailView(work: work)
        }
    }
    
    // MARK: - 子视图
    
    private var headerView: some View {
        Text("我的收藏")
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.top, 60)
            .padding(.bottom, 20)
    }
    
    private var categoryTabsView: some View {
        HStack(spacing: 0) {
            ForEach(FavoriteCategory.allCases, id: \.self) { category in
                CategoryTabButton(
                    category: category,
                    isSelected: selectedCategory == category,
                    count: category == .inspiration ? favoriteManager.inspirationCount : favoriteManager.worksCount
                ) {
                    withAnimation(.spring(response: 0.3)) {
                        selectedCategory = category
                    }
                }
            }
        }
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private var contentView: some View {
        Group {
            if selectedCategory == .inspiration {
                inspirationContentView
            } else {
                worksContentView
            }
        }
    }
    
    private var inspirationContentView: some View {
        Group {
            if favoriteManager.favoriteInspirations.isEmpty {
                EmptyFavoriteView(
                    icon: "sparkles",
                    title: "还没有收藏的灵感",
                    subtitle: "在首页点击灵感图片收藏吧",
                    color: .purple
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(favoriteManager.favoriteInspirations) { inspiration in
                            InspirationFavoriteCard(inspiration: inspiration)
                                .onTapGesture {
                                    selectedInspiration = inspiration
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
    }
    
    private var worksContentView: some View {
        Group {
            if favoriteManager.favoriteWorks.isEmpty {
                EmptyFavoriteView(
                    icon: "photo.fill",
                    title: "还没有收藏的作品",
                    subtitle: "在作品详情中点击收藏吧",
                    color: .pink
                )
            } else {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(favoriteManager.favoriteWorks) { work in
                            WorkFavoriteCard(work: work)
                                .onTapGesture {
                                    selectedWork = work
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
    }
    
    private var inspirationBinding: Binding<InspirationDetail?> {
        Binding(
            get: {
                selectedInspiration.map { InspirationDetail(imageName: $0.imageName, title: $0.title, subtitle: $0.subtitle) }
            },
            set: { _ in
                selectedInspiration = nil
            }
        )
    }
}

// MARK: - 分类标签按钮
struct CategoryTabButton: View {
    let category: FavoritesView.FavoriteCategory
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: category.icon)
                        .font(.system(size: 14))
                    
                    Text(category.rawValue)
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(isSelected ? category.color : .gray)
                
                Text("\(count)")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                isSelected ? category.color.opacity(0.1) : Color.clear
            )
        }
    }
}

// MARK: - AIGC灵感收藏卡片
struct InspirationFavoriteCard: View {
    let inspiration: FavoriteInspiration
    @StateObject private var favoriteManager = UnifiedFavoriteManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 图片
            if let uiImage = UIImage(named: inspiration.imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 160)
                    .clipped()
                    .cornerRadius(12)
                    .overlay(
                        // 收藏标记
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.pink)
                                    .padding(8)
                                    .background(
                                        Circle()
                                            .fill(Color.black.opacity(0.5))
                                    )
                                    .padding(8)
                            }
                            Spacer()
                        }
                    )
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 160)
                    .cornerRadius(12)
            }
            
            // 标题
            VStack(alignment: .leading, spacing: 4) {
                Text(inspiration.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(inspiration.subtitle)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            .padding(.horizontal, 4)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.purple.opacity(0.3), lineWidth: 1)
                )
        )
        .contextMenu {
            Button(role: .destructive) {
                favoriteManager.removeInspirationFavorite(imageName: inspiration.imageName)
            } label: {
                Label("取消收藏", systemImage: "heart.slash")
            }
        }
    }
}

// MARK: - 作品收藏卡片
struct WorkFavoriteCard: View {
    let work: Work
    @StateObject private var favoriteManager = UnifiedFavoriteManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 图片
            if let image = work.uiImage {
                let imageAspectRatio = image.size.width / image.size.height
                let cardWidth = UIScreen.main.bounds.width / 2 - 36
                
                let calculatedHeight: CGFloat = {
                    if imageAspectRatio > 1.3 {
                        return min(max(cardWidth / imageAspectRatio, 120), 180)
                    } else {
                        return min(cardWidth / imageAspectRatio, 220)
                    }
                }()
                
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: cardWidth, height: calculatedHeight)
                    .clipped()
                    .cornerRadius(12)
                    .overlay(
                        // 收藏标记
                        VStack {
                            HStack {
                                Spacer()
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.pink)
                                    .padding(8)
                                    .background(
                                        Circle()
                                            .fill(Color.black.opacity(0.5))
                                    )
                                    .padding(8)
                            }
                            Spacer()
                        }
                    )
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .cornerRadius(12)
            }
            
            // 标题和日期
            VStack(alignment: .leading, spacing: 4) {
                Text(work.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                Text(work.createdAt.formatted(date: .numeric, time: .omitted))
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 4)
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.pink.opacity(0.3), lineWidth: 1)
                )
        )
        .contextMenu {
            Button(role: .destructive) {
                favoriteManager.removeWorkFavorite(workId: work.id)
            } label: {
                Label("取消收藏", systemImage: "heart.slash")
            }
        }
    }
}

// MARK: - 空状态视图
struct EmptyFavoriteView: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(color.opacity(0.5))
            
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    FavoritesView()
}

