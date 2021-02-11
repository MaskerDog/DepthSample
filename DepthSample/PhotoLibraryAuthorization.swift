//
//  PhotoLibraryAuthorization.swift
//  DepthSample
//
//  Created by npc on 2021/02/11.
//

import Photos

// 読み込みが必要
class PhotoLibraryAuthorization {
    static func ifAuthorizingExecute(handler:@escaping ()->()) {
        if #available(iOS 14, *) {
            switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
            // 許可を得ていない
            case .notDetermined:
                info("notDetermined")
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    switch status {
                    case .authorized, .limited:
                        handler()
                    case .notDetermined:
                        warning("re-NotDetermined")
                    case .restricted:
                        error("restricted")
                    case .denied:
                        warning("denied")
                    @unknown default:
                        error("unknown")
                    }
                }
            case .authorized, .limited:
                info("許可済み")
                handler()
                break;
            case .denied:
                info("非許可")
            case .restricted:
                error("restricted")
            default:
                warning("unknown")
            }
        
        } else {
            // iOS14以下の場合
        }
    }
}
