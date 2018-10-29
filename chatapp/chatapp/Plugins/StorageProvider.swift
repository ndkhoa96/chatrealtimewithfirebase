//
//  StorageProvider.swift
//  chatapp
//
//  Created by Khoa Nguyen on 10/1/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import Foundation
import FirebaseStorage

class StorageProvider {
    
    static let shared = StorageProvider()
    
    private init(){
    }
    
    //MARK: STORAGE
    var reference: StorageReference {
        return Storage.storage().reference()
    }
    
    var groupsImagesReference: StorageReference {
        return reference.child(KEY_DATA.STORAGE.GROUP_IMAGES)
    }
    
    var backgroundImagesReference: StorageReference {
        return reference.child(KEY_DATA.STORAGE.BACKGROUND_IMAGES)
    }
    
    var messagesVideosReference: StorageReference {
        return reference.child(KEY_DATA.STORAGE.MESSAGE_VIDEOS)
    }
    
    var messagesImagesReference: StorageReference {
        return reference.child(KEY_DATA.STORAGE.MESSAGE_IMAGES)
    }
    
    var profileImagesReference: StorageReference {
        return reference.child(KEY_DATA.STORAGE.PROFILE_IMAGES)
    }
    
    var userImagesReference: StorageReference {
        return reference.child(KEY_DATA.STORAGE.USER_IMAGES)
    }
   
}
