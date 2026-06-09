import SwiftUI

// MARK: - 作品展示页面
struct WorksView: View {
    @StateObject private var worksManager = WorksManager.shared
    @State private var selectedTab: WorkTab = .published
    @State private var searchText = ""
    @State private var selectedWork: Work?
    @State private var showingRenameAlert = false
    @State private var newTitle = ""
    
    enum WorkTab: String, CaseIterable {
        case published = "已发布"
        case drafts = "草稿"
        
        var icon: String {
            switch self {
            case .published: return "checkmark.circle.fill"
            case .drafts: return "doc.text"
            }
        }
    }
    
    var body: some View {
        ZStack {
            // 背景
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 标题
                Text("我的作品")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                    .padding(.bottom, 20)
                
                // 搜索框
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("搜索我的作品", text: $searchText)
                        .foregroundColor(.white)
                        .placeholder(when: searchText.isEmpty) {
                            Text("搜索我的作品")
                                .foregroundColor(.gray)
                        }
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // 标签切换
                HStack(spacing: 0) {
                    ForEach(WorkTab.allCases, id: \.self) { tab in
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                selectedTab = tab
                            }
                        }) {
                            VStack(spacing: 8) {
                                HStack(spacing: 6) {
                                    Image(systemName: tab.icon)
                                        .font(.system(size: 14))
                                    
                                    Text(tab.rawValue)
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(selectedTab == tab ? Color(red: 0, green: 1, blue: 0.5) : .gray)
                                
                                // 数量标签
                                Text("\(tab == .published ? worksManager.publishedCount : worksManager.draftCount)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                selectedTab == tab ?
                                    Color(red: 0, green: 1, blue: 0.5).opacity(0.1) : Color.clear
                            )
                        }
                    }
                }
                .background(Color.white.opacity(0.05))
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // 作品网格
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(filteredWorks) { work in
                            WorkCard(work: work)
                                .onTapGesture {
                                    selectedWork = work
                                }
                                .onLongPressGesture {
                                    selectedWork = work
                                    newTitle = work.title
                                    showingRenameAlert = true
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .sheet(item: $selectedWork) { work in
            WorkDetailView(work: work)
        }
        .alert("重命名作品", isPresented: $showingRenameAlert) {
            TextField("新标题", text: $newTitle)
            Button("取消", role: .cancel) {}
            Button("确定") {
                if let work = selectedWork {
                    worksManager.renameWork(work, newTitle: newTitle)
                }
            }
        }
    }
    
    // 过滤后的作品列表
    private var filteredWorks: [Work] {
        let works = selectedTab == .published ? worksManager.published : worksManager.drafts
        
        if searchText.isEmpty {
            return works
        } else {
            return works.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

// MARK: - 作品卡片
struct WorkCard: View {
    let work: Work
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 图片 - 智能适配宽高比（支持横屏、竖屏、正方形）
            if let image = work.uiImage {
                let imageAspectRatio = image.size.width / image.size.height
                let cardWidth = UIScreen.main.bounds.width / 2 - 36 // 考虑padding和spacing
                
                // 根据宽高比智能计算高度
                let calculatedHeight: CGFloat = {
                    if imageAspectRatio > 1.5 {
                        // 横屏图片（宽度明显大于高度）
                        return min(max(cardWidth / imageAspectRatio, 100), 160)
                    } else if imageAspectRatio < 0.75 {
                        // 竖屏图片（高度明显大于宽度）
                        // 限制最大高度，避免卡片过高
                        return min(cardWidth / imageAspectRatio, 280)
                    } else {
                        // 正方形或接近正方形
                        return min(cardWidth / imageAspectRatio, 200)
                    }
                }()
                
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: cardWidth, height: calculatedHeight)
                    .clipped()
                    .cornerRadius(12)
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
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

// MARK: - 作品详情页
struct WorkDetailView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var worksManager = WorksManager.shared
    @StateObject private var favoriteManager = UnifiedFavoriteManager.shared
    let work: Work
    
    @State private var showingDeleteAlert = false
    @State private var showingShareSheet = false
    @State private var showingRenameAlert = false
    @State private var newTitle = ""
    @State private var isFavorited = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部栏
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text(work.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // 收藏按钮
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isFavorited.toggle()
                        }
                        if isFavorited {
                            favoriteManager.addWorkFavorite(work)
                        } else {
                            favoriteManager.removeWorkFavorite(workId: work.id)
                        }
                    }) {
                        Image(systemName: isFavorited ? "heart.fill" : "heart")
                            .font(.system(size: 20))
                            .foregroundColor(isFavorited ? .pink : .white)
                            .frame(width: 44, height: 44)
                    }
                    
                    Menu {
                        Button {
                            newTitle = work.title
                            showingRenameAlert = true
                        } label: {
                            Label("重命名", systemImage: "pencil")
                        }
                        
                        if work.isPublished {
                            Button {
                                worksManager.unpublishWork(work)
                                dismiss()
                            } label: {
                                Label("转为草稿", systemImage: "arrow.uturn.backward")
                            }
                        } else {
                            Button {
                                worksManager.publishWork(work)
                                dismiss()
                            } label: {
                                Label("发布作品", systemImage: "paperplane.fill")
                            }
                        }
                        
                        Button {
                            showingShareSheet = true
                        } label: {
                            Label("分享", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                // 图片
                ScrollView {
                    VStack(spacing: 20) {
                        if let image = work.uiImage {
                            // 智能计算图片显示尺寸（横屏优化）
                            let imageAspectRatio = image.size.width / image.size.height
                            let screenWidth = UIScreen.main.bounds.width - 40 // 减去padding
                            let screenHeight = UIScreen.main.bounds.height * 0.7 // 最大显示高度
                            
                            // 根据宽高比智能调整
                            let displayHeight: CGFloat = {
                                if imageAspectRatio > 1.2 {
                                    // 横屏图片：优先保证宽度充满
                                    return min(screenWidth / imageAspectRatio, screenHeight)
                                } else {
                                    // 竖屏或正方形图片：限制高度
                                    return min(screenWidth / imageAspectRatio, screenHeight)
                                }
                            }()
                            
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: screenWidth, height: displayHeight)
                                .cornerRadius(16)
                                .shadow(color: Color(red: 0, green: 1, blue: 0.6).opacity(0.2), radius: 10)
                                .padding(.horizontal, 20)
                                .padding(.top, 20)
                        }
                        
                        // 信息卡片
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(Color(red: 0, green: 1, blue: 0.5))
                                Text("创作于: \(work.createdAt.formatted(date: .long, time: .shortened))")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                            }
                            
                            if !work.usedMaterials.isEmpty {
                                Divider()
                                    .background(Color.white.opacity(0.2))
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "square.stack.3d.up.fill")
                                            .foregroundColor(Color(red: 0, green: 1, blue: 0.5))
                                        Text("所用素材")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                    
                                    ForEach(work.usedMaterials, id: \.self) { material in
                                        Text("• \(material)")
                                            .font(.system(size: 13))
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
                
                // 底部按钮
                if !work.isPublished {
                    Button(action: {
                        worksManager.publishWork(work)
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "paperplane.fill")
                            Text("发布作品")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0, green: 1, blue: 0.5), Color(red: 0, green: 0.8, blue: 0.4)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .alert("删除作品", isPresented: $showingDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("删除", role: .destructive) {
                worksManager.deleteWork(work)
                dismiss()
            }
        } message: {
            Text("确定要删除这个作品吗？此操作无法撤销。")
        }
        .alert("重命名作品", isPresented: $showingRenameAlert) {
            TextField("新标题", text: $newTitle)
            Button("取消", role: .cancel) {}
            Button("确定") {
                worksManager.renameWork(work, newTitle: newTitle)
            }
        } message: {
            Text("请输入新的作品名称")
        }
        .sheet(isPresented: $showingShareSheet) {
            if let image = work.uiImage {
                ShareSheet(items: [image])
            }
        }
        .onAppear {
            // 加载收藏状态
            isFavorited = favoriteManager.isWorkFavorited(workId: work.id)
        }
    }
}

// MARK: - 分享面板
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - TextField Placeholder 扩展
extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

#Preview {
    WorksView()
}
