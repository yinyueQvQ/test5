//
//  ImageProcessingUtils.swift
//  test5
//
//  Created by AI Assistant on 2025/10/15.
//

import UIKit
import CoreImage
import CoreML

struct ImageProcessingUtils {
    
    // MARK: - 图像尺寸标准化
    
    /// 将图像调整到标准尺寸（512x512）以确保一致性
    static func standardizeImageSize(_ image: UIImage, targetSize: CGSize = CGSize(width: 512, height: 512)) -> UIImage? {
        // 使用高质量的重采样
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    // MARK: - 图像格式转换
    
    /// 将 UIImage 转换为 CVPixelBuffer
    static func pixelBuffer(from image: UIImage, pixelFormatType: OSType = kCVPixelFormatType_32ARGB) -> CVPixelBuffer? {
        let targetSize = CGSize(width: 512, height: 512)
        guard let standardizedImage = standardizeImageSize(image, targetSize: targetSize) else {
            return nil
        }
        
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(targetSize.width),
            Int(targetSize.height),
            pixelFormatType,
            attrs,
            &pixelBuffer
        )
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0))
        defer { CVPixelBufferUnlockBaseAddress(buffer, CVPixelBufferLockFlags(rawValue: 0)) }
        
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let context = CGContext(
            data: pixelData,
            width: Int(targetSize.width),
            height: Int(targetSize.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else {
            return nil
        }
        
        context.translateBy(x: 0, y: targetSize.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        if let cgImage = standardizedImage.cgImage {
            context.draw(cgImage, in: CGRect(origin: .zero, size: targetSize))
        }
        
        return pixelBuffer
    }
    
    /// 将 CVPixelBuffer 转换为 UIImage
    static func uiImage(from pixelBuffer: CVPixelBuffer) -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - 图像合成
    
    /// 将前景图像与背景图像合成
    static func compositeImages(foreground: UIImage, background: UIImage, mask: UIImage? = nil) -> UIImage? {
        let targetSize = CGSize(width: 512, height: 512)
        
        guard let foregroundResized = standardizeImageSize(foreground, targetSize: targetSize),
              let backgroundResized = standardizeImageSize(background, targetSize: targetSize) else {
            return nil
        }
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        // 先绘制背景
        backgroundResized.draw(in: CGRect(origin: .zero, size: targetSize))
        
        // 如果有遮罩，应用遮罩
        if let mask = mask,
           let maskResized = standardizeImageSize(mask, targetSize: targetSize) {
            // 使用遮罩混合前景
            let context = UIGraphicsGetCurrentContext()
            context?.saveGState()
            
            // 将遮罩作为裁剪区域
            if let maskCGImage = maskResized.cgImage {
                context?.clip(to: CGRect(origin: .zero, size: targetSize), mask: maskCGImage)
            }
            
            foregroundResized.draw(in: CGRect(origin: .zero, size: targetSize))
            context?.restoreGState()
        } else {
            // 直接叠加前景
            foregroundResized.draw(in: CGRect(origin: .zero, size: targetSize), blendMode: .normal, alpha: 1.0)
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    // MARK: - 图像质量优化
    
    /// 优化图像以提高模型处理效果
    static func optimizeForProcessing(_ image: UIImage) -> UIImage? {
        guard let standardizedImage = standardizeImageSize(image) else {
            return nil
        }
        
        // 应用一些基本的图像增强
        guard let ciImage = CIImage(image: standardizedImage) else {
            return standardizedImage
        }
        
        let context = CIContext()
        
        // 轻微的对比度和亮度调整
        let adjustedImage = ciImage
            .applyingFilter("CIColorControls", parameters: [
                kCIInputContrastKey: 1.1,
                kCIInputBrightnessKey: 0.05,
                kCIInputSaturationKey: 1.05
            ])
        
        guard let cgImage = context.createCGImage(adjustedImage, from: adjustedImage.extent) else {
            return standardizedImage
        }
        
        return UIImage(cgImage: cgImage)
    }
    
    // MARK: - 错误处理辅助
    
    enum ImageProcessingError: LocalizedError {
        case invalidImage
        case processingFailed
        case modelNotLoaded
        case unsupportedFormat
        
        var errorDescription: String? {
            switch self {
            case .invalidImage:
                return "图像格式无效或损坏"
            case .processingFailed:
                return "图像处理失败，请重试"
            case .modelNotLoaded:
                return "AI模型加载失败，请检查模型文件"
            case .unsupportedFormat:
                return "不支持的图像格式"
            }
        }
    }
    
    // MARK: - 内存管理
    
    /// 清理图像处理过程中的临时资源
    static func cleanupResources() {
        // 清理 Core Image 缓存
        CIContext().clearCaches()
        
        // 触发垃圾回收
        DispatchQueue.global(qos: .background).async {
            autoreleasepool {
                // 执行一些清理操作
                let _ = UIImage()
            }
        }
    }
}

// MARK: - UIImage Extension

extension UIImage {
    
    /// 快速标准化图像尺寸
    func standardized() -> UIImage? {
        return ImageProcessingUtils.standardizeImageSize(self)
    }
    
    /// 优化图像用于AI处理
    func optimizedForProcessing() -> UIImage? {
        return ImageProcessingUtils.optimizeForProcessing(self)
    }
    
    /// 获取图像的像素缓冲区
    func pixelBuffer() -> CVPixelBuffer? {
        return ImageProcessingUtils.pixelBuffer(from: self)
    }
    
    /// 检查图像是否有效
    var isValid: Bool {
        return cgImage != nil && size.width > 0 && size.height > 0
    }
    
    /// 计算图像的纵横比
    var aspectRatio: CGFloat {
        return size.width / size.height
    }
}
