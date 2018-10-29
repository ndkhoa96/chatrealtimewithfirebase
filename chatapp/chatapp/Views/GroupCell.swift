//
//  GroupCell.swift
//  chatapp
//
//  Created by Khoa Nguyen on 6/21/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit
import Firebase

class GroupCell: UserCell{
    
    override func setupNameAndProfileImage(){
        
        self.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
        self.detailTextLabel?.textColor = UIColor.darkGray
        
        var name: String?
        var mess: String?
        
        if let messText = self.message?.text{
            mess = ": \(messText)"
        }else{
            mess = ": [MEDIA]"
        }
        
        if let id = message?.fromID{
            if id == AuthProvider.shared.currentUserID {
                name = "You"
                self.detailTextLabel?.text = name! + mess!
            }else{
                DBProvider.shared.usersReference.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dic = snapshot.value as? [String: AnyObject]
                    {
                        name = dic[KEY_DATA.USER.NAME] as? String
                        DispatchQueue.main.async {
                            self.detailTextLabel?.text = name! + mess!
                        }
                    }
                }, withCancel: nil)
            }
        }
 

        
        
    }
    

        
}
