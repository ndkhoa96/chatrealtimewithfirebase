//
//  StorageProvider.swift
//  chatapp
//
//  Created by Khoa Nguyen on 10/1/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage


class StorageProvider {
    
    class var shared: StorageProvider {
        struct Static {
            static var instance = StorageProvider()
        }
        return Static.instance
    }
    //weak var delegate: FetchData?
    
    private init(){
    }
    
    //MARK: STORAGE
    var reference: StorageReference {
        return Storage.storage().reference()
    }
    
    var groups_images: StorageReference {
        return reference.child(KEY_DATA.STORAGE.GROUP_IMAGES)
    }
    
    var background_images: StorageReference {
        return reference.child(KEY_DATA.STORAGE.BACKGROUND_IMAGES)
    }
    
    var messages_videos: StorageReference {
        return reference.child(KEY_DATA.STORAGE.MESSAGE_VIDEOS)
    }
    
    var messages_images: StorageReference {
        return reference.child(KEY_DATA.STORAGE.MESSAGE_IMAGES)
    }
    
    var profile_images: StorageReference {
        return reference.child(KEY_DATA.STORAGE.PROFILE_IMAGES)
    }
    
    var user_images: StorageReference {
        return reference.child(KEY_DATA.STORAGE.USER_IMAGES)
    }
   
}
