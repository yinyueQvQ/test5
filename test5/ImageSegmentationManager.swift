//
//  ImageSegmentationManager.swift
//  test5
//
//  Created by AI Assistant on 2025/10/15.
//

import Foundation
import CoreML
import Vision
import UIKit
import SwiftUI

class ImageSegmentationManager: ObservableObject {
    private var model: VNCoreMLModel?
    @Published var isLoading = false
    @Published var segmentationResult: UIImage?
    @Published var highlightedSegmentationResult: UIImage?
    @Published var originalImage: UIImage?
    @Published var segmentedRegions: [SegmentedRegion] = []
    @Published var selectedRegions: Set<Int> = [] {
        didSet {
            updateHighlightedResult()
        }
    }
    
    // 存储真实分割数据
    private var realSegmentationData: [Int: [CGPoint]] = [:]
    private var segmentationImageSize: CGSize = .zero
    
    struct SegmentedRegion: Equatable {
        let id: Int
        let pixelMask: [CGPoint]
        let color: UIColor
        let bounds: CGRect
        
        static func == (lhs: SegmentedRegion, rhs: SegmentedRegion) -> Bool {
            return lhs.id == rhs.id
        }
    }
    
    init() {
        loadModel()
    }
    
    private func loadModel() {
        print("🔍 [DEBUG] 开始加载分割模型...")
        
        guard let modelURL = Bundle.main.url(forResource: "is-net-genral-use", withExtension: "mlmodelc") else {
            print("❌ [DEBUG] 无法找到is-net-genral-use.mlmodelc文件")
            return
        }
        
        print("✅ [DEBUG] 找到模型文件: \(modelURL.lastPathComponent)")
        
        do {
            let mlModel = try MLModel(contentsOf: modelURL)
            print("✅ [DEBUG] MLModel加载成功")
            
            model = try VNCoreMLModel(for: mlModel)
            print("✅ [DEBUG] VNCoreMLModel创建成功")
        } catch {
            print("❌ [DEBUG] 加载分割模型失败: \(error)")
        }
    }
    
    func segmentImage(_ image: UIImage) {
        print("🖼️ [DEBUG] 开始图像分割处理...")
        
        guard let model = model else {
            print("❌ [DEBUG] 模型未加载")
            return
        }
        
        isLoading = true
        originalImage = image
        
        // 调整图像大小
        let targetSize = CGSize(width: 512, height: 512)
        guard let resizedImage = resizeImage(image, to: targetSize) else {
            isLoading = false
            return
        }
        
        guard let ciImage = CIImage(image: resizedImage) else {
            isLoading = false
            return
        }
        
        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            DispatchQueue.main.async {
                self?.handleSegmentationResult(request: request, error: error, originalSize: targetSize)
            }
        }
        
        request.imageCropAndScaleOption = .scaleFit
        
        let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("❌ [DEBUG] 图像分割请求失败: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    
    private func handleSegmentationResult(request: VNRequest, error: Error?, originalSize: CGSize) {
        print("🔄 [DEBUG] 开始处理分割结果...")
        isLoading = false
        
        if let error = error {
            print("❌ [DEBUG] 分割失败: \(error)")
            return
        }
        
        // 只处理真实模型输出
        if let observations = request.results as? [VNCoreMLFeatureValueObservation] {
            print("✅ [DEBUG] 获得FeatureValue结果")
            processModelOutput(observations, originalSize: originalSize)
        } else if let pixelBufferObservations = request.results as? [VNPixelBufferObservation] {
            print("✅ [DEBUG] 获得PixelBuffer结果")  
            processPixelBufferOutput(pixelBufferObservations, originalSize: originalSize)
        } else {
            print("❌ [DEBUG] 模型输出格式不支持")
        }
    }
    
    private func processModelOutput(_ observations: [VNCoreMLFeatureValueObservation], originalSize: CGSize) {
        guard let multiArray = observations.first?.featureValue.multiArrayValue else {
            print("❌ [DEBUG] 无法获取MultiArray")
            return
        }
        
        print("📊 [DEBUG] MultiArray形状: \(multiArray.shape)")
        extractSegmentationRegions(from: multiArray, imageSize: originalSize)
    }
    
    private func processPixelBufferOutput(_ observations: [VNPixelBufferObservation], originalSize: CGSize) {
        guard let pixelBuffer = observations.first?.pixelBuffer else {
            print("❌ [DEBUG] 无法获取PixelBuffer")
            return
        }
        
        extractSegmentationRegions(from: pixelBuffer, imageSize: originalSize)
    }
    
    // 从MultiArray提取分割区域
    private func extractSegmentationRegions(from multiArray: MLMultiArray, imageSize: CGSize) {
        let shape = multiArray.shape
        guard shape.count >= 2 else { return }
        
        let height = shape[0].intValue
        let width = shape[1].intValue
        segmentationImageSize = CGSize(width: width, height: height)
        
        var detectedObjects: [Int: [CGPoint]] = [:]
        
        for y in 0..<height {
            for x in 0..<width {
                var classId: Int
                
                if shape.count == 2 {
                    classId = Int(multiArray[[y, x] as [NSNumber]].floatValue)
                } else if shape.count == 3 {
                    let numClasses = shape[2].intValue
                    var maxProb: Float = -1
                    classId = 0
                    
                    for c in 0..<numClasses {
                        let prob = multiArray[[y, x, c] as [NSNumber]].floatValue
                        if prob > maxProb {
                            maxProb = prob
                            classId = c
                        }
                    }
                } else {
                    classId = 0
                }
                
                // 只记录物体，忽略背景(classId = 0)
                if classId > 0 {
                    if detectedObjects[classId] == nil {
                        detectedObjects[classId] = []
                    }
                    detectedObjects[classId]?.append(CGPoint(x: x, y: y))
                }
            }
        }
        
        createRegionsFromData(detectedObjects)
    }
    
    // 从PixelBuffer提取分割区域
    private func extractSegmentationRegions(from pixelBuffer: CVPixelBuffer, imageSize: CGSize) {
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
        defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly) }
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        segmentationImageSize = CGSize(width: width, height: height)
        
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else { return }
        
        let buffer = baseAddress.assumingMemoryBound(to: UInt8.self)
        var detectedObjects: [Int: [CGPoint]] = [:]
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = y * width + x
                let classId = Int(buffer[pixelIndex])
                
                // 只记录物体，忽略背景
                if classId > 0 {
                    if detectedObjects[classId] == nil {
                        detectedObjects[classId] = []
                    }
                    detectedObjects[classId]?.append(CGPoint(x: x, y: y))
                }
            }
        }
        
        createRegionsFromData(detectedObjects)
    }
    
    // 从检测数据创建区域
    private func createRegionsFromData(_ detectedObjects: [Int: [CGPoint]]) {
        print("🎨 [DEBUG] 从\(detectedObjects.count)个检测物体创建区域...")
        
        realSegmentationData = detectedObjects
        segmentationResult = originalImage
        
        // 过滤有效物体并限制到最大5个
        let validObjects = detectedObjects.filter { $0.value.count > 20 }
        let sortedObjects = validObjects.sorted { $0.value.count > $1.value.count }
        let topObjects = Array(sortedObjects.prefix(5))
        
        var newRegions: [SegmentedRegion] = []
        let colors: [UIColor] = [.red, .blue, .green, .yellow, .orange]
        
        // 重新分配ID为顺序编号：1, 2, 3, 4, 5
        for (index, (originalId, pixels)) in topObjects.enumerated() {
            let sequentialId = index + 1  // 从1开始的顺序ID
            
            print("🔄 [DEBUG] 重新分配ID: 原始ID \(originalId) → 顺序ID \(sequentialId)")
            
            let minX = pixels.map { $0.x }.min() ?? 0
            let maxX = pixels.map { $0.x }.max() ?? 0
            let minY = pixels.map { $0.y }.min() ?? 0
            let maxY = pixels.map { $0.y }.max() ?? 0
            let bounds = CGRect(x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1)
            
            let region = SegmentedRegion(
                id: sequentialId,  // 使用顺序ID
                pixelMask: pixels,
                color: colors[index % colors.count],
                bounds: bounds
            )
            newRegions.append(region)
        }
        
        segmentedRegions = newRegions
        updateHighlightedResult()
        
        print("✅ [DEBUG] 创建了\(newRegions.count)个真实物体区域，ID: \(newRegions.map { $0.id })")
    }
    
    // 工具函数
    private func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        image.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    // 更新高亮显示
    func updateHighlightedResult() {
        guard let originalImage = originalImage else { return }
        
        let size = CGSize(width: 512, height: 512)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        let context = UIGraphicsGetCurrentContext()
        
        // 绘制原图
        if let resizedOriginal = resizeImage(originalImage, to: size) {
            resizedOriginal.draw(in: CGRect(origin: .zero, size: size))
        }
        
        // 绘制所有区域的边框
        for region in segmentedRegions {
            drawRegionBorder(region: region, context: context, size: size, isSelected: false)
        }
        
        // 绘制选中区域的高亮
        for regionId in selectedRegions {
            if let region = segmentedRegions.first(where: { $0.id == regionId }) {
                drawRegionHighlight(region: region, context: context, size: size)
            }
        }
        
        highlightedSegmentationResult = UIGraphicsGetImageFromCurrentImageContext()
    }
    
    private func drawRegionBorder(region: SegmentedRegion, context: CGContext?, size: CGSize, isSelected: Bool) {
        guard let context = context else { return }
        
        context.saveGState()
        
        if isSelected {
            context.setStrokeColor(UIColor.systemYellow.cgColor)
            context.setLineWidth(3.0)
        } else {
            context.setStrokeColor(UIColor.white.withAlphaComponent(0.6).cgColor)
            context.setLineWidth(1.0)
        }
        
        context.stroke(region.bounds)
        context.restoreGState()
    }
    
    private func drawRegionHighlight(region: SegmentedRegion, context: CGContext?, size: CGSize) {
        // 移除所有高亮效果 - 选中区域不显示任何视觉反馈
        return
    }
    
    // 抠图功能
    func extractSelectedRegions() -> UIImage? {
        guard !selectedRegions.isEmpty,
              let originalImage = originalImage else { return nil }
        
        let size = CGSize(width: 512, height: 512)
        let width = Int(size.width)
        let height = Int(size.height)
        
        // 创建原图像素数据
        guard let resizedOriginal = resizeImage(originalImage, to: size),
              let originalCGImage = resizedOriginal.cgImage else { return nil }
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var originalPixels = [UInt8](repeating: 0, count: width * height * 4)
        
        guard let originalContext = CGContext(data: &originalPixels,
                                            width: width,
                                            height: height,
                                            bitsPerComponent: 8,
                                            bytesPerRow: width * 4,
                                            space: colorSpace,
                                            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        
        originalContext.draw(originalCGImage, in: CGRect(origin: .zero, size: size))
        
        // 创建抠图结果（全透明背景）
        var cutoutPixels = [UInt8](repeating: 0, count: width * height * 4)
        
        // 缩放比例
        let scaleX = Double(width) / segmentationImageSize.width
        let scaleY = Double(height) / segmentationImageSize.height
        
        // 合并所有选中区域
        for regionId in selectedRegions {
            guard let region = segmentedRegions.first(where: { $0.id == regionId }) else { continue }
            
            for point in region.pixelMask {
                let scaledX = Int(point.x * scaleX)
                let scaledY = Int(point.y * scaleY)
                
                if scaledX >= 0 && scaledX < width && scaledY >= 0 && scaledY < height {
                    let pixelIndex = scaledY * width + scaledX
                    let colorIndex = pixelIndex * 4
                    
                    if colorIndex < cutoutPixels.count - 3 {
                        cutoutPixels[colorIndex] = originalPixels[colorIndex]         // R
                        cutoutPixels[colorIndex + 1] = originalPixels[colorIndex + 1] // G
                        cutoutPixels[colorIndex + 2] = originalPixels[colorIndex + 2] // B
                        cutoutPixels[colorIndex + 3] = 255                           // A
                    }
                }
            }
        }
        
        // 创建最终图像
        guard let cutoutContext = CGContext(data: &cutoutPixels,
                                          width: width,
                                          height: height,
                                          bitsPerComponent: 8,
                                          bytesPerRow: width * 4,
                                          space: colorSpace,
                                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
              let cutoutCGImage = cutoutContext.makeImage() else { return nil }
        
        print("✅ [DEBUG] 抠图创建成功！")
        return UIImage(cgImage: cutoutCGImage)
    }
}