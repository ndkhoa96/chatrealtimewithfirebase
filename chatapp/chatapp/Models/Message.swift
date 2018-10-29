//
//  Message.swift
//  chatapp
//
//  Created by Khoa Nguyen on 3/23/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    var fromID: String?
    var toID: String?
    var text: String?
    var timeStamp: NSNumber?
    var imageUrl: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    var videoUrl: String?
    
    init(values: [String: AnyObject]) {
        super.init()
        self.fromID = values[KEY_DATA.MESSAGE.FROM_ID] as? String
        self.toID = values[KEY_DATA.MESSAGE.TO_ID] as? String
        self.text = values[KEY_DATA.MESSAGE.TEXT] as? String
        self.timeStamp = values[KEY_DATA.MESSAGE.TIME_STAMP] as? NSNumber
        self.imageUrl = values[KEY_DATA.MESSAGE.IMAGE_URL] as? String
        self.imageHeight = values[KEY_DATA.MESSAGE.IMAGE_HEIGHT] as? NSNumber
        self.imageWidth = values[KEY_DATA.MESSAGE.IMAGE_WIDTH] as? NSNumber
        self.videoUrl = values[KEY_DATA.MESSAGE.VIDEO_URL] as? String
    }
    
    func chatPartnerId() -> String? {
        return fromID == AuthProvider.shared.currentUserID ? toID : fromID
    }

}
