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
    
    init(values: [String: AnyObject]) {
        super.init()
        self.fromID = values["fromID"] as? String
        self.toID = values["toID"] as? String
        self.text = values["text"] as? String
        self.timeStamp = values["timeStamp"] as? NSNumber
        self.imageUrl = values["imageUrl"] as? String
        self.imageHeight = values["imageHeight"] as? NSNumber
        self.imageWidth = values["imageWidth"] as? NSNumber
    }
    
    func chatPartnerId() -> String? {
        return fromID == Auth.auth().currentUser?.uid ? toID : fromID

    }
}
