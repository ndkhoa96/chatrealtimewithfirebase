//
//  GallaryPicker.swift
//  chatapp
//
//  Created by Khoa Nguyen on 10/4/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit
import MobileCoreServices

enum TypePicker {
    case photo
    case video
    case camera
}

class GallaryPicker {
    
    //MARK: - SHARE INSTANCE
    static let shared = GallaryPicker()
    
    //MARK: - CONSTANTS
    struct Constants {
        static let cameraTitle = "Open Camera"
        static let photoTitle = "Photo Gallery"
        static let videoTitle =  "Video Gallery"
        static let cancelTitle = "Cancel"
        static let okTitle = "Ok"
        static let warningTitle = "Warning"
        static let noCameraMessage = "You don't have camera"
    }
    
    
    
    //MARK: - PROPERTIES
    private var imagePickerController = UIImagePickerController()
    private var alertPhotoCamera = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
    private var alertPhotoVideoCamera = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
    private var controller: UIViewController?
    
    
    //MARK: - INIT
    private init(){
        let photoAction = UIAlertAction(title: Constants.photoTitle, style: .default, handler: { (alert) in
            self.open(.photo, from: self.controller!)
        })
        
        let videoAction = UIAlertAction(title: Constants.videoTitle, style: .default, handler: { (alert) in
            self.open(.video, from: self.controller!)
        })
        
        let cameraAction = UIAlertAction(title: Constants.cameraTitle, style: .default, handler: { (alert) in
            self.open(.camera, from: self.controller!)
        })
 
        alertPhotoVideoCamera.addAction(photoAction)
        alertPhotoVideoCamera.addAction(videoAction)
        alertPhotoVideoCamera.addAction(cameraAction)
        
        alertPhotoCamera.addAction(photoAction)
        alertPhotoCamera.addAction(cameraAction)
    }
    
    //MARK: - METHOD
    func showActionPhotoCamera(from controller: UIViewController, withCancel: ((Bool) -> Void)?) {
        self.controller = controller
        if alertPhotoCamera.actions.count < 3 {
            let cancelAction = UIAlertAction(title: Constants.cancelTitle, style: .default, handler: { (alert) in
                withCancel?(true)
            })
            alertPhotoCamera.addAction(cancelAction)
        }
        controller.present(alertPhotoCamera, animated: true, completion: nil)
    }
    
    func showActionPhotoVideoCamera(from controller: UIViewController, withCancel: ((Bool) -> Void)?) {
        self.controller = controller
        if alertPhotoVideoCamera.actions.count < 4 {
            let cancelAction = UIAlertAction(title: Constants.cancelTitle, style: .default, handler: { (alert) in
                withCancel?(true)
            })
            alertPhotoVideoCamera.addAction(cancelAction)
        }
        controller.present(alertPhotoVideoCamera, animated: true, completion: nil)
    }
    
    private func open(_ type: TypePicker, from controller: UIViewController) {
        switch type {
        case .camera:
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePickerController.sourceType = .camera
                self.imagePickerController.mediaTypes = [kUTTypeImage as String]
            }
            else {
                AlertMessage.shared.show(tilte: Constants.warningTitle, message: Constants.noCameraMessage, from: controller)
                return
            }
        case .video:
            self.imagePickerController.sourceType = .photoLibrary
            self.imagePickerController.mediaTypes = [kUTTypeVideo as String, kUTTypeMovie as String]
        case .photo:
            self.imagePickerController.sourceType = .photoLibrary
            self.imagePickerController.mediaTypes = [kUTTypeImage as String]
        }
        
        self.imagePickerController.delegate = controller as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        self.imagePickerController.allowsEditing = true
        
        controller.present(self.imagePickerController, animated: true, completion: nil)
    }
}
