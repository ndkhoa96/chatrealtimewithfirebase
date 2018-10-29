//
//  OtherConstant.swift
//  chatapp
//
//  Created by Khoa Nguyen on 10/4/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit

struct KEY_INFO {
    struct IMAGE {
        static let EDIT = "UIImagePickerControllerEditedImage"
        static let ORIGIN = "UIImagePickerControllerOriginalImage"
    }
}

struct CONSTANT {
    struct IMAGE {
        static let COMPRESSION: CGFloat = 0.1
        static let TYPE = ".jpg"
    }
    
    struct VIDEO {
        static let COMPRESSION: CGFloat = 0.1
        static let TYPE = ".mov"
    }
    
    struct TIME {
        static let REFRESH = 0.1
    }
}

struct RATIO {
    static let THREE_PART: CGFloat = 1/3
    static let TWO_PART: CGFloat = 1/2
}

struct ERROR {
    //Error Connection
    struct CONNECTION {
        struct E001 {
            static let TITLE = "UNSUCCESSFUL"
            static let MESSAGE = "Please check your connection!"
        }
    }
    
    //Error Login and Register
    struct LOGIN_REGISTER {
        struct E002 {
            static let TITLE = "UNSUCCESSFUL"
            static let MESSAGE = "Invalid email address!"
        }
        
        struct E003 {
            static let TITLE = "UNSUCCESSFUL"
            static let MESSAGE = "Wrong password!"
        }
        
        struct E004 {
            static let TITLE = "UNSUCCESSFUL"
            static let MESSAGE = "User is not exist!"
        }
        
        struct E005 {
            static let TITLE = "UNSUCCESSFUL"
            static let MESSAGE = "Password should be at least 6 characters!"
        }
        
        struct E006 {
            static let TITLE = "UNSUCCESSFUL"
            static let MESSAGE = "Email is already have registered!"
        }

    }
    
    // Error db

    struct DATA {
        struct REMOVE {
            static let TITLE = "UNSUCCESSFUL"
            static let MESSAGE = "Can not delete this conversation!"
        }
        
        struct UPLOAD {
            static let TITLE = "UNSUCCESSFUL"
            static let MESSAGE = "Can not upload data to server!"
        }
        
        struct SEND {
            static let TITLE = "UNSUCCESSFUL"
            static let MESSAGE = "Can not send message!"
        }
    }
}
