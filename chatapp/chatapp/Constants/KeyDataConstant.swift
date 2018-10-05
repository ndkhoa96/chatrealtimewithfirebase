//
//  Constants.swift
//  chatapp
//
//  Created by Khoa Nguyen on 9/27/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import Foundation

struct KEY_DATA {
    
    struct USER {
        static let ROOT = "users"
        static let EMAIL = "email"
        static let NAME = "name"
        static let FULL_NAME = "fullName"
        static let BACKGROUND_IMAGE_URL = "backgroundImageUrl"
        static let PROFILE_IMAGE_URL = "profileImageUrl"
        static let GENDER = "gender"
        static let BIRTHDAY = "birthDay"
        static let PHONE_NUMBER = "phoneNumber"
    }
    
    struct MESSAGE {
        static let ROOT = "messages"
        static let FROM_ID = "fromID"
        static let TO_ID = "toID"
        static let TEXT = "text"
        static let TIME_STAMP = "timeStamp"
        static let IMAGE_HEIGHT = "imageHeight"
        static let IMAGE_WIDTH = "imageWidth"
        static let IMAGE_URL = "imageUrl"
        static let VIDEO_URL = "videoUrl"
    }
    
    struct GROUP {
        static let ROOT = "groups"
        static let NAME = "name"
        static let HOST_ID = "hostId"
        static let GROUP_IMAGE_URL = "groupImageUrl"
    }
    
    struct USER_MESSAGES {
        static let ROOT = "user-messages"
    }
    
    struct USER_GROUPS {
        static let ROOT = "user-groups"
    }
    
    struct USER_IMAGES {
        static let ROOT = "user-images"
    }
    
    struct GROUP_MESSAGES {
        static let ROOT = "group-messages"
    }
    
    struct GROUP_MEMBERS {
        static let ROOT = "group-members"
    }
    
    struct STORAGE {
        static let BACKGROUND_IMAGES = "background_images"
        static let GROUP_IMAGES = "groups_images"
        static let MESSAGE_IMAGES = "message_images"
        static let MESSAGE_VIDEOS = "message_videos"
        static let PROFILE_IMAGES = "profile_images"
        static let USER_IMAGES = "user_images"

    }
}

