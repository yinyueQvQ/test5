//
//  CreateView.swift
//  test5
//
//  创作页 - 直接内嵌工作流，不用模态
//

import SwiftUI
import UIKit

struct CreateView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var draftManager: DraftManager
    
    @StateObject private var permissionManager = PermissionManager()
    @StateObject private var segmentationManager = ImageSegmentationManager()
    @StateObject private var styleTransferManager = StyleTransferManager()
    @StateObject private var inventoryManager = InventoryManager()
    @StateObject private var compositionManager = CompositionManager.shared  // 使用单例
    @StateObject private var backpackManager = BackpackManager.shared
    @StateObject private var worksManager = WorksManager.shared
    
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var showingBackpack = false
    @State private var currentStep: WorkflowStep = .selectSource
    @State private var showingNameAlert = false
    @State private var workTitle = ""
    
    enum WorkflowStep {
        case selectSource      // 选择来源
        case segmentation      // 分割中
        case regionSelection   // 选择区域
        case styleTransfer     // 风格迁移
        case composition       // 合成
        case result            // 完成
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部导航
                HStack {
                    Button(action: {
                        if currentStep == .selectSource {
                            dismiss()
                        } else {
                            // 返回选择来源
                            currentStep = .selectSource
                            
                            // 清除所有状态
                            segmentationManager.reset()
                            styleTransferManager.transferredImage = nil
                            inventoryManager.clearAll()  // 清除背包素材
                            compositionManager.clearSelection()
                            compositionManager.composedResult = nil
                            compositionManager.errorMessage = nil
                            compositionManager.prompt = ""
                            compositionManager.selectedCraftStyle = nil
                        }
                    }) {
                        Image(systemName: currentStep == .selectSource ? "xmark" : "chevron.left")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                    
                    Spacer()
                    
                    Text(currentStep == .selectSource ? "✨创作✨" : currentStep.title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
//                    Button(action: {
//                        if let result = compositionManager.composedResult {
//                            draftManager.saveDraft(title: "未命名作品", image: result)
//                            dismiss()
//                        }
//                    }) {
//                        Text("保存")
//                            .foregroundColor(compositionManager.composedResult != nil ? .green : .gray)
//                    }
//                    .disabled(compositionManager.composedResult == nil)
//                    .frame(width: 60)
                }
                .padding()
                .background(Color.black)
                
                // 内容区
                ScrollView {
                    VStack(spacing: 20) {
                        switch currentStep {
                        case .selectSource:
                            SelectSourceView()
                        case .segmentation:
                            SegmentationView()
                        case .regionSelection:
                            RegionSelectionView()
                        case .styleTransfer:
                            StyleTransferView()
                        case .composition:
                            CompositionView()
                        case .result:
                            ResultView()
                        }
                    }
                    .padding()
                }
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerView(selectedImage: Binding(
                get: { segmentationManager.originalImage },
                set: { image in
                    if let img = image {
                        segmentationManager.originalImage = img
                        currentStep = .segmentation
                        segmentationManager.segmentImage(img)
                    }
                }
            ), sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showingCamera) {
            ImagePickerView(selectedImage: Binding(
                get: { segmentationManager.originalImage },
                set: { image in
                    if let img = image {
                        segmentationManager.originalImage = img
                        currentStep = .segmentation
                        segmentationManager.segmentImage(img)
                    }
                }
            ), sourceType: .camera)
        }
        .sheet(isPresented: $showingBackpack) {
            BackpackView()
        }
        .onAppear {
            styleTransferManager.inventoryManager = inventoryManager
        }
    }
    
    // MARK: - 选择来源
    
    @ViewBuilder
    private func SelectSourceView() -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            // 中心图标
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0, green: 1, blue: 0.6).opacity(0.2))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 60))
                        .foregroundColor(Color(red: 0, green: 1, blue: 0.6))
                }
                
                Text("选择图片")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // 底部按钮组
            VStack(spacing: 16) {
                // 相册按钮
                Button(action: {
                    Task {
                        let hasPermission = await permissionManager.requestPhotoLibraryPermission()
                        if hasPermission {
                            showingImagePicker = true
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "photo.on.rectangle")
                            .font(.system(size: 24))
                        Text("相册选择图片")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(red: 0, green: 1, blue: 0.6))
                    .cornerRadius(16)
                }
                
                // 相机按钮
                Button(action: {
                    Task {
                        let hasPermission = await permissionManager.requestCameraPermission()
                        if hasPermission {
                            showingCamera = true
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 24))
                        Text("拍摄新照片")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(16)
                }
                
                // 查看背包按钮（移到前面）
                Button(action: {
                    showingBackpack = true
                }) {
                    HStack {
                        Image(systemName: "backpack.fill")
                            .font(.system(size: 24))
                        Text("查看背包")
                            .font(.system(size: 18, weight: .semibold))
                        
                        if !backpackManager.items.isEmpty {
                            Text("(\(backpackManager.items.count))")
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(red: 0, green: 1, blue: 0.6).opacity(0.5), lineWidth: 1)
                    )
                    .cornerRadius(16)
                }
                
                // 进入工作台按钮（移到后面）
                Button(action: {
                    showingImagePicker = false
                    showingCamera = false
                    currentStep = .composition
                }) {
                    HStack {
                        Image(systemName: "square.grid.3x3.fill")
                            .font(.system(size: 24))
                        Text("进入工作台")
                            .font(.system(size: 18, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.orange, Color.red]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
                
                // 分割线
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - 分割视图
    
    @ViewBuilder
    private func SegmentationView() -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            // 图片显示区域
            if let originalImage = segmentationManager.originalImage {
                ZStack {
                    Image(uiImage: originalImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: UIScreen.main.bounds.width - 40)
                        .cornerRadius(20)
                    
                    // 如果有分割结果，显示分割结果
                    if let segmentationResult = segmentationManager.segmentationResult, !segmentationManager.isLoading {
                        Image(uiImage: segmentationResult)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: UIScreen.main.bounds.width - 40)
                            .cornerRadius(20)
                            .opacity(0.7)
                    }
                }
            }
            
            Spacer()
            
            // 底部区域
            VStack(spacing: 16) {
                if segmentationManager.isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(Color(red: 0, green: 1, blue: 0.6))
                        Text("AI正在智能识别...")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .frame(height: 100)
                } else if !segmentationManager.segmentedRegions.isEmpty {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(red: 0, green: 1, blue: 0.6))
                            Text("识别完成，找到 \(segmentationManager.segmentedRegions.count) 个区域")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        }
                        
                        // 大的绿色确认按钮
                        Button(action: {
                            currentStep = .regionSelection
                        }) {
                            HStack {
                                Image(systemName: "arrow.right")
                                Text("选择区域")
                            }
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(red: 0, green: 1, blue: 0.6))
                            .cornerRadius(16)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - 区域选择
    
    @ViewBuilder
    private func RegionSelectionView() -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            // 图片显示区域（带绿色虚线边框效果）
            ZStack {
                if let highlightedResult = segmentationManager.highlightedSegmentationResult {
                    Image(uiImage: highlightedResult)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: UIScreen.main.bounds.width - 40)
                        .cornerRadius(20)
                } else if let segmentationResult = segmentationManager.segmentationResult {
                    Image(uiImage: segmentationResult)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: UIScreen.main.bounds.width - 40)
                        .cornerRadius(20)
                }
                
                // 绿色虚线边框（如果有选中区域）
                if !segmentationManager.selectedRegions.isEmpty {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(style: StrokeStyle(lineWidth: 3, dash: [10, 5]))
                        .foregroundColor(Color(red: 0, green: 1, blue: 0.6))
                        .frame(maxWidth: UIScreen.main.bounds.width - 40)
                        .aspectRatio(1, contentMode: .fit)
                }
            }
            
            Spacer()
            
            // 底部控制区
            VStack(spacing: 16) {
                // 选中区域预览（如果有）
                if !segmentationManager.selectedRegions.isEmpty,
                   let extractedImage = segmentationManager.extractSelectedRegions() {
                    VStack(spacing: 12) {
                        Text("选中区域预览")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Image(uiImage: extractedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 120)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 0, green: 1, blue: 0.6), lineWidth: 2)
                            )
                    }
                    .padding(.horizontal, 24)
                }
                
                // 区域选择网格
                if !segmentationManager.segmentedRegions.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(segmentationManager.segmentedRegions.prefix(6), id: \.id) { region in
                                Button(action: {
                                    if segmentationManager.selectedRegions.contains(region.id) {
                                        segmentationManager.selectedRegions.remove(region.id)
                                    } else {
                                        segmentationManager.selectedRegions.insert(region.id)
                                    }
                                }) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(uiColor: region.color))
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(
                                                    segmentationManager.selectedRegions.contains(region.id) 
                                                    ? Color(red: 0, green: 1, blue: 0.6) 
                                                    : Color.gray,
                                                    lineWidth: segmentationManager.selectedRegions.contains(region.id) ? 3 : 1
                                                )
                                        )
                                        .overlay(
                                            Group {
                                                if segmentationManager.selectedRegions.contains(region.id) {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .font(.system(size: 20))
                                                        .foregroundColor(Color(red: 0, green: 1, blue: 0.6))
                                                }
                                            }
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
                
                // 确认提取按钮
                Button(action: {
                    currentStep = .styleTransfer
                }) {
                    HStack {
                        Image(systemName: "arrow.right")
                        Text("确认提取")
                    }
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(red: 0, green: 1, blue: 0.6))
                    .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                .disabled(segmentationManager.selectedRegions.isEmpty)
                .opacity(segmentationManager.selectedRegions.isEmpty ? 0.5 : 1)
            }
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - 风格迁移
    
    @ViewBuilder
    private func StyleTransferView() -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            // 图片显示区域
            ZStack {
                if let transferredImage = styleTransferManager.transferredImage {
                    Image(uiImage: transferredImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: UIScreen.main.bounds.width - 40)
                        .cornerRadius(20)
                } else if let extractedImage = segmentationManager.extractSelectedRegions() {
                    Image(uiImage: extractedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: UIScreen.main.bounds.width - 40)
                        .cornerRadius(20)
                }
            }
            
            Spacer()
            
            // 底部控制区
            VStack(spacing: 16) {
                if styleTransferManager.isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(Color(red: 0, green: 1, blue: 0.6))
                        Text("AI正在风格转换...")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .frame(height: 100)
                } else if styleTransferManager.transferredImage != nil {
                    // 转换完成
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(red: 0, green: 1, blue: 0.6))
                            Text("风格迁移完成，已保存到素材库")
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            currentStep = .composition
                        }) {
                            HStack {
                                Image(systemName: "arrow.right")
                                Text("进入合成台")
                            }
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color(red: 0, green: 1, blue: 0.6))
                            .cornerRadius(16)
                        }
                    }
                } else {
                    // 开始转换按钮
                    Button(action: {
                        if let extractedImage = segmentationManager.extractSelectedRegions() {
                            styleTransferManager.transferStyle(for: extractedImage)
                        }
                    }) {
                        HStack {
                            Image(systemName: "wand.and.stars")
                            Text("应用动漫风格")
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color(red: 0, green: 1, blue: 0.6))
                        .cornerRadius(16)
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 30)
        }
    }
    
    // MARK: - 合成台
    
    @ViewBuilder
    private func CompositionView() -> some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 24) {
                    // 顶部间距
                    Color.clear.frame(height: 20)
                    
                    // 1. 画布区域（素材摆放）
                    ZStack {
                        // 背景框
                        RoundedRectangle(cornerRadius: 24)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.05, green: 0.15, blue: 0.15),
                                        Color(red: 0.02, green: 0.08, blue: 0.08)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .frame(height: 400)
                        
                        // 素材摆放区
                        if compositionManager.selectedMaterials.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "photo.stack")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                Text("点击下方素材添加到画布")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                            }
                        } else {
                            // 已选素材展示（自由摆放效果）
                            GeometryReader { geometry in
                                ForEach(Array(compositionManager.selectedMaterials.enumerated()), id: \.element.id) { index, item in
                                    if let image = item.image {
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 140, height: 140)
                                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 20)
                                                        .stroke(Color(red: 0, green: 1, blue: 0.6), lineWidth: 3)
                                                )
                                                .shadow(color: Color(red: 0, green: 1, blue: 0.6).opacity(0.3), radius: 10)
                                            
                            // 删除按钮
                            Button(action: {
                                compositionManager.removeSelectedMaterial(item)
                            }) {
                                Circle()
                                    .fill(Color.black.opacity(0.8))
                                    .frame(width: 32, height: 32)
                                    .overlay(
                                        Image(systemName: "xmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(.white)
                                    )
                            }
                            .offset(x: 6, y: -6)
                                        }
                                        .position(
                                            x: geometry.size.width * [0.25, 0.65, 0.45, 0.35, 0.75][index % 5],
                                            y: geometry.size.height * [0.3, 0.35, 0.65, 0.5, 0.7][index % 5]
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // 2. 素材栏（从底部移上来）
                    if !backpackManager.items.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("素材选择")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Text("已选 \(compositionManager.selectedMaterials.count)/\(compositionManager.maxMaterialsCount)")
                                    .font(.system(size: 13))
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(backpackManager.items.prefix(20)) { backpackItem in
                                        Button(action: {
                                            compositionManager.toggleMaterialFromBackpack(backpackItem)
                                        }) {
                                            ZStack {
                                                if let image = backpackItem.uiImage {
                                                    Image(uiImage: image)
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fill)
                                                        .frame(width: 80, height: 80)
                                                        .clipped()
                                                        .cornerRadius(16)
                                                }
                                                
                                                // 选中状态
                                                if compositionManager.isBackpackItemSelected(backpackItem) {
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .stroke(Color(red: 0, green: 1, blue: 0.6), lineWidth: 3)
                                                        .frame(width: 80, height: 80)
                                                    
                                                    // 选中标记
                                                    VStack {
                                                        HStack {
                                                            Spacer()
                                                            Circle()
                                                                .fill(Color(red: 0, green: 1, blue: 0.6))
                                                                .frame(width: 24, height: 24)
                                                                .overlay(
                                                                    Image(systemName: "checkmark")
                                                                        .font(.system(size: 12, weight: .bold))
                                                                        .foregroundColor(.black)
                                                                )
                                                        }
                                                        Spacer()
                                                    }
                                                    .frame(width: 80, height: 80)
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.vertical, 16)
                        .background(Color.clear)
                    }
                    
                    // 3. 工艺选择
                    VStack(alignment: .leading, spacing: 16) {
                        Text("工艺选择")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                            ForEach(CraftStyle.allCases) { craft in
                                CraftStyleCompactCard(
                                    style: craft,
                                    isSelected: compositionManager.selectedCraftStyle == craft,
                                    onTap: {
                                        compositionManager.selectedCraftStyle = craft
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // 4. 提示词输入（可选）
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("创意提示词")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("(可选)")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 20)
                        
                        // 提示词输入框
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("", text: $compositionManager.prompt, prompt: Text("描述你想要生成的效果...").foregroundColor(.gray.opacity(0.5)))
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.1))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                            
                            // 提示
                            Text("💡 提示：留空则使用默认提示词，或输入你的创意描述")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 12)
                    
                    // 合成结果 - 精美的卡片展示
                    if let result = compositionManager.composedResult {
                        VStack(spacing: 20) {
                            // 生成成功提示
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(red: 0, green: 1, blue: 0.6))
                                Text("合成完成！")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            // 图片展示（卡片样式）
                            ZStack {
                                RoundedRectangle(cornerRadius: 24)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.1, green: 0.2, blue: 0.15),
                                                Color(red: 0.05, green: 0.1, blue: 0.08)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24)
                                            .stroke(Color(red: 0, green: 1, blue: 0.6).opacity(0.3), lineWidth: 2)
                                    )
                                    .shadow(color: Color(red: 0, green: 1, blue: 0.6).opacity(0.3), radius: 20)
                                
                                Image(uiImage: result)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(20)
                                    .padding(12)
                            }
                            .padding(.horizontal, 20)
                            .transition(.scale.combined(with: .opacity))
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: result)
                            
                            // 操作按钮
                            HStack(spacing: 12) {
                                Button(action: {
                                    compositionManager.composedResult = nil
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.counterclockwise")
                                        Text("重新合成")
                                    }
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                                    .cornerRadius(14)
                                }
                                
                                Button(action: {
                                    currentStep = .result
                                }) {
                                    HStack {
                                        Image(systemName: "checkmark")
                                        Text("完成")
                                    }
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                                    .background(
                                        LinearGradient(
                                            colors: [Color(red: 0, green: 1, blue: 0.6), Color(red: 0, green: 0.8, blue: 0.5)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(14)
                                    .shadow(color: Color(red: 0, green: 1, blue: 0.6).opacity(0.4), radius: 10)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.vertical, 20)
                    }
                    
                    // 底部间距（为按钮留空间）
                    Color.clear.frame(height: 140)
                }
            }
            
            // 底部固定按钮区
            VStack(spacing: 0) {
                // 开始合成按钮
                if !compositionManager.isProcessing && compositionManager.composedResult == nil {
                    Button(action: {
                        compositionManager.composeWithStableDiffusion()
                        // 立即跳转到结果页查看生成进度
                        currentStep = .result
                    }) {
                        Text("开始合成")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                compositionManager.selectedMaterials.isEmpty
                                ? Color.gray
                                : Color(red: 0, green: 1, blue: 0.6)
                            )
                            .cornerRadius(16)
                    }
                    .disabled(compositionManager.selectedMaterials.isEmpty)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0),
                        Color.black
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
    
    // MARK: - 完成（图7风格）
    
    @ViewBuilder
    private func ResultView() -> some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 顶部标题
                Text("AI生成结果")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                
                // 图片展示区
                if compositionManager.isProcessing {
                    // 正在生成
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .stroke(Color(red: 0, green: 1, blue: 0.6).opacity(0.2), lineWidth: 8)
                                .frame(width: 120, height: 120)
                            
                            Circle()
                                .trim(from: 0.0, to: 0.7)
                                .stroke(Color(red: 0, green: 1, blue: 0.6), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                                .frame(width: 120, height: 120)
                                .rotationEffect(.degrees(-90))
                                .animation(
                                    Animation.linear(duration: 2.0)
                                        .repeatForever(autoreverses: false),
                                    value: true
                                )
                            
                            Image(systemName: "wand.and.stars")
                                .font(.system(size: 50))
                                .foregroundColor(Color(red: 0, green: 1, blue: 0.6))
                        }
                        
                        VStack(spacing: 12) {
                            Text("AI正在生成中...")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("这可能需要几分钟时间")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                            
                            Text("请保持网络连接")
                                .font(.system(size: 13))
                                .foregroundColor(.gray.opacity(0.7))
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                } else if let result = compositionManager.composedResult {
                    // 生成完成，显示结果
                    ScrollView {
                        VStack(spacing: 20) {
                            // 主图
                            Image(uiImage: result)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(20)
                                .shadow(color: Color(red: 0, green: 1, blue: 0.5).opacity(0.3), radius: 20)
                                .padding(.horizontal, 20)
                            
                            Spacer().frame(height: 180)
                        }
                    }
                } else {
                    // 未生成或错误
                    VStack(spacing: 16) {
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("暂无结果")
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                Spacer()
                
                // 底部按钮区
                VStack(spacing: 12) {
                    // 保存作品按钮（荧光绿）
                    Button(action: {
                        if compositionManager.composedResult != nil {
                            // 显示命名对话框
                            workTitle = ""
                            showingNameAlert = true
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "arrow.down.doc.fill")
                                .font(.system(size: 20))
                            Text("保存作品")
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
                    
                    // 底部操作按钮组
                    HStack(spacing: 12) {
                        // 重新编辑
                        Button(action: {
                            currentStep = .composition
                            compositionManager.composedResult = nil
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.counterclockwise")
                                Text("重新编辑")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .cornerRadius(12)
                        }
                        
                        // 分享
                        Button(action: {
                            // TODO: 实现分享功能
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                Text("分享")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .alert("作品命名", isPresented: $showingNameAlert) {
            TextField("请输入作品名称", text: $workTitle)
            Button("取消", role: .cancel) {}
            Button("保存") {
                if let result = compositionManager.composedResult {
                    let materialNames = compositionManager.selectedMaterials.map { $0.name }
                    worksManager.saveWork(
                        title: workTitle.isEmpty ? "未命名作品" : workTitle,
                        image: result,
                        usedMaterials: materialNames
                    )
                    
                    // 清除合成状态
                    compositionManager.clearSelection()
                    compositionManager.composedResult = nil
                    
                    // 返回主页
                    dismiss()
                }
            }
        } message: {
            Text("给你的作品起个名字吧")
        }
    }
}

extension CreateView.WorkflowStep {
    var title: String {
        switch self {
        case .selectSource: return "选择来源"
        case .segmentation: return "智能分割"
        case .regionSelection: return "选择区域"
        case .styleTransfer: return "风格迁移"
        case .composition: return "合成台"
        case .result: return "完成"
        }
    }
}

// MARK: - 紧凑型工艺卡片（合成台用）
struct CraftStyleCompactCard: View {
    let style: CraftStyle
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // 图标
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconBackgroundColor)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: style.icon)
                        .font(.system(size: 20))
                        .foregroundColor(.white)
                }
                
                // 标题
                Text(style.rawValue)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                
                // 描述
                Text(description)
                    .font(.system(size: 11))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color(red: 0, green: 1, blue: 0.6) : Color.white.opacity(0.1),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var iconBackgroundColor: Color {
        switch style {
        case .realistic: return Color.green.opacity(0.3)
        case .cartoon: return Color.cyan.opacity(0.3)
        case .oilPainting: return Color.purple.opacity(0.3)
        case .sketch: return Color.yellow.opacity(0.3)
        case .watercolor: return Color.blue.opacity(0.3)
        case .cyberpunk: return Color.orange.opacity(0.3)
        }
    }
    
    private var description: String {
        switch style {
        case .realistic: return "控制切割精度与边缘处理"
        case .cartoon: return "调节表面光滑度与光泽"
        case .oilPainting: return "添加细节纹理与图案"
        case .sketch: return "控制材料融合与连接"
        case .watercolor: return "渲染最终效果"
        case .cyberpunk: return "高科技未来风格"
        }
    }
}

// MARK: - 工艺卡片视图
struct CraftStyleCardView: View {
    let style: CraftStyle
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // 图标
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconBackgroundColor)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: style.icon)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                
                // 标题
                Text(style.rawValue)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                
                // 描述
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? Color(red: 0, green: 1, blue: 0.6) : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
    }
    
    private var iconBackgroundColor: Color {
        switch style {
        case .realistic: return Color.green.opacity(0.3)
        case .cartoon: return Color.cyan.opacity(0.3)
        case .oilPainting: return Color.purple.opacity(0.3)
        case .sketch: return Color.yellow.opacity(0.3)
        case .watercolor: return Color.blue.opacity(0.3)
        case .cyberpunk: return Color.orange.opacity(0.3)
        }
    }
    
    private var description: String {
        switch style {
        case .realistic: return "真实摄影风格，还原细节"
        case .cartoon: return "卡通动漫风格，夸张有趣"
        case .oilPainting: return "油画质感，艺术气息"
        case .sketch: return "素描线条，简约经典"
        case .watercolor: return "水彩渲染，柔和梦幻"
        case .cyberpunk: return "高科技未来，霓虹赛博"
        }
    }
}
