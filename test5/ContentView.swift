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
        
        var title: String {
            switch self {
            case .selectImage: return "选择图片"
            case .segmentation: return "图像分割"
            case .regionSelection: return "选择区域"
            case .styleTransfer: return "风格迁移"
            case .result: return "最终结果"
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

#Preview {
    ContentView()
}
