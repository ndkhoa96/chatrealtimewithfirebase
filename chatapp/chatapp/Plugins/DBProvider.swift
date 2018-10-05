//
//  DBProvider.swift
//  AloOpen
//
//  Created by Khoa Nguyen on 2/7/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

@objc protocol FetchUsersData: class {
    @objc optional func getCurrentUser(user: User)
    @objc optional func getAllUser(users: [User])
}

class DBProvider {

    class var shared: DBProvider {
        struct Static {
            static var instance = DBProvider()
        }
        return Static.instance
    }
    
    weak var delegate: FetchUsersData?
    
    private init(){
    }
    
    
    //MARK: DATABASE
    var reference: DatabaseReference {
        return Database.database().reference()
    }
    
    var users: DatabaseReference {
        return reference.child(KEY_DATA.USER.ROOT)
    }
    
    var messages: DatabaseReference {
        return reference.child(KEY_DATA.MESSAGE.ROOT)
    }
    
    var groups: DatabaseReference {
        return reference.child(KEY_DATA.GROUP.ROOT)
    }
    
    var user_messages: DatabaseReference {
        return reference.child(KEY_DATA.USER_MESSAGES.ROOT)
    }
    
    var user_images: DatabaseReference {
        return reference.child(KEY_DATA.USER_IMAGES.ROOT)
    }
    
    var user_groups: DatabaseReference {
        return reference.child(KEY_DATA.USER_GROUPS.ROOT)
    }
    
    var group_members: DatabaseReference {
        return reference.child(KEY_DATA.GROUP_MEMBERS.ROOT)
    }
    
    var group_messages: DatabaseReference {
        return reference.child(KEY_DATA.GROUP_MESSAGES.ROOT)
    }

    func getCurrentUser(){
        
        let uid = AuthProvider.shared.userID
        print("uid: ", uid)
        DBProvider.shared.users.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                
                let user = User(values: dictionary)
                user.id = snapshot.key
                self.delegate?.getCurrentUser!(user: user)
                
            }
            
        }, withCancel: nil)
        
//        usersRef.observeSingleEvent(of: DataEventType.value){
//            (snapshot: DataSnapshot) in
//            if let myContacts = snapshot.value as? NSDictionary{
//                for(key,value) in myContacts{
//                    if let contactData = value as? NSDictionary{
//                        if let email = contactData[Constants.EMAIL] as? String {
//                                let id = key as! String
//                                let newContact = Contact(id: id, email: email)
//                                contacts.append(newContact)
//
//                        }
//                    }
//                }
//            }
//            self.delegate?.dataReceived(users: contacts)
//        }
   }
}
