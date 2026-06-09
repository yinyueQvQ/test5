//
//  ContentView.swift
//  test5
//
//  Created by zhuojin li on 2025/10/15.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var segmentationManager = ImageSegmentationManager()
    @StateObject private var styleTransferManager = StyleTransferManager()
    @StateObject private var permissionManager = PermissionManager()
    @StateObject private var inventoryManager = InventoryManager()
    @StateObject private var compositionManager = CompositionManager.shared  // 使用单例
    
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @State private var showingCamera = false
    @State private var currentStep = ProcessStep.selectImage
    @State private var showingStyleTransfer = false
    
    enum ProcessStep: CaseIterable {
        case selectImage
        case segmentation
        case regionSelection
        case styleTransfer
        case result
        case inventory
        case composition
        case compositionResult
        
        var title: String {
            switch self {
            case .selectImage: return "选择图片"
            case .segmentation: return "图像分割"
            case .regionSelection: return "选择区域"
            case .styleTransfer: return "风格迁移"
            case .result: return "完成"
            case .inventory: return "背包"
            case .composition: return "合成台"
            case .compositionResult: return "合成结果"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 进度指示器
                StepIndicatorView(currentStep: currentStep)
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 主要内容区域
                        switch currentStep {
                        case .selectImage:
                            ImageSelectionView()
                        case .segmentation:
                            SegmentationView()
                        case .regionSelection:
                            RegionSelectionView()
                        case .styleTransfer:
                            StyleTransferView()
                        case .result:
                            ResultView()
                        case .inventory:
                            InventoryView()
                        case .composition:
                            CompositionView()
                        case .compositionResult:
                            CompositionResultView()
                        }
                    }
                    .padding(.horizontal)
                }
                
                // 底部操作按钮
                BottomActionButtons()
            }
            .navigationTitle("AI图像处理")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerView(selectedImage: $selectedImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showingCamera) {
            ImagePickerView(selectedImage: $selectedImage, sourceType: .camera)
        }
        .onChange(of: selectedImage) { image in
            if let image = image {
                currentStep = .segmentation
                segmentationManager.segmentImage(image)
            }
        }
        .onAppear {
            // 连接管理器
            styleTransferManager.inventoryManager = inventoryManager
        }
    }
    
    // MARK: - 子视图
    
    @ViewBuilder
    private func ImageSelectionView() -> some View {
        VStack(spacing: 24) {
            // 标题和描述
            VStack(spacing: 12) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 64))
                    .foregroundColor(.blue)
                
                Text("选择或拍摄图片")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("选择一张图片开始AI图像分割和风格迁移")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 32)
            
            // 选择按钮
            VStack(spacing: 16) {
                Button(action: {
                    Task {
                        let hasPermission = await permissionManager.requestPhotoLibraryPermission()
                        if hasPermission {
                            showingImagePicker = true
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "photo.fill")
                        Text("从相册选择")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                
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
                        Text("拍摄照片")
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // 分隔线
                Divider()
                    .padding(.vertical, 8)
                
                // 直接进入工作台
                Button(action: {
                    currentStep = .composition
                }) {
                    HStack {
                        Image(systemName: "square.grid.3x3.fill")
                        Text("进入工作台")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.orange, .red]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
    }
    
    @ViewBuilder
    private func SegmentationView() -> some View {
        VStack(spacing: 20) {
            Text("图像分割中...")
                .font(.title2)
                .fontWeight(.semibold)
            
            if let originalImage = segmentationManager.originalImage {
                VStack(spacing: 16) {
                    Text("原始图片")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(uiImage: originalImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                }
            }
            
            if segmentationManager.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("AI正在分析图像...")
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 32)
                } else if let segmentationResult = segmentationManager.segmentationResult {
                VStack(spacing: 16) {
                    Text("分割结果")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(uiImage: segmentationResult)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                    
                    Text("不同颜色代表不同的物体区域")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
        .onChange(of: segmentationManager.segmentedRegions) { _ in
            if !segmentationManager.segmentedRegions.isEmpty && !segmentationManager.isLoading {
                currentStep = .regionSelection
            }
        }
    }
    
    @ViewBuilder
    private func RegionSelectionView() -> some View {
        VStack(spacing: 20) {
            Text("选择需要的区域")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("点击下方区域卡片选择要保留的物体，选中的区域会在图像上高亮显示")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // 显示带高亮效果的分割结果
            if let highlightedResult = segmentationManager.highlightedSegmentationResult {
                Image(uiImage: highlightedResult)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 250)
                    .cornerRadius(12)
                    .shadow(radius: 4)
            } else if let segmentationResult = segmentationManager.segmentationResult {
                Image(uiImage: segmentationResult)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 250)
                    .cornerRadius(12)
                    .shadow(radius: 4)
            }
            
            // 区域选择列表
            if !segmentationManager.segmentedRegions.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("可选区域:")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                        ForEach(segmentationManager.segmentedRegions, id: \.id) { region in
                            RegionSelectionCard(
                                region: region,
                                isSelected: segmentationManager.selectedRegions.contains(region.id)
                            ) {
                                toggleRegionSelection(region.id)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.systemGray6))
                .cornerRadius(12)
            }
            
            // 预览选中区域
            if !segmentationManager.selectedRegions.isEmpty,
               let extractedImage = segmentationManager.extractSelectedRegions() {
                VStack(spacing: 12) {
                    Text("选中区域预览")
                        .font(.headline)
                    
                    Image(uiImage: extractedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 150)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
    }
    
    @ViewBuilder
    private func StyleTransferView() -> some View {
        VStack(spacing: 20) {
            Text("AI风格迁移")
                .font(.title2)
                .fontWeight(.semibold)
            
            if let extractedImage = segmentationManager.extractSelectedRegions() {
                VStack(spacing: 16) {
                    Text("原始选中区域")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(uiImage: extractedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                }
            }
            
            if styleTransferManager.isLoading {
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("正在进行动漫风格转换...")
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 32)
            } else if let transferredImage = styleTransferManager.transferredImage {
                VStack(spacing: 16) {
                    Text("动漫风格结果")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Image(uiImage: transferredImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
        .onChange(of: styleTransferManager.transferredImage) { image in
            if image != nil {
                currentStep = .result
            }
        }
    }
    
    @ViewBuilder
    private func ResultView() -> some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(.green)
                
                Text("处理完成!")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            
            if let transferredImage = styleTransferManager.transferredImage {
                VStack(spacing: 16) {
                    Text("最终结果")
                        .font(.headline)
                    
                    Image(uiImage: transferredImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 300)
                        .cornerRadius(12)
                        .shadow(radius: 8)
                }
            }
            
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    Button("保存图片") {
                        if let image = styleTransferManager.transferredImage {
                            permissionManager.savePhotoToLibrary(image)
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                    
                    Button("重新开始") {
                        resetAll()
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // 进入背包和合成台的按钮
                Button(action: {
                    currentStep = .inventory
                }) {
                    HStack {
                        Image(systemName: "bag.fill")
                        Text("进入背包 (\(inventoryManager.items.count)个素材)")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [.purple, .blue]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
    }
    
    @ViewBuilder
    private func BottomActionButtons() -> some View {
        HStack(spacing: 16) {
            if currentStep != .selectImage && currentStep != .result {
                Button("上一步") {
                    previousStep()
                }
                .font(.headline)
                .foregroundColor(.blue)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
            
            if currentStep == .regionSelection && !segmentationManager.selectedRegions.isEmpty {
                Button("开始风格迁移") {
                    if let extractedImage = segmentationManager.extractSelectedRegions() {
                        currentStep = .styleTransfer
                        styleTransferManager.transferStyle(for: extractedImage)
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.orange, .red]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - 辅助方法
    
    private func toggleRegionSelection(_ regionId: Int) {
        if segmentationManager.selectedRegions.contains(regionId) {
            segmentationManager.selectedRegions.remove(regionId)
        } else {
            segmentationManager.selectedRegions.insert(regionId)
        }
    }
    
    private func previousStep() {
        switch currentStep {
        case .segmentation:
            currentStep = .selectImage
        case .regionSelection:
            currentStep = .segmentation
        case .styleTransfer:
            currentStep = .regionSelection
        case .result:
            currentStep = .styleTransfer
        default:
            break
        }
    }
    
    private func resetAll() {
        selectedImage = nil as UIImage?
        segmentationManager.segmentationResult = nil
        segmentationManager.originalImage = nil
        segmentationManager.segmentedRegions = []
        segmentationManager.selectedRegions = []
        styleTransferManager.transferredImage = nil
        currentStep = .selectImage
    }
    
    // MARK: - 背包视图
    
    @ViewBuilder
    private func InventoryView() -> some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("素材背包")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("风格迁移后的素材会自动保存到这里")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                Button(action: {
                    currentStep = .composition
                }) {
                    HStack {
                        Image(systemName: "square.grid.3x3.fill")
                        Text("合成台")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.orange)
                    .cornerRadius(8)
                }
            }
            
            if inventoryManager.items.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "bag")
                        .font(.system(size: 64))
                        .foregroundColor(.gray)
                    Text("背包空空如也")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("完成风格迁移后，素材会自动保存到这里")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("返回制作素材") {
                        currentStep = .selectImage
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.vertical, 40)
            } else {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                        ForEach(inventoryManager.items) { item in
                            InventoryItemCard(item: item)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        inventoryManager.removeItem(item)
                                    } label: {
                                        Label("删除", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
                
                HStack(spacing: 12) {
                    Button("清空背包") {
                        inventoryManager.clearAll()
                    }
                    .font(.subheadline)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    Button("继续制作") {
                        currentStep = .selectImage
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
    }
    
    // MARK: - 合成台视图
    
    @ViewBuilder
    private func CompositionView() -> some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI合成台")
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("选择素材和工艺，使用 Stable Diffusion 进行创作")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            if inventoryManager.items.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "square.grid.3x3")
                        .font(.system(size: 64))
                        .foregroundColor(.gray)
                    Text("还没有素材")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Button("返回背包") {
                        currentStep = .inventory
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.vertical, 40)
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // 1. 素材选择区
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("选择素材 (\(compositionManager.selectedMaterials.count)/\(compositionManager.maxMaterialsCount))")
                                    .font(.headline)
                                Spacer()
                                if !compositionManager.selectedMaterials.isEmpty {
                                    Button("清空") {
                                        compositionManager.clearSelection()
                                    }
                                    .font(.caption)
                                    .foregroundColor(.red)
                                }
                            }
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                                ForEach(inventoryManager.items.prefix(9)) { item in
                                    CompositionMaterialCard(
                                        item: item,
                                        isSelected: compositionManager.isMaterialSelected(item)
                                    ) {
                                        compositionManager.toggleMaterial(item)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(12)
                        
                        // 2. 工艺选择
                        VStack(alignment: .leading, spacing: 12) {
                            Text("选择工艺风格")
                                .font(.headline)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                                ForEach(CraftStyle.allCases) { craft in
                                    CraftStyleSelectionCard(
                                        style: craft,
                                        isSelected: compositionManager.selectedCraftStyle == craft,
                                        onTap: {
                                            compositionManager.selectedCraftStyle = craft
                                        }
                                    )
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(12)
                        
                        // 3. 提示词输入（可选）
                        VStack(alignment: .leading, spacing: 8) {
                            Text("自定义提示词（可选）")
                                .font(.headline)
                            TextField("输入描述，如：夕阳下的美丽风景...", text: $compositionManager.prompt)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.vertical, 4)
                        }
                        .padding()
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(12)
                    }
                }
                
                // 底部操作按钮
                HStack(spacing: 12) {
                    Button("返回背包") {
                        currentStep = .inventory
                    }
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    
                    Button(action: {
                        compositionManager.composeWithStableDiffusion()
                        currentStep = .compositionResult
                    }) {
                        HStack {
                            Image(systemName: "wand.and.stars")
                            Text("开始合成")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            Group {
                                if compositionManager.selectedMaterials.isEmpty {
                                    Color.gray
                                } else {
                                    LinearGradient(
                                        gradient: Gradient(colors: [.orange, .red]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                }
                            }
                        )
                        .cornerRadius(12)
                    }
                    .disabled(compositionManager.selectedMaterials.isEmpty)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
    }
    
    // MARK: - 合成结果视图
    
    @ViewBuilder
    private func CompositionResultView() -> some View {
        VStack(spacing: 24) {
            if compositionManager.isProcessing {
                VStack(spacing: 20) {
                    Text("AI创作中...")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    ProgressView()
                        .scaleEffect(1.5)
                    
                    Text("Stable Diffusion 正在生成作品")
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    if let style = compositionManager.selectedCraftStyle {
                        Text("工艺: \(style.rawValue)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 60)
            } else if let result = compositionManager.composedResult {
                VStack(spacing: 16) {
                    VStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 48))
                            .foregroundColor(.yellow)
                        
                        Text("合成完成！")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    
                    Image(uiImage: result)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 400)
                        .cornerRadius(16)
                        .shadow(radius: 10)
                    
                    VStack(spacing: 8) {
                        if let style = compositionManager.selectedCraftStyle {
                            HStack {
                                Image(systemName: "paintbrush.fill")
                                Text("工艺: \(style.rawValue)")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                        
                        if !compositionManager.prompt.isEmpty {
                            HStack {
                                Image(systemName: "text.quote")
                                Text(compositionManager.prompt)
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack(spacing: 12) {
                        Button("再次合成") {
                            compositionManager.composedResult = nil
                            currentStep = .composition
                        }
                        .font(.headline)
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                        
                        Button("返回背包") {
                            compositionManager.clearSelection()
                            currentStep = .inventory
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
            } else if let error = compositionManager.errorMessage {
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 64))
                        .foregroundColor(.red)
                    
                    Text("合成失败")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text(error)
                        .font(.body)
                        .foregroundColor(.secondary)
                    
                    Button("返回重试") {
                        currentStep = .composition
                    }
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.vertical, 40)
            }
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16)
    }
}

// MARK: - 辅助视图

struct StepIndicatorView: View {
    let currentStep: ContentView.ProcessStep
    
    var body: some View {
        HStack {
            ForEach(ContentView.ProcessStep.allCases, id: \.self) { step in
                VStack(spacing: 8) {
                    Circle()
                        .fill(stepColor(for: step))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: stepIcon(for: step))
                                .foregroundColor(.white)
                                .font(.system(size: 14, weight: .bold))
                        )
                    
                    Text(step.title)
                        .font(.caption)
                        .foregroundColor(stepColor(for: step))
                        .fontWeight(step == currentStep ? .semibold : .regular)
                }
                
                if step != ContentView.ProcessStep.allCases.last {
                    Rectangle()
                        .fill(stepCompleted(step) ? .blue : Color.gray.opacity(0.3))
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func stepColor(for step: ContentView.ProcessStep) -> Color {
        if stepCompleted(step) || step == currentStep {
            return .blue
        } else {
            return Color.gray.opacity(0.5)
        }
    }
    
    private func stepCompleted(_ step: ContentView.ProcessStep) -> Bool {
        let currentIndex = ContentView.ProcessStep.allCases.firstIndex(of: currentStep) ?? 0
        let stepIndex = ContentView.ProcessStep.allCases.firstIndex(of: step) ?? 0
        return stepIndex < currentIndex
    }
    
    private func stepIcon(for step: ContentView.ProcessStep) -> String {
        switch step {
        case .selectImage: return "photo"
        case .segmentation: return "scissors"
        case .regionSelection: return "hand.tap"
        case .styleTransfer: return "paintbrush"
        case .result: return "checkmark"
        case .inventory: return "bag"
        case .composition: return "square.grid.3x3"
        case .compositionResult: return "sparkles"
        }
    }
}

struct RegionSelectionCard: View {
    let region: ImageSegmentationManager.SegmentedRegion
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(Color(region.color))
                .frame(width: 40, height: 40)
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .overlay(
                            Group {
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .bold))
                                }
                            }
                        )
                )
            
            Text("区域 \(region.id)")
                .font(.caption)
                .foregroundColor(.primary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                )
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - 背包素材卡片（已移至 BackpackView.swift，避免重复定义）

// MARK: - 合成台素材卡片

struct CompositionMaterialCard: View {
    let item: InventoryItem
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack {
            if let image = item.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(8)
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.blue.opacity(0.2) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 3 : 1)
                )
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .overlay(
            Group {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                        .background(Circle().fill(Color.white))
                        .offset(x: 35, y: -35)
                }
            }
        )
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
