//
//  DBProvider.swift
//  AloOpen
//
//  Created by Khoa Nguyen on 2/7/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit
import FirebaseDatabase

protocol FetchAllUserData: class {
    func dataReceived(users: [User])
}

class DBProvider: NSObject {
    //MARk: - SHARE INSTANCE
    static let shared = DBProvider()
    
    //MARK: - INIT
    private override init(){}
    
    //MARK: - PROPERTIES
    weak var delegateAllUser: FetchAllUserData?
    
    //MARK: - REFERENCE DATABASE PROPERTIES
    var reference: DatabaseReference {
        return Database.database().reference()
    }
    
    var usersReference: DatabaseReference {
        return reference.child(KEY_DATA.USER.ROOT)
    }
    
    var messagesReference: DatabaseReference {
        return reference.child(KEY_DATA.MESSAGE.ROOT)
    }
    
    var groupsReference: DatabaseReference {
        return reference.child(KEY_DATA.GROUP.ROOT)
    }
    
    var userMessagesReference: DatabaseReference {
        return reference.child(KEY_DATA.USER_MESSAGES.ROOT)
    }
    
    var userImagesReference: DatabaseReference {
        return reference.child(KEY_DATA.USER_IMAGES.ROOT)
    }
    
    var userGroupsReference: DatabaseReference {
        return reference.child(KEY_DATA.USER_GROUPS.ROOT)
    }
    
    var groupMembersReference: DatabaseReference {
        return reference.child(KEY_DATA.GROUP_MEMBERS.ROOT)
    }
    
    var groupMessagesReference: DatabaseReference {
        return reference.child(KEY_DATA.GROUP_MESSAGES.ROOT)
    }
    
    //MARK: GET USER DATA WITH ID
    func getUserWith(id: String, completion: @escaping (_ user: User?) -> ()) {
        usersReference.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let user = User(values: dictionary)
                user.id = snapshot.key
                completion(user)
            }
        }, withCancel: nil)
    }
    
    //MARK: GET ALL USER DATA
    func getAllUser() {
        guard let uid =  AuthProvider.shared.currentUserID else { return }
        var usersData = [User]()
        
        usersReference.queryOrdered(byChild: KEY_DATA.USER.NAME).observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User(values: dictionary)
                user.id = snapshot.key
                
                if uid != user.id{
                    usersData.append(user)
                }
                
                self.delegateAllUser?.dataReceived(users: usersData)
            }
        }, withCancel: nil)
    }
    
    //MARK: HANDLE GROUP CHAT FUNCTION
    //Create Group
    func createGroupWith(name: String, image: UIImage, completion: @escaping (_ error: Error?) -> ()) {
        guard let uid = AuthProvider.shared.currentUserID else { return }
        let storageRef = StorageProvider.shared.groupsImagesReference.child("\(name)\(CONSTANT.IMAGE.TYPE)")
        if let uploadData = image.jpegData(compressionQuality: 0.1) {
            storageRef.putData(uploadData, metadata: nil, completion: { (metaData, error) in
                if error != nil{
                    completion(error)
                    return
                }
                if let groupImageUrl = metaData?.downloadURL()?.absoluteString {
                    let values = [KEY_DATA.USER.NAME: name, KEY_DATA.GROUP.GROUP_IMAGE_URL: groupImageUrl, KEY_DATA.GROUP.HOST_ID: uid]
                    let dbRefGroup = self.groupsReference.childByAutoId()
                    let keyAutoId = dbRefGroup.key
                    
                    dbRefGroup.updateChildValues(values, withCompletionBlock: { (err, ref) in
                        if err != nil {
                            completion(err)
                            return
                        }
                        self.updateUserGroupAndGroupMember(childId: uid, idGroup: keyAutoId, nameGroup: name)
                        completion(nil)
                    })
                }
            })
        }
    }
    
    private func updateUserGroupAndGroupMember(childId: String, idGroup: String, nameGroup: String) {
        let role = "admin"
        userGroupsReference.child(childId).updateChildValues([idGroup: role])
        groupMembersReference.child(idGroup).updateChildValues([childId: role])
        putSomeDataWhenFirstCreateGroup(childId: childId, idGroup: idGroup, nameGroup: nameGroup)
    }
    
    private func putSomeDataWhenFirstCreateGroup(childId: String, idGroup: String, nameGroup: String) {
        let dbRef = DBProvider.shared.messagesReference
        let childRef = dbRef.childByAutoId()
        let timeStamp = Int(NSDate().timeIntervalSince1970)
        let values = [KEY_DATA.MESSAGE.FROM_ID: childId,KEY_DATA.MESSAGE.TO_ID: idGroup , KEY_DATA.MESSAGE.TIME_STAMP: timeStamp, KEY_DATA.MESSAGE.TEXT: "Create the group - \(nameGroup)"] as [String: AnyObject]
        
        childRef.updateChildValues(values) { (error, dbRef) in
            if error != nil{
                print(error!)
                return
            }
            let messagesId = childRef.key
            let groupMessagesRef = DBProvider.shared.groupMessagesReference.child(idGroup)
            groupMessagesRef.updateChildValues([messagesId: 1])
            
        }
    }
    
    //Leave Group
    func userLeaveGroup(groupID: String, completion: @escaping (_ error: Error?) -> ()) {
        guard let uid = AuthProvider.shared.currentUserID else { return }
        groupMembersReference.child(groupID).child(uid).removeValue { (error, ref) in
            if error != nil {
                completion(error)
                return
            }
            self.userGroupsReference.child(uid).child(groupID).removeValue{ (error, ref) in
                if error != nil {
                    completion(error)
                    return
                }
                completion(nil)
            }
        }
    }
    
    //Delete Group
    func deleteGroup(groupID: String, completion: @escaping (_ error: Error?) -> ()) {
        groupMembersReference.child(groupID).observe(.childAdded, with: { (snapshot) in        self.userGroupsReference.child(snapshot.key).child(groupID).removeValue{ (error, ref) in
                if error != nil {
                    completion(error)
                    return
                }
            }
            self.groupsReference.child(groupID).removeValue { (error, ref) in
                if error != nil {
                    completion(error)
                    return
                }
                self.groupMembersReference.child(groupID).removeValue { (error, ref) in
                    if error != nil {
                        completion(error)
                        return
                    }
                    completion(nil)
                }
            }
        }, withCancel: nil)
    }
}
