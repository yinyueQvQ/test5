//
//  StyleTransferManager.swift
//  test5
//
//  Created by AI Assistant on 2025/10/15.
//

import Foundation
import CoreML
import Vision
import UIKit
import SwiftUI

class StyleTransferManager: ObservableObject {
    private var model: VNCoreMLModel?
    @Published var isLoading = false
    @Published var transferredImage: UIImage?
    
    // 保存输入图像用于合成
    private var inputImageForCompositing: UIImage?
    
    init() {
        loadModel()
    }
    
    private func loadModel() {
        guard let modelURL = Bundle.main.url(forResource: "animeganPaprika", withExtension: "mlmodelc") else {
            print("无法找到animeganPaprika.mlmodelc文件")
            return
        }
        
        do {
            let mlModel = try MLModel(contentsOf: modelURL)
            model = try VNCoreMLModel(for: mlModel)
        } catch {
            print("加载风格迁移模型失败: \(error)")
        }
    }
    
    func transferStyle(for image: UIImage) {
        guard let model = model else {
            print("❌ [DEBUG] 风格迁移模型未加载")
            return
        }
        
        print("🎨 [DEBUG] 开始风格迁移，保持透明背景...")
        isLoading = true
        
        // 保存输入图像用于后续合成
        inputImageForCompositing = image
        
        // 确保图像尺寸一致
        let targetSize = CGSize(width: 512, height: 512)
        guard let resizedImage = resizeImage(image, to: targetSize) else {
            isLoading = false
            return
        }
        
        // 预处理：将透明区域填充为纯色，避免模型处理时的边缘效应
        guard let processedImage = preprocessImageForStyleTransfer(resizedImage) else {
            print("❌ [DEBUG] 图像预处理失败")
            isLoading = false
            return
        }
        
        guard let ciImage = CIImage(image: processedImage) else {
            isLoading = false
            return
        }
        
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            DispatchQueue.main.async {
                self?.handleStyleTransferResult(request: request, error: error)
            }
        }
        
        request.imageCropAndScaleOption = .scaleFit
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    print("❌ [DEBUG] 风格迁移请求失败: \(error)")
                    self.isLoading = false
                }
            }
        }
    }
    
    // 预处理图像：将透明区域填充，避免模型边缘效应
    private func preprocessImageForStyleTransfer(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        
        // 创建像素数据
        var pixelData = [UInt8](repeating: 0, count: width * height * 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let context = CGContext(data: &pixelData,
                                    width: width,
                                    height: height,
                                    bitsPerComponent: 8,
                                    bytesPerRow: width * 4,
                                    space: colorSpace,
                                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // 处理透明区域：填充为中性色
        for i in stride(from: 0, to: pixelData.count, by: 4) {
            let alpha = pixelData[i + 3]
            
            if alpha == 0 {
                // 透明区域：填充为中性灰色
                pixelData[i] = 128     // R
                pixelData[i + 1] = 128 // G
                pixelData[i + 2] = 128 // B
                pixelData[i + 3] = 255 // A - 设为不透明供模型处理
            }
        }
        
        // 创建预处理后的图像
        guard let processedContext = CGContext(data: &pixelData,
                                             width: width,
                                             height: height,
                                             bitsPerComponent: 8,
                                             bytesPerRow: width * 4,
                                             space: colorSpace,
                                             bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              let processedCGImage = processedContext.makeImage() else {
            return nil
        }
        
        print("✅ [DEBUG] 图像预处理完成")
        return UIImage(cgImage: processedCGImage)
    }
    
    private func handleStyleTransferResult(request: VNRequest, error: Error?) {
        isLoading = false
        
        if let error = error {
            print("❌ [DEBUG] 风格迁移失败: \(error)")
            return
        }
        
        print("📊 [DEBUG] 检查风格迁移结果类型...")
        print("📋 [DEBUG] 结果数量: \(request.results?.count ?? 0)")
        
        // 尝试不同的结果类型
        if let observations = request.results as? [VNCoreMLFeatureValueObservation] {
            print("✅ [DEBUG] 获得VNCoreMLFeatureValueObservation结果")
            handleStyleTransferFeatureValue(observations)
        } else if let pixelBufferObservations = request.results as? [VNPixelBufferObservation] {
            print("✅ [DEBUG] 获得VNPixelBufferObservation结果")
            handleStyleTransferPixelBuffer(pixelBufferObservations)
        } else {
            print("❌ [DEBUG] 未知的风格迁移结果类型")
            if let results = request.results {
                print("📋 [DEBUG] 实际结果类型: \(type(of: results.first))")
            }
        }
    }
    
    private func handleStyleTransferFeatureValue(_ observations: [VNCoreMLFeatureValueObservation]) {
        print("🔍 [DEBUG] 处理风格迁移FeatureValue结果...")
        
        guard let featureValue = observations.first?.featureValue else {
            print("❌ [DEBUG] 无法获取featureValue")
            return
        }
        
        if let pixelBuffer = featureValue.imageBufferValue {
            convertPixelBufferToImage(pixelBuffer)
        } else if let multiArray = featureValue.multiArrayValue {
            print("📊 [DEBUG] MultiArray形状: \(multiArray.shape)")
            print("📊 [DEBUG] MultiArray数据类型: \(multiArray.dataType)")
            convertMultiArrayToImage(multiArray)
        } else {
            print("❌ [DEBUG] FeatureValue中没有可用的图像数据")
        }
    }
    
    private func handleStyleTransferPixelBuffer(_ observations: [VNPixelBufferObservation]) {
        print("🔍 [DEBUG] 处理风格迁移PixelBuffer结果...")
        
        guard let pixelBuffer = observations.first?.pixelBuffer else {
            print("❌ [DEBUG] 无法获取pixelBuffer")
            return
        }
        
        convertPixelBufferToImage(pixelBuffer)
    }
    
    private func convertPixelBufferToImage(_ pixelBuffer: CVPixelBuffer) {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            print("❌ [DEBUG] 无法从PixelBuffer创建CGImage")
            return
        }
        
        let styledImage = UIImage(cgImage: cgImage)
        
        // 合成最终结果：风格迁移的物体 + 透明背景
        transferredImage = compositeWithTransparentBackground(styledImage: styledImage)
        print("✅ [DEBUG] 透明背景风格迁移完成")
    }
    
    private func convertMultiArrayToImage(_ multiArray: MLMultiArray) {
        // 处理3维或其他维度的MultiArray输出
        let shape = multiArray.shape
        print("🔄 [DEBUG] 尝试从MultiArray创建图像，形状: \(shape)")
        
        // 假设输出是 [height, width, channels] 或 [channels, height, width]
        var height: Int, width: Int, channels: Int
        
        if shape.count == 3 {
            if shape[2].intValue == 3 || shape[2].intValue == 1 {
                // [height, width, channels]
                height = shape[0].intValue
                width = shape[1].intValue
                channels = shape[2].intValue
            } else {
                // [channels, height, width]
                channels = shape[0].intValue
                height = shape[1].intValue
                width = shape[2].intValue
            }
        } else {
            print("❌ [DEBUG] 不支持的MultiArray维度")
            return
        }
        
        print("📏 [DEBUG] 图像尺寸: \(width)x\(height), 通道数: \(channels)")
        
        // 创建像素数据
        let pixelData = UnsafeMutablePointer<UInt8>.allocate(capacity: width * height * 4)
        defer { pixelData.deallocate() }
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * width + x) * 4
                
                if channels == 3 {
                    // RGB
                    let rIndex = shape[2].intValue == 3 ? [y, x, 0] : [0, y, x]
                    let gIndex = shape[2].intValue == 3 ? [y, x, 1] : [1, y, x]
                    let bIndex = shape[2].intValue == 3 ? [y, x, 2] : [2, y, x]
                    
                    let r = UInt8(max(0, min(255, multiArray[rIndex as [NSNumber]].floatValue * 255)))
                    let g = UInt8(max(0, min(255, multiArray[gIndex as [NSNumber]].floatValue * 255)))
                    let b = UInt8(max(0, min(255, multiArray[bIndex as [NSNumber]].floatValue * 255)))
                    
                    pixelData[pixelIndex] = r
                    pixelData[pixelIndex + 1] = g
                    pixelData[pixelIndex + 2] = b
                    pixelData[pixelIndex + 3] = 255 // alpha
                } else {
                    // 灰度或其他格式
                    let value = UInt8(max(0, min(255, multiArray[[y, x, 0] as [NSNumber]].floatValue * 255)))
                    pixelData[pixelIndex] = value
                    pixelData[pixelIndex + 1] = value
                    pixelData[pixelIndex + 2] = value
                    pixelData[pixelIndex + 3] = 255
                }
            }
        }
        
        // 创建CGImage
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        guard let context = CGContext(
            data: pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo.rawValue
        ), let cgImage = context.makeImage() else {
            print("❌ [DEBUG] 无法从MultiArray创建CGImage")
            return
        }
        
        let styledImage = UIImage(cgImage: cgImage)
        
        // 合成最终结果：风格迁移的物体 + 透明背景
        transferredImage = compositeWithTransparentBackground(styledImage: styledImage)
        print("✅ [DEBUG] 从MultiArray创建透明背景风格迁移结果成功")
    }
    
    private func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        image.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    // 合成透明背景的风格迁移结果
    private func compositeWithTransparentBackground(styledImage: UIImage) -> UIImage? {
        guard let inputImage = inputImageForCompositing,
              let inputCGImage = inputImage.cgImage,
              let styledCGImage = styledImage.cgImage else {
            print("⚠️ [DEBUG] 缺少输入图像，返回原始风格迁移结果")
            return styledImage
        }
        
        let width = inputCGImage.width
        let height = inputCGImage.height
        
        print("🔄 [DEBUG] 开始合成透明背景风格迁移结果...")
        
        // 获取输入图像的像素数据（包含透明度信息）
        var inputPixels = [UInt8](repeating: 0, count: width * height * 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let inputContext = CGContext(data: &inputPixels,
                                         width: width,
                                         height: height,
                                         bitsPerComponent: 8,
                                         bytesPerRow: width * 4,
                                         space: colorSpace,
                                         bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return styledImage
        }
        
        inputContext.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // 获取风格迁移后的像素数据
        var styledPixels = [UInt8](repeating: 0, count: width * height * 4)
        
        guard let styledContext = CGContext(data: &styledPixels,
                                          width: width,
                                          height: height,
                                          bitsPerComponent: 8,
                                          bytesPerRow: width * 4,
                                          space: colorSpace,
                                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return styledImage
        }
        
        styledContext.draw(styledCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        // 创建最终合成结果
        var finalPixels = [UInt8](repeating: 0, count: width * height * 4)
        
        for i in stride(from: 0, to: inputPixels.count, by: 4) {
            let inputAlpha = inputPixels[i + 3]
            
            if inputAlpha > 0 {
                // 原图非透明区域：使用风格迁移后的颜色，保持原始透明度
                finalPixels[i] = styledPixels[i]         // R
                finalPixels[i + 1] = styledPixels[i + 1] // G
                finalPixels[i + 2] = styledPixels[i + 2] // B
                finalPixels[i + 3] = inputAlpha          // 保持原始透明度
            } else {
                // 原图透明区域：保持完全透明
                finalPixels[i] = 0     // R
                finalPixels[i + 1] = 0 // G
                finalPixels[i + 2] = 0 // B
                finalPixels[i + 3] = 0 // A (透明)
            }
        }
        
        // 创建最终图像
        guard let finalContext = CGContext(data: &finalPixels,
                                         width: width,
                                         height: height,
                                         bitsPerComponent: 8,
                                         bytesPerRow: width * 4,
                                         space: colorSpace,
                                         bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              let finalCGImage = finalContext.makeImage() else {
            return styledImage
        }
        
        print("✅ [DEBUG] 透明背景合成完成")
        return UIImage(cgImage: finalCGImage)
    }
    
    func reset() {
        transferredImage = nil
        inputImageForCompositing = nil
    }
}
