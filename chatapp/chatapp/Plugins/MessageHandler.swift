//
//  MessageHandler.swift
//  AloOpen
//
//  Created by Khoa Nguyen on 2/28/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage

protocol MessageReceivedDelegate: class{
    func messageReceived(senderID: String,senderName: String, text: String)
    func mediaReceived(senderID: String,senderName: String, url: String)
}


enum UploadType {
    case video
    case photo

}

class MessagesHandler{
    static let share = MessagesHandler()
    
    private init(){
        
    }
    
    weak var delegate: MessageReceivedDelegate?
    
    func uploadPhotoMessage(selectedImageFromPicker: UIImage, onComplete: @escaping (_ imageUrl: String?, _ error: String?) -> ()){
                
        uploadToFireBaseStoragesUsingImage(image: selectedImageFromPicker) { (imageUrl, error) in
            if error != nil {
                onComplete(nil, error)
                return
            }
            onComplete(imageUrl, nil)
            
            //self.sendMessageWithImageUrl(imageUrl: imageUrl, image: selectedImage)
        }
        
    }
    
    func uploadToFireBaseStoragesUsingImage(image: UIImage, completion: @escaping (_ imageUrl: String?, _ error: String?) -> ()){
        let imageName = NSUUID().uuidString
        let storageRef = StorageProvider.shared.messages_images .child(imageName)
        
        if let data = image.jpegData(compressionQuality: 0.1){
            storageRef.putData(data, metadata: nil, completion: { (metadata, error) in
                
                if error != nil{
                    print("Fail to upload image", error!)
                    completion(nil, error?.localizedDescription)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString{
                    completion(imageUrl, nil)
                }
                
            })
        }
    }
    
//    func sendMessage(senderID: String, senderName: String, text: String){
//        let data:Dictionary<String,Any> = [Constants.SENDER_ID: senderID, Constants.SENDER_NAME: senderName, Constants.TEXT: text]
//
//        DBProvider.Instance.messagesRef.childByAutoId().setValue(data)
//
//    }
//    
//    func sendMediaMessage(senderID: String, senderName: String, url: String){
//        let data: NSDictionary = [Constants.SENDER_ID: senderID, Constants.SENDER_NAME: senderName, Constants.URL: url]
//        DBProvider.Instance.mediaMessagesRef.childByAutoId().setValue(data)
//    }
//
//    func sendMedia(image: Data?, video: URL?, senderID: String, senderName: String){
//        if image != nil{
//
//            DBProvider.Instance.imageStorageRef.child(senderID + "\(NSUUID().uuidString).jpg").putData(image!, metadata: nil){
//                (metadata: StorageMetadata?, err: Error?) in
//                if err != nil{
//
//                } else {
//                    self.sendMediaMessage(senderID: senderID, senderName: senderName, url: String(describing: metadata!.downloadURL()!))
//                }
//
//            }
//
//
//        } else {
//            DBProvider.Instance.videoStorageRef.child(senderID + "\(NSUUID().uuidString)").putFile(from: video!, metadata: nil){
//                (metadata: StorageMetadata?, err: Error?) in
//                if err != nil {
//
//                }else{
//                    self.sendMediaMessage(senderID: senderID, senderName: senderName, url: String( describing: metadata!.downloadURL()!))
//                }
//            }
//        }
    
//    }
    
//    func observeMessages(){
//        DBProvider.Instance.messagesRef.observe(DataEventType.childAdded){ (snapshot: DataSnapshot) in
//            if let data = snapshot.value as? NSDictionary{
//                if let senderID = data[Constants.SENDER_ID] as? String{
//                    if let senderName = data[Constants.SENDER_NAME] as? String{
//                        if let text = data[Constants.TEXT] as? String {
//                            self.delegate?.messageReceived(senderID: senderID, senderName: senderName, text: text)
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    func obsersveMediaMessages(){
//        DBProvider.Instance.mediaMessagesRef.observe(DataEventType.childAdded){
//            (snapshot: DataSnapshot) in
//
//            if let data = snapshot.value as? NSDictionary{
//                if let id = data[Constants.SENDER_ID] as? String{
//                    if let name = data[Constants.SENDER_NAME] as? String{
//                        if let fileURL = data[Constants.URL] as? String{
//                            self.delegate?.mediaReceived(senderID: id, senderName: name, url: fileURL)
//                        }
//                    }
//                }
//            }
//        }
//    }

}
