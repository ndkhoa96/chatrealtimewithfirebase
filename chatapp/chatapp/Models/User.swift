//
//  User.swift
//  chatapp
//
//  Created by Khoa Nguyen on 3/16/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit

class User: NSObject {
    var id:String?
    var email:String?
    var name:String?
    var profileImageUrl:String?
    var fullName:String?
    var gender:String?
    var birthDay:String?
    var phoneNumber:String?
    var backgroundImageUrl:String?
    
    
    init(values: [String: AnyObject]) {
        self.email = values[KEY_DATA.USER.EMAIL] as? String
        self.name = values[KEY_DATA.USER.NAME] as? String
        self.profileImageUrl = values[KEY_DATA.USER.PROFILE_IMAGE_URL] as? String
        self.fullName = values[KEY_DATA.USER.FULL_NAME] as? String
        self.gender = values[KEY_DATA.USER.GENDER] as? String
        self.birthDay = values[KEY_DATA.USER.BIRTHDAY] as? String
        self.phoneNumber = values[KEY_DATA.USER.PHONE_NUMBER] as? String
        self.backgroundImageUrl = values[KEY_DATA.USER.BACKGROUND_IMAGE_URL] as? String
    }
}
