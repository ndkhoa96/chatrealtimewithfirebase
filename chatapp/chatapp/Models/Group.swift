//
//  Group.swift
//  chatapp
//
//  Created by Khoa Nguyen on 6/17/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit

class Group: NSObject {
    var id:String?
    var name:String?
    var groupImageUrl:String?
    var hostId: String?
    
    init(values: [String: AnyObject]) {
        self.name = values[KEY_DATA.GROUP.NAME] as? String
        self.groupImageUrl = values[KEY_DATA.GROUP.GROUP_IMAGE_URL] as? String
        self.hostId = values[KEY_DATA.GROUP.HOST_ID] as? String
    }
}
