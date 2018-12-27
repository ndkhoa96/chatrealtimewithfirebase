//
//  MessageHandler.swift
//  AloOpen
//
//  Created by Khoa Nguyen on 2/28/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation


protocol FetchUserMessages: class {
    func dataReceived(messagesDictionary: [String : Message])
}

protocol FetchUserChatLog: class {
    func dataReceived(messages: [Message])
}

protocol FetchUserGroups: class {
    func dataReceived(groupDictionary: [String: Group], groupMessagesDictionary: [String : Message])
}

protocol FetchGroupMessages: class {
    func dataReceived(groupMessages: [Message])
}

class MessagesHandler: NSObject {
    //MARK: - SHARE INSTANCE
    static let shared = MessagesHandler()
    
    //MARK: - INIT
    private override init(){
        
    }
    
    //MARK: - PROPERTIES
    weak var delegateUserMessages: FetchUserMessages?
    weak var delegateUserChatLog: FetchUserChatLog?
    weak var delegateUserGroups: FetchUserGroups?
    weak var delegateGroupMessages: FetchGroupMessages?
    
    private var messagesDictionary = [String : Message]()
    private var groupMessagesDictionary = [String: Message]()
    private var groupDictionary = [String: Group]()
    
    //MARK: - HANDLE UPLOAD MEDIA
    func uploadImageMessage(image: UIImage, completion: @escaping (_ imageUrl: String?, _ error: Error?) -> ()) {
        let imageName = NSUUID().uuidString
        let storageRef = StorageProvider.shared.messagesImagesReference.child(imageName)
        
        if let data = image.jpegData(compressionQuality: CONSTANT.IMAGE.COMPRESSION){
            storageRef.putData(data, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    completion(nil, error)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString{
                    completion(imageUrl, nil)
                }
            })
        }
    }
    
    func uploadVideoMessage(url: URL, completion: @escaping (_ videoUrl: String?, _ thumbnailUrl: String?, _ error: Error?) -> Void) {
        let fileName = NSUUID().uuidString + CONSTANT.VIDEO.TYPE
        
        let uploadTask = StorageProvider.shared.messagesVideosReference.child(fileName).putFile(from: url, metadata: nil) { (metadata, error) in
                if error != nil {
                    completion(nil,nil,error)
                    return
                }
                
                if let videoUrl = metadata?.downloadURL()?.absoluteString{
                    if let thumnailImage = self.getThumbnailImageForVideoUrl(fileUrl: url) {
                        self.uploadImageMessage(image: thumnailImage, completion: { (thumbnailUrl, err) in
                            if err != nil {
                                completion(nil,nil,err)
                                return
                            }
                            completion(videoUrl,thumbnailUrl,nil)
                        })              
                    }
                }
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            print(snapshot.progress?.completedUnitCount as Any)
        }
    }
    
    func getThumbnailImageForVideoUrl(fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            
            return UIImage(cgImage: thumbnailCGImage)
        } catch let err {
            print(err)
        }
        
        return nil
    }
 
    //MARK: - HANDLE USER CHAT
    func observeUserMessages() {
        messagesDictionary.removeAll()
        guard let uid = AuthProvider.shared.currentUserID else { return }

        observedUserMessagesChildAdd(uid: uid)
        observedUserMessagesChildRemove(uid: uid)
    }
    
    private func observedUserMessagesChildAdd(uid: String) {
        DBProvider.shared.userMessagesReference.child(uid).observe(.childAdded, with: { (snapshot) in
            let partnerId = snapshot.key
            DBProvider.shared.userMessagesReference.child(uid).child(partnerId).observe(.childAdded, with: { (snapshot) in
                let messageId = snapshot.key
                self.fetchUserMessageWithMessageId(messageId: messageId)
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    private func observedUserMessagesChildRemove(uid: String) {
        DBProvider.shared.userMessagesReference.child(uid).observe(.childRemoved, with: { (snapshot) in
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.delegateUserMessages?.dataReceived(messagesDictionary: self.messagesDictionary)
        }, withCancel: nil)
    }
    
    
    private func fetchUserMessageWithMessageId(messageId: String) {
        let messagesRef = DBProvider.shared.messagesReference.child(messageId)
        messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let message = Message(values: dictionary)
                
                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                }
                
                self.delegateUserMessages?.dataReceived(messagesDictionary: self.messagesDictionary)
            }
        }, withCancel: nil)
    }
    
    func deleteUserMessages(with chatPartnerId: String, completion: @escaping (_ error : Error?) -> ()) {
        guard let uid =  AuthProvider.shared.currentUserID else { return }
        
        DBProvider.shared.userMessagesReference.child(uid).child(chatPartnerId).removeValue { (error, ref) in
            if error != nil {
                completion(error!)
                return
            }
            self.messagesDictionary.removeValue(forKey: chatPartnerId)
            self.delegateUserMessages?.dataReceived(messagesDictionary: self.messagesDictionary)
            completion(nil)
        }
    }
    
    func observeUserChatLog(recipientID: String) {
        guard let uid = AuthProvider.shared.currentUserID else { return }
        var messages = [Message]()

        DBProvider.shared.userMessagesReference.child(uid).child(recipientID).observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            DBProvider.shared.messagesReference.child(messageId).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String : AnyObject] else { return }
                let message = Message(values: dictionary)
                messages.append(message)
                
                self.delegateUserChatLog?.dataReceived(messages: messages)
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    func sendDirectUserMessage(toID recipientID: String, properties: [String: AnyObject], completion: @escaping (_ error: Error?) -> () ) {
        let dbRef = DBProvider.shared.messagesReference
        let childRef = dbRef.childByAutoId()
        let fromID = AuthProvider.shared.currentUserID
        let timeStamp = Int(NSDate().timeIntervalSince1970)
        
        var values = [KEY_DATA.MESSAGE.FROM_ID: fromID!, KEY_DATA.MESSAGE.TO_ID: recipientID, KEY_DATA.MESSAGE.TIME_STAMP: timeStamp] as [String: AnyObject]
        
        //append properties dictionary onto values
        //key $0 value $1
        properties.forEach({values[$0.0] = $0.1})
        
        childRef.updateChildValues(values) { (error, dbRef) in
            if error != nil{
                completion(error)
                return
            }
            
            let userMessagesRef = DBProvider.shared.userMessagesReference.child(fromID!).child(recipientID)
            let messagesId = childRef.key
            userMessagesRef.updateChildValues([messagesId: 1])
            
            let recipientUserMessagesRef = DBProvider.shared.userMessagesReference.child(recipientID).child(fromID!)
            recipientUserMessagesRef.updateChildValues([messagesId: 1])
            completion(nil)
        }
    }
    
    
    //MARK: - HANDLE CHAT GROUP
    func observeUserGroups() {
        groupMessagesDictionary.removeAll()
        groupDictionary.removeAll()
        guard let uid = AuthProvider.shared.currentUserID else { return }
        let dbRef = DBProvider.shared.userGroupsReference.child(uid)
        
        dbRef.observe(.childAdded, with: { (snapshot) in
            let groupId = snapshot.key
            DBProvider.shared.groupsReference.child(groupId).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let group = Group(values: dictionary)
                    group.id = snapshot.key
                    self.groupDictionary[group.id!] = group
                }
            }, withCancel: nil)
            self.fetchGroupMessages(groupId: groupId)
        }, withCancel: nil)
        
        dbRef.observe(.childRemoved, with: { (snapshot) in
            self.groupMessagesDictionary.removeValue(forKey: snapshot.key)
            self.groupDictionary.removeValue(forKey: snapshot.key)
            self.delegateUserGroups?.dataReceived(groupDictionary: self.groupDictionary, groupMessagesDictionary: self.groupMessagesDictionary)
        }, withCancel: nil)
    }
    
    private func fetchGroupMessages(groupId: String) {
        DBProvider.shared.groupMessagesReference.child(groupId).observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            DBProvider.shared.messagesReference.child(messageId).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
                    let message = Message(values: dictionary)
                    
                    if let groupId = message.toID {
                        self.groupMessagesDictionary[groupId] = message
                        self.delegateUserGroups?.dataReceived(groupDictionary: self.groupDictionary, groupMessagesDictionary: self.groupMessagesDictionary)
                    }
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    func observeGroupMessages(groupId: String) {
        var groupMessages = [Message]()
        
        DBProvider.shared.groupMessagesReference.child(groupId).observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            DBProvider.shared.messagesReference.child(messageId).observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String : AnyObject] else { return }
                let message = Message(values: dictionary)
                groupMessages.append(message)
                self.delegateGroupMessages?.dataReceived(groupMessages: groupMessages)

            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    func sendDirectGroupMessage(groupID: String, properties: [String: AnyObject], completion: @escaping (_ error: Error?) -> () ) {
        guard let fromID = AuthProvider.shared.currentUserID else { return }
        let dbRef = DBProvider.shared.messagesReference
        let childRef = dbRef.childByAutoId()
        let timeStamp = Int(NSDate().timeIntervalSince1970)
        var values = [KEY_DATA.MESSAGE.FROM_ID: fromID as AnyObject, KEY_DATA.MESSAGE.TO_ID: groupID, KEY_DATA.MESSAGE.TIME_STAMP: timeStamp] as [String: AnyObject]
        
        //append properties dictionary onto values
        //key $0 value $1
        properties.forEach({values[$0.0] = $0.1})
        
        childRef.updateChildValues(values) { (error, dbRef) in
            if error != nil{
                completion(error)
                return
            }
            
            let messagesId = childRef.key
            let groupMessagesRef = DBProvider.shared.groupMessagesReference.child(groupID)
            groupMessagesRef.updateChildValues([messagesId: 1])
            completion(nil)
        }
    }
    
    func observeGroupMembersChildRemove(groupId: String, completion: @escaping (_ removeId: String?) -> ()) {
        DBProvider.shared.groupMembersReference.child(groupId).observe(.childRemoved, with: { (snapshot) in
            completion(snapshot.key)
        }, withCancel: nil)
    }
    
    
}
