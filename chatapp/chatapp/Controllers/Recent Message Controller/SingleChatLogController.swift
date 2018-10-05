//
//  ChatLogController.swift
//  chatapp
//
//  Created by Khoa Nguyen on 3/22/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class SingleChatLogController: BaseChatLogController {
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    func observeMessages(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let toId = user?.id
      
        
        let dbRef = Database.database().reference().child(KEY_DATA.USER_MESSAGES.ROOT).child(uid).child(toId!)
        dbRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child(KEY_DATA.MESSAGE.ROOT).child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String : AnyObject]
                    else{
                        return
                }
                let message = Message(values: dictionary)
                self.messages.append(message)
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()

                }
              
            }, withCancel: nil)
            
        }, withCancel: nil)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_infor"), style: .plain, target: self, action: #selector(showProfileUser))
        
        setupKeyboardObservers()

    }
    
    @objc func showProfileUser(){
        let persionnalPageController = PersionalPageViewController(collectionViewLayout: UICollectionViewFlowLayout())
        
        persionnalPageController.hidesBottomBarWhenPushed = true
        persionnalPageController.user = self.user
        navigationController?.pushViewController(persionnalPageController, animated: true)
    }
 
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)

    }

    @objc func handleKeyboardDidShow() {

        if self.messages.count > 0 {
            let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
            self.collectionView?.scrollToItem(at: indexPath , at: .bottom, animated: true)
        }
    }
    

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
     
        cell.chatLogController = self
        
        let message = messages[indexPath.row]
        cell.messages = message
        cell.textView.text = message.text

        setupCell(cell: cell, message: message)
        
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            cell.textView.isHidden = false
        } else if message.imageUrl != nil{
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        
        cell.playButton.isHidden = message.videoUrl == nil

        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height:CGFloat = 80
        
        let message = messages[indexPath.row]
        if let text = message.text {
           height = estimateFrameForText(text: text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }

    
    
//    func handleImageSelectedForUrl(url: URL){
//        let fileName = NSUUID().uuidString + ".mov"
//
//        let uploadTask = StorageProvider.shared.messages_videos
//            .child(fileName).putFile(from: url, metadata: nil) { (metadata, error) in
//            if error != nil {
//                print("Fail to upload of video: ", error!)
//                return
//            }
//
//            if let videoUrl = metadata?.downloadURL()?.absoluteString{
//                if let thumnailImage = self.getThumbnailImageForVideoUrl(fileUrl: url){
//                    print("thumnailImage width = \(thumnailImage.size.width)")
//                    print("thumnailImage height = \(thumnailImage.size.height)")
//                    self.uploadToFireBaseStoragesUsingImage(image: thumnailImage, completion: { (imageUrl) in
//                        let properties = [KEY_DATA.MESSAGE.IMAGE_URL: imageUrl, KEY_DATA.MESSAGE.IMAGE_WIDTH: thumnailImage.size.width, KEY_DATA.MESSAGE.IMAGE_HEIGHT: thumnailImage.size.height, KEY_DATA.MESSAGE.VIDEO_URL: videoUrl] as [String: AnyObject]
//                        self.sendMessageWithProperties(properties: properties)
//
//                    })
//                }
//            }
//        }
//
//        uploadTask.observe(.progress) { (snapshot) in
//            print(snapshot.progress?.completedUnitCount as Any)
//        }
//    }

    
    
    
    
//    @objc override func handleSend(){
//        if inputTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
//            return
//        }
//        
//        let properties = [KEY_DATA.MESSAGE.TEXT: inputTextField.text!] as [String: AnyObject]
//        
//        sendMessageWithProperties(properties: properties)
//        
//    }
    
//    func sendMessageWithImageUrl(imageUrl: String, image: UIImage){
//        
//        let properties = [KEY_DATA.MESSAGE.IMAGE_URL: imageUrl, KEY_DATA.MESSAGE.IMAGE_WIDTH: image.size.width, KEY_DATA.MESSAGE.IMAGE_HEIGHT: image.size.height] as [String: AnyObject]
//        
//        sendMessageWithProperties(properties: properties)
//        
//    }
   
    
    override func sendMessageWithProperties(properties: [String: AnyObject]){
        let dbRef = DBProvider.shared.messages
        let childRef = dbRef.childByAutoId()
        let toID = user?.id
        let fromID = AuthProvider.shared.userID
        let timeStamp = Int(NSDate().timeIntervalSince1970)
        
        var values = [KEY_DATA.MESSAGE.FROM_ID: fromID, KEY_DATA.MESSAGE.TO_ID: toID!, KEY_DATA.MESSAGE.TIME_STAMP: timeStamp] as [String: AnyObject]
        
        //append properties dictionary onto values
        //key $0 value $1
        properties.forEach({values[$0.0] = $0.1})
        
        childRef.updateChildValues(values) { (error, dbRef) in
            if error != nil{
                print(error!)
                return
            }
            
            self.inputTextField.text = nil

            let userMessagesRef = DBProvider.shared.user_messages.child(fromID).child(toID!)
            let messagesId = childRef.key
            userMessagesRef.updateChildValues([messagesId: 1])
            
            let recipientUserMessagesRef = DBProvider.shared.user_messages.child(toID!).child(fromID)
            recipientUserMessagesRef.updateChildValues([messagesId: 1])
            
        }
    }
 
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
