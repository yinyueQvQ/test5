import SwiftUI

// MARK: - 背包视图
struct BackpackView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var backpackManager = BackpackManager.shared
    
    @State private var selectedItemId: UUID?
    @State private var showingRenameAlert = false
    @State private var newName = ""
    
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
                    
                    Text("我的背包")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: {
                        // 清空背包
                        backpackManager.clearAll()
                    }) {
                        Text("清空")
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 0, green: 1, blue: 0.5))
                    }
                    .frame(width: 44, height: 44)
                    .disabled(backpackManager.items.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)
                
                // 素材数量
                HStack {
                    Image(systemName: "cube.box.fill")
                        .foregroundColor(Color(red: 0, green: 1, blue: 0.5))
                    Text("共 \(backpackManager.items.count) 个素材")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                
                // 素材网格
                if backpackManager.items.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()
                        
                        Image(systemName: "backpack")
                            .font(.system(size: 80))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("背包是空的")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.gray)
                        
                        Text("制作素材后会自动保存到这里")
                            .font(.system(size: 14))
                            .foregroundColor(.gray.opacity(0.7))
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ], spacing: 16) {
            ForEach(backpackManager.items) { item in
                BackpackItemCard(item: item)
                    .onLongPressGesture {
                        // 长按改名
                        selectedItemId = item.id
                        newName = item.name
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            showingRenameAlert = true
                        }
                    }
                    .contextMenu {
                        Button {
                            selectedItemId = item.id
                            newName = item.name
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                showingRenameAlert = true
                            }
                        } label: {
                            Label("改名", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            backpackManager.deleteItem(item)
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                    }
            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .alert("重命名素材", isPresented: $showingRenameAlert) {
            TextField("新名称", text: $newName)
            Button("取消", role: .cancel) {
                selectedItemId = nil
                newName = ""
            }
            Button("确定") {
                if let itemId = selectedItemId,
                   let item = backpackManager.items.first(where: { $0.id == itemId }) {
                    backpackManager.renameItem(item, newName: newName)
                }
                selectedItemId = nil
                newName = ""
            }
        }
    }
}

// MARK: - 背包素材卡片（使用 BackpackItem）
struct BackpackItemCard: View {
    let item: BackpackItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 图片
            if let image = item.uiImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 100)
                    .clipped()
                    .cornerRadius(12)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 100)
                    .cornerRadius(12)
            }
            
            // 名称和时间
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(item.createdAt.formatted(date: .numeric, time: .shortened))
                    .font(.system(size: 9))
                    .foregroundColor(.gray)
            }
        }
        .padding(8)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - 背包素材卡片（使用 InventoryItem）- 保留用于兼容
struct InventoryItemCard: View {
    let item: InventoryItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 图片
            if let image = item.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 100)
                    .clipped()
                    .cornerRadius(12)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 100)
                    .cornerRadius(12)
            }
            
            // 时间标签
            Text(item.createdAt.formatted(date: .numeric, time: .shortened))
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.gray)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(8)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    BackpackView()
}

