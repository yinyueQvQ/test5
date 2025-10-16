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

class PermissionManager: ObservableObject {
    
    @Published var cameraPermissionStatus: AVAuthorizationStatus = .notDetermined
    @Published var photoLibraryPermissionStatus: PHAuthorizationStatus = .notDetermined
    
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
    
    // MARK: - Convenience Methods
    
    var canUseCamera: Bool {
        return cameraPermissionStatus == .authorized
    }
    
    var canAccessPhotoLibrary: Bool {
        return photoLibraryPermissionStatus == .authorized || photoLibraryPermissionStatus == .limited
    }
}
