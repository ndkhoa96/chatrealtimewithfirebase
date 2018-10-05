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
    case gallery
    case camera
}

class GallaryPicker {
    
    static let shared = GallaryPicker()
    
    private init(){
        
    }
    
    private var imagePickerController = UIImagePickerController()
    
    
//    static func getInstance() -> GallaryPicker{
//        
//        if shared.imagePickerController == nil {
//            shared.imagePickerController = UIImagePickerController()
//        }
//        
//        return shared
//    }
    
    func open(_ type: TypePicker, from controller: UIViewController) {
        
        switch type {
        case .camera:
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                
                self.imagePickerController.sourceType = UIImagePickerController.SourceType.camera
        
            }
            else {
                let alertWarning = UIAlertController(title:"Warning", message: "You don't have camera", preferredStyle: .alert)
                let actionOk = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alertWarning.addAction(actionOk)
                
                controller.present(alertWarning, animated: true, completion: nil)
                return
            }
        case .gallery:
            self.imagePickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
   
        }
        
        self.imagePickerController.delegate = controller as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
        self.imagePickerController.allowsEditing = true
        controller.present(self.imagePickerController, animated: true, completion: nil)
        
       
    }

    
    
}
