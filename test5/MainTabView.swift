//
//  MainTabView.swift
//  test5
//
//  主页Tab导航系统
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var draftManager = DraftManager()
    @StateObject private var compositionManager = CompositionManager.shared
    @State private var selectedTab = 0
    @State private var showCompletionAlert = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // 主内容区域 - 不使用 TabView，手动切换视图
            Group {
                switch selectedTab {
                case 0:
                    HomeView()
                        .environmentObject(draftManager)
                case 1:
                    WorksView()
                        .environmentObject(draftManager)
                case 3:
                    MaterialView()
                        .environmentObject(draftManager)
                case 4:
                    SettingsView()
                default:
                    HomeView()
                        .environmentObject(draftManager)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 合成进度横幅（在TabBar上方）
            if compositionManager.isProcessing {
                CompositionProgressBanner()
                    .environmentObject(compositionManager)
                    .environmentObject(draftManager)
                    .offset(y: -90)  // 在TabBar上方
            }
            
            // 自定义底部导航栏
            CustomTabBar(selectedTab: $selectedTab)
                .environmentObject(draftManager)
        }
        .ignoresSafeArea(.keyboard)
        .onChange(of: compositionManager.isProcessing) { isProcessing in
            // 合成完成时的处理
            if !isProcessing && compositionManager.composedResult != nil {
                showCompletionAlert = true
            }
        }
        .sheet(isPresented: $showCompletionAlert) {
            if let result = compositionManager.composedResult {
                CompositionResultView(image: result)
                    .environmentObject(compositionManager)
            }
        }
    }
}

// 自定义底部导航栏
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @State private var showingCreateSheet = false
    @EnvironmentObject var draftManager: DraftManager
    
    var body: some View {
        ZStack {
            // 背景框
            RoundedRectangle(cornerRadius: 0)
                .fill(Color(white: 0.1))
                .frame(height: 90)
                .shadow(color: .black.opacity(0.3), radius: 10, y: -5)
            
            // 按钮区域
            HStack(spacing: 0) {
                // Tab 1: 首页
                TabBarButton(
                    icon: "house.fill",
                    title: "首页",
                    isSelected: selectedTab == 0,
                    color: .green
                ) {
                    selectedTab = 0
                }
                
                // Tab 2: 作品
                TabBarButton(
                    icon: "photo.fill",
                    title: "作品",
                    isSelected: selectedTab == 1,
                    color: .green
                ) {
                    selectedTab = 1
                }
                
                // 中间创作按钮（特殊样式）
                Button(action: {
                    showingCreateSheet = true
                }) {
                    ZStack {
                        // 使用椭圆形，稍微扁平化
                        Ellipse()
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.green, Color.mint]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                            .scaleEffect(x: 1.0, y: 0.92) // 垂直方向稍微压扁
                            .shadow(color: .green.opacity(0.5), radius: 10, y: 3)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 26, weight: .semibold))
                            .foregroundColor(.black)
                    }
                }
                .offset(y: -8) // 从-15改为-8，减少向上突出的高度
                .frame(maxWidth: .infinity)
                
                // Tab 3: 资料
                TabBarButton(
                    icon: "person.fill",
                    title: "资料",
                    isSelected: selectedTab == 3,
                    color: .green
                ) {
                    selectedTab = 3
                }
                
                // Tab 4: 设置
                TabBarButton(
                    icon: "gearshape.fill",
                    title: "设置",
                    isSelected: selectedTab == 4,
                    color: .green
                ) {
                    selectedTab = 4
                }
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 8)
        }
        .frame(height: 90)  // 固定高度
        .offset(y: 45)  // 向下偏移30，让按钮更靠近底部
        .sheet(isPresented: $showingCreateSheet) {
            CreateView()
                .environmentObject(draftManager)
        }
    }
}

// Tab按钮组件
struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? color : .gray)
                
                Text(title)
                    .font(.system(size: 11))
                    .foregroundColor(isSelected ? color : .gray)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 合成进度横幅
struct CompositionProgressBanner: View {
    @EnvironmentObject var compositionManager: CompositionManager
    @EnvironmentObject var draftManager: DraftManager
    @State private var isExpanded = true
    @State private var showingCompositionView = false
    
    var body: some View {
        VStack(spacing: 0) {
            if isExpanded {
                // 详细进度视图
                VStack(spacing: 12) {
                    HStack {
                        // 旋转的加载图标
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0, green: 1, blue: 0.5)))
                            .scaleEffect(0.8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("正在合成中...")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Text("点击查看详情")
                                .font(.system(size: 12))
                                .foregroundColor(Color(red: 0, green: 1, blue: 0.5))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3)) {
                                isExpanded.toggle()
                            }
                        }) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [Color(red: 0, green: 1, blue: 0.5).opacity(0.5), Color.clear],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .padding(.horizontal, 16)
                .contentShape(Rectangle())
                .onTapGesture {
                    showingCompositionView = true
                }
            } else {
                // 收起状态：只显示一个小圆点
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color(red: 0, green: 1, blue: 0.5))
                        .frame(width: 8, height: 8)
                    
                    Text("合成中")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("点击查看")
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                )
                .padding(.horizontal, 16)
                .contentShape(Rectangle())
                .onTapGesture {
                    showingCompositionView = true
                }
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .sheet(isPresented: $showingCompositionView) {
            CompositionProgressDetailView()
                .environmentObject(compositionManager)
        }
    }
}

// MARK: - 合成进度详情页面
struct CompositionProgressDetailView: View {
    @EnvironmentObject var compositionManager: CompositionManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // 顶部栏
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text("合成中")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                Spacer()
                
                // 加载动画
                VStack(spacing: 20) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0, green: 1, blue: 0.5)))
                        .scaleEffect(2.0)
                    
                    Text("正在生成中...")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("AI正在为你创作精美作品")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // 选中的素材列表
                VStack(alignment: .leading, spacing: 16) {
                    Text("使用素材")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(compositionManager.selectedMaterials) { material in
                                VStack(spacing: 8) {
                                    if let image = material.image {
                                        Image(uiImage: image)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 80, height: 80)
                                            .clipped()
                                            .cornerRadius(12)
                                    }
                                    
                                    Text(material.name)
                                        .font(.system(size: 12))
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                        .frame(width: 80)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // 进度信息
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(Color(red: 0, green: 1, blue: 0.5))
                            Text("预计需要60秒左右")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        if let style = compositionManager.selectedCraftStyle {
                            HStack {
                                Image(systemName: "paintbrush.fill")
                                    .foregroundColor(Color(red: 0, green: 1, blue: 0.5))
                                Text("风格：\(style.rawValue)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.05))
                )
                .padding(.horizontal, 20)
                
                Spacer()
                
                // 提示信息
                Text("可以关闭此页面，合成会在后台继续")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .padding(.bottom, 40)
            }
        }
    }
}

// MARK: - 合成结果视图
struct CompositionResultView: View {
    let image: UIImage
    @EnvironmentObject var compositionManager: CompositionManager
    @Environment(\.dismiss) var dismiss
    @State private var showingSaveAlert = false
    @State private var workTitle = ""
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // 顶部栏
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text("合成完成 🎉")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                
                // 合成结果图片
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(16)
                    .shadow(color: Color(red: 0, green: 1, blue: 0.6).opacity(0.3), radius: 20)
                    .padding(.horizontal, 20)
                
                Spacer()
                
                // 底部按钮
                VStack(spacing: 12) {
                    // 保存到作品
                    Button(action: {
                        showingSaveAlert = true
                    }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down.fill")
                            Text("保存到我的作品")
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
                    
                    // 关闭
                    Button(action: { dismiss() }) {
                        Text("关闭")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .alert("保存作品", isPresented: $showingSaveAlert) {
            TextField("作品名称", text: $workTitle)
            Button("取消", role: .cancel) {}
            Button("保存") {
                saveWork()
            }
        } message: {
            Text("给你的作品起个名字吧")
        }
    }
    
    private func saveWork() {
        let title = workTitle.isEmpty ? "合成作品 \(Date().formatted(date: .numeric, time: .omitted))" : workTitle
        let materials = compositionManager.selectedMaterials.map { $0.name }
        
        WorksManager.shared.saveWork(
            title: title,
            image: image,
            usedMaterials: materials
        )
        
        compositionManager.reset()
        dismiss()
    }
}

#Preview {
    MainTabView()
}

