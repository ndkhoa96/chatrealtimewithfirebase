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
        self.email = values["email"] as? String
        self.name = values["name"] as? String
        self.profileImageUrl = values["profileImageUrl"] as? String
        self.fullName = values["fullName"] as? String
        self.gender = values["gender"] as? String
        self.birthDay = values["birthDay"] as? String
        self.phoneNumber = values["phoneNumber"] as? String
        self.backgroundImageUrl = values["backgroundImageUrl"] as? String
    }
}
