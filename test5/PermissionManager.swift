//
//  PermissionManager.swift
//  test5
//
//  Created by AI Assistant on 2025/10/15.
//

import Foundation
import AVFoundation
import Photos
import UIKit
import UserNotifications

// 统一的权限状态枚举
enum PermissionStatus {
    case authorized
    case denied
    case restricted
    case notDetermined
}

class PermissionManager: ObservableObject {
    
    @Published var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    @Published var photoLibraryPermissionStatus: PHAuthorizationStatus = .notDetermined
    @Published var notificationPermissionStatus: UNAuthorizationStatus = .notDetermined
    
    init() {
        updatePermissionStatus()
    }
    
    // MARK: - Permission Status Updates
    
    func updatePermissionStatus() {
        cameraPermissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
        if #available(iOS 14, *) {
            photoLibraryPermissionStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        } else {
            photoLibraryPermissionStatus = PHPhotoLibrary.authorizationStatus()
        }
        
        // 更新通知权限状态
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            await MainActor.run {
                notificationPermissionStatus = settings.authorizationStatus
            }
        }
    }
    
    // MARK: - Camera Permission
    
    func requestCameraPermission() async -> Bool {
        switch cameraPermissionStatus {
        case .authorized:
            return true
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            await MainActor.run {
                cameraPermissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
            }
            return granted
        case .denied, .restricted:
            await MainActor.run {
                showSettingsAlert(for: "相机")
            }
            return false
        @unknown default:
            return false
        }
    }
    
    // MARK: - Photo Library Permission
    
    func requestPhotoLibraryPermission() async -> Bool {
        switch photoLibraryPermissionStatus {
        case .authorized, .limited:
            return true
        case .notDetermined:
            var status: PHAuthorizationStatus
            if #available(iOS 14, *) {
                status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            } else {
                status = await withCheckedContinuation { continuation in
                    PHPhotoLibrary.requestAuthorization { authStatus in
                        continuation.resume(returning: authStatus)
                    }
                }
            }
            await MainActor.run {
                photoLibraryPermissionStatus = status
            }
            return status == .authorized || status == .limited
        case .denied, .restricted:
            await MainActor.run {
                showSettingsAlert(for: "照片")
            }
            return false
        @unknown default:
            return false
        }
    }
    
    // MARK: - Save Photo Permission
    
    func savePhotoToLibrary(_ image: UIImage) {
        Task {
            let hasPermission = await requestPhotoLibraryPermission()
            if hasPermission {
                await MainActor.run {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func showSettingsAlert(for feature: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        
        let alert = UIAlertController(
            title: "需要访问\(feature)",
            message: "请在设置中允许访问\(feature)以使用此功能",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "设置", style: .default) { _ in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        window.rootViewController?.present(alert, animated: true)
    }
    
    // MARK: - Notification Permission
    
    func requestNotificationPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run {
                Task {
                    let settings = await center.notificationSettings()
                    await MainActor.run {
                        notificationPermissionStatus = settings.authorizationStatus
                    }
                }
            }
            return granted
        } catch {
            return false
        }
    }
    
    // MARK: - Convenience Methods
    
    var canUseCamera: Bool {
        return cameraPermissionStatus == .authorized
    }
    
    var canAccessPhotoLibrary: Bool {
        return photoLibraryPermissionStatus == .authorized || photoLibraryPermissionStatus == .limited
    }
    
    // MARK: - Unified Permission Status
    
    var cameraStatus: PermissionStatus {
        switch cameraPermissionStatus {
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .notDetermined
        }
    }
    
    var photoLibraryStatus: PermissionStatus {
        switch photoLibraryPermissionStatus {
        case .authorized, .limited:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .notDetermined
        }
    }
    
    var notificationStatus: PermissionStatus {
        switch notificationPermissionStatus {
        case .authorized, .provisional, .ephemeral:
            return .authorized
        case .denied:
            return .denied
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .notDetermined
        }
    }
}
