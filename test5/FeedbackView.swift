//
//  FeedbackView.swift
//  test5
//
//  意见反馈页面
//

import SwiftUI
import PhotosUI

struct FeedbackView: View {
    @Environment(\.dismiss) var dismiss
    @State private var feedbackText = ""
    @State private var selectedImages: [UIImage] = []
    @State private var showingImagePicker = false
    @State private var showingSuccessAlert = false
    @StateObject private var permissionManager = PermissionManager()
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    // 标题区域
                    VStack(alignment: .leading, spacing: 12) {
                        Text("意见反馈")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("我们非常重视您的意见，请告诉我们您的想法！")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    .padding(.bottom, 30)
                    
                    // 反馈内容输入
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("反馈内容")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Text("\(feedbackText.count) / 500")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                        }
                        
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 0.15, green: 0.15, blue: 0.15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                            
                            if feedbackText.isEmpty {
                                Text("请在此描述您遇到的问题、建议或新功能需求...")
                                    .font(.system(size: 15))
                                    .foregroundColor(.gray.opacity(0.6))
                                    .padding(.horizontal, 16)
                                    .padding(.top, 16)
                            }
                            
                            TextEditor(text: $feedbackText)
                                .font(.system(size: 15))
                                .foregroundColor(.white)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                                .padding(8)
                                .onChange(of: feedbackText) { newValue in
                                    if newValue.count > 500 {
                                        feedbackText = String(newValue.prefix(500))
                                    }
                                }
                        }
                        .frame(height: 180)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                    
                    // 上传图片区域
                    VStack(alignment: .leading, spacing: 12) {
                        Text("上传图片（可选）最多4张")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                        
                        // 图片网格
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                            ForEach(Array(selectedImages.enumerated()), id: \.offset) { index, image in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 150)
                                        .clipped()
                                        .cornerRadius(12)
                                    
                                    // 删除按钮
                                    Button(action: {
                                        selectedImages.remove(at: index)
                                    }) {
                                        Circle()
                                            .fill(Color.black.opacity(0.7))
                                            .frame(width: 28, height: 28)
                                            .overlay(
                                                Image(systemName: "xmark")
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundColor(.white)
                                            )
                                    }
                                    .padding(8)
                                }
                            }
                            
                            // 添加图片按钮
                            if selectedImages.count < 4 {
                                Button(action: {
                                    Task {
                                        let hasPermission = await permissionManager.requestPhotoLibraryPermission()
                                        if hasPermission {
                                            showingImagePicker = true
                                        }
                                    }
                                }) {
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [8, 8]))
                                        .foregroundColor(.gray.opacity(0.5))
                                        .frame(height: 150)
                                        .overlay(
                                            VStack(spacing: 12) {
                                                Image(systemName: "photo")
                                                    .font(.system(size: 40))
                                                    .foregroundColor(.gray.opacity(0.6))
                                                Text("点击或拖拽图片到此处上传")
                                                    .font(.system(size: 13))
                                                    .foregroundColor(.gray.opacity(0.6))
                                                    .multilineTextAlignment(.center)
                                            }
                                            .padding()
                                        )
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                    
                    // 底部按钮
                    HStack(spacing: 16) {
                        Button(action: {
                            dismiss()
                        }) {
                            Text("取消")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color.clear)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        Button(action: {
                            submitFeedback()
                        }) {
                            Text("提交反馈")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(
                                    feedbackText.isEmpty
                                    ? Color.gray
                                    : Color(red: 0, green: 1, blue: 0.6)
                                )
                                .cornerRadius(16)
                        }
                        .disabled(feedbackText.isEmpty)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            
            // 自定义返回按钮（左上角）
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                    }
                    .padding(.leading, 20)
                    .padding(.top, 50)
                    
                    Spacer()
                }
                Spacer()
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePickerView(selectedImage: Binding(
                get: { nil },
                set: { image in
                    if let img = image, selectedImages.count < 4 {
                        selectedImages.append(img)
                    }
                }
            ), sourceType: .photoLibrary)
        }
        .alert("提交成功", isPresented: $showingSuccessAlert) {
            Button("确定") {
                dismiss()
            }
        } message: {
            Text("感谢您的反馈！我们会认真处理。")
        }
    }
    
    private func submitFeedback() {
        // 这里实现提交反馈的逻辑
        // 可以保存到本地或发送到服务器
        print("提交反馈: \(feedbackText)")
        print("图片数量: \(selectedImages.count)")
        
        showingSuccessAlert = true
    }
}

#Preview {
    FeedbackView()
}

