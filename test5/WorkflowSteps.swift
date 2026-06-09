//
//  WorkflowSteps.swift
//  test5
//
//  工作流各步骤的视图组件
//

import SwiftUI

// MARK: - 分割步骤
struct SegmentationStepView: View {
    @ObservedObject var manager: ImageSegmentationManager
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // 卡片背景
            VStack(spacing: 16) {
                // 标题
                HStack {
                    Image(systemName: "scissors")
                        .foregroundColor(.green)
                    Text("AI智能分割")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
                
                // 原始图片
                if let originalImage = manager.originalImage {
                    VStack(spacing: 8) {
                        Text("原始图片")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Image(uiImage: originalImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 250)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.3), radius: 10)
                    }
                }
                
                // 加载状态
                if manager.isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.green)
                        Text("AI正在识别图像中的物体...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 30)
                }
                
                // 分割结果
                if let segmentationResult = manager.segmentationResult, !manager.isLoading {
                    VStack(spacing: 8) {
                        Text("分割结果")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Image(uiImage: segmentationResult)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 250)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.3), radius: 10)
                        
                        Text("✓ 识别到 \(manager.segmentedRegions.count) 个区域")
                            .font(.caption)
                            .foregroundColor(.green)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        // 下一步按钮
                        Button(action: onNext) {
                            HStack {
                                Text("选择区域")
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .padding(20)
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
        }
    }
}

// MARK: - 区域选择步骤
struct RegionSelectionStepView: View {
    @ObservedObject var manager: ImageSegmentationManager
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                // 标题
                HStack {
                    Image(systemName: "hand.tap")
                        .foregroundColor(.cyan)
                    Text("选择需要的区域")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
                
                Text("点击下方区域卡片，选中的区域会高亮显示")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // 分割结果预览
                if let highlightedResult = manager.highlightedSegmentationResult {
                    Image(uiImage: highlightedResult)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 250)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.3), radius: 10)
                } else if let segmentationResult = manager.segmentationResult {
                    Image(uiImage: segmentationResult)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 250)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.3), radius: 10)
                }
                
                // 区域选择网格
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(manager.segmentedRegions, id: \.id) { region in
                        RegionCard(
                            region: region,
                            isSelected: manager.selectedRegions.contains(region.id),
                            onTap: {
                                // 切换区域选择状态
                                if manager.selectedRegions.contains(region.id) {
                                    manager.selectedRegions.remove(region.id)
                                } else {
                                    manager.selectedRegions.insert(region.id)
                                }
                            }
                        )
                    }
                }
                
                // 已选择提示
                if !manager.selectedRegions.isEmpty {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("已选择 \(manager.selectedRegions.count) 个区域")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                    .padding(.vertical, 8)
                }
                
                // 下一步按钮
                Button(action: onNext) {
                    HStack {
                        Text("风格迁移")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(manager.selectedRegions.isEmpty ? Color.gray : Color.cyan)
                    .cornerRadius(12)
                }
                .disabled(manager.selectedRegions.isEmpty)
            }
            .padding(20)
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
        }
    }
}

// 区域卡片
struct RegionCard: View {
    let region: ImageSegmentationManager.SegmentedRegion
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(region.color).opacity(0.3))
                        .frame(height: 60)
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.green)
                    }
                }
                
                Text("区域 \(region.id)")
                    .font(.caption)
                    .foregroundColor(isSelected ? .green : .gray)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 风格迁移步骤
struct StyleTransferStepView: View {
    @ObservedObject var manager: StyleTransferManager
    @ObservedObject var segmentationManager: ImageSegmentationManager
    @ObservedObject var inventoryManager: InventoryManager
    let onNext: () -> Void
    
    @State private var hasStartedTransfer = false
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                // 标题
                HStack {
                    Image(systemName: "paintbrush.fill")
                        .foregroundColor(.purple)
                    Text("风格迁移")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
                
                // 选中区域预览
                if let highlightedImage = segmentationManager.highlightedSegmentationResult {
                    VStack(spacing: 8) {
                        Text("选中的区域")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Image(uiImage: highlightedImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.3), radius: 10)
                    }
                }
                
                // 开始风格迁移按钮
                if !hasStartedTransfer {
                    Button(action: {
                        hasStartedTransfer = true
                        // 使用原始图像进行风格迁移
                        if let originalImage = segmentationManager.originalImage {
                            manager.transferStyle(for: originalImage)
                        }
                    }) {
                        HStack {
                            Image(systemName: "wand.and.stars")
                            Text("应用动漫风格")
                        }
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(12)
                    }
                }
                
                // 处理中状态
                if manager.isLoading {
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.purple)
                        Text("正在应用风格...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 20)
                }
                
                // 迁移结果
                if let result = manager.transferredImage, !manager.isLoading {
                    VStack(spacing: 8) {
                        Text("迁移结果")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Image(uiImage: result)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 200)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.3), radius: 10)
                        
                        Text("✓ 素材已自动保存到背包")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        // 下一步按钮
                        Button(action: onNext) {
                            HStack {
                                Text("查看背包")
                                Image(systemName: "arrow.right")
                            }
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .padding(20)
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
        }
    }
}

// MARK: - 背包步骤
struct InventoryStepView: View {
    @ObservedObject var manager: InventoryManager
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                // 标题
                HStack {
                    Image(systemName: "bag.fill")
                        .foregroundColor(.orange)
                    Text("素材背包")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                    
                    Text("\(manager.items.count) 个素材")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // 素材网格
                if manager.items.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bag.badge.plus")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("背包是空的")
                            .foregroundColor(.gray)
                        Text("完成风格迁移后素材会自动保存到这里")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                        ForEach(manager.items) { item in
                            SimpleInventoryItemView(item: item)
                        }
                    }
                }
                
                // 进入合成台按钮
                Button(action: onNext) {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("进入合成台")
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(manager.items.isEmpty ? Color.gray : Color.orange)
                    .cornerRadius(12)
                }
                .disabled(manager.items.isEmpty)
            }
            .padding(20)
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
        }
    }
}

// 简单素材卡片视图（仅用于工作流显示）
struct SimpleInventoryItemView: View {
    let item: InventoryItem
    
    var body: some View {
        VStack(spacing: 4) {
            if let image = item.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipped()
                    .cornerRadius(12)
            }
            
            if let craft = item.selectedCraft {
                Text(craft.rawValue)
                    .font(.caption2)
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
        }
    }
}

// MARK: - 合成步骤
struct CompositionStepView: View {
    @ObservedObject var manager: CompositionManager
    @ObservedObject var inventoryManager: InventoryManager
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                // 标题
                HStack {
                    Image(systemName: "wand.and.stars.inverse")
                        .foregroundColor(.pink)
                    Text("AI合成台")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
                
                Text("选择素材进行AI创作（最多3个）")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                // 素材选择
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    ForEach(inventoryManager.items) { item in
                        SelectableInventoryItemCard(
                            item: item,
                            isSelected: manager.isMaterialSelected(item),
                            onTap: {
                                manager.toggleMaterial(item)
                            }
                        )
                    }
                }
                
                // 工艺风格选择
                if !manager.selectedMaterials.isEmpty {
                    VStack(spacing: 12) {
                        Text("选择工艺风格")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            ForEach(CraftStyle.allCases, id: \.self) { style in
                                CraftStyleSelectionCard(
                                    style: style,
                                    isSelected: manager.selectedCraftStyle == style,
                                    onTap: { manager.selectedCraftStyle = style }
                                )
                            }
                        }
                    }
                    
                    // 开始合成按钮
                    Button(action: {
                        manager.composeWithStableDiffusion()
                        // 等待合成完成后跳转
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            if manager.composedResult != nil {
                                onNext()
                            }
                        }
                    }) {
                        if manager.isProcessing {
                            HStack(spacing: 12) {
                                ProgressView()
                                    .tint(.white)
                                Text("AI创作中...")
                            }
                        } else {
                            HStack {
                                Image(systemName: "sparkles")
                                Text("开始合成")
                            }
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(manager.isProcessing ? Color.gray : Color.pink)
                    .cornerRadius(12)
                    .disabled(manager.isProcessing)
                }
            }
            .padding(20)
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
        }
    }
}

// 可选择的素材卡片
struct SelectableInventoryItemCard: View {
    let item: InventoryItem
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                if let image = item.image {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipped()
                        .cornerRadius(12)
                        .opacity(isSelected ? 1 : 0.5)
                }
                
                if isSelected {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .offset(x: -4, y: 4)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.green : Color.clear, lineWidth: 3)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 工艺风格选择卡片
struct CraftStyleSelectionCard: View {
    let style: CraftStyle
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                Image(systemName: style.icon)
                    .font(.system(size: 30))
                    .foregroundColor(isSelected ? .pink : .white)
                
                Text(style.rawValue)
                    .font(.subheadline)
                    .foregroundColor(isSelected ? .pink : .white)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.pink.opacity(0.2) : Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.pink : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 完成步骤
struct ResultStepView: View {
    @ObservedObject var compositionManager: CompositionManager
    let onSaveDraft: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                // 标题
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("创作完成")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
                
                // 最终作品
                if let result = compositionManager.composedResult {
                    VStack(spacing: 12) {
                        Image(uiImage: result)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 400)
                            .cornerRadius(20)
                            .shadow(color: .black.opacity(0.5), radius: 20)
                        
                        // 保存按钮
                        Button(action: onSaveDraft) {
                            HStack {
                                Image(systemName: "square.and.arrow.down")
                                Text("保存到草稿")
                            }
                            .font(.headline)
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                        }
                    }
                }
            }
            .padding(20)
            .background(Color.white.opacity(0.1))
            .cornerRadius(20)
        }
    }
}

