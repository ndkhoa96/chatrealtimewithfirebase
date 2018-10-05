//
//  GroupChatLogController.swift
//  chatapp
//
//  Created by Khoa Nguyen on 6/21/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class GroupChatLogController: BaseChatLogController {
    
    var group: Group? {
        didSet {
            navigationItem.title = group?.name
            observeMessages()
 
        }
    }

    
    var groupMessages = [Message]()
    
    func observeMessages(){
        guard let groupId = group?.id
            else{
                return
        }
        
        let dbRef = Database.database().reference().child(KEY_DATA.GROUP_MESSAGES.ROOT).child(groupId)
        dbRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child(KEY_DATA.MESSAGE.ROOT).child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String : AnyObject]
                    else{
                        return
                }
                let message = Message(values: dictionary)
                
                self.groupMessages.append(message)
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    if self.groupMessages.count > 0{
                        let indexPath = IndexPath(item: self.groupMessages.count - 1, section: 0)
                        self.collectionView?.scrollToItem(at: indexPath , at: .bottom, animated: true)
                    }
                }
     
            }, withCancel: nil)
        }, withCancel: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: ASSETS.ICON.SETTING), style: .plain, target: self, action: #selector(handleAddMember))

        setupKeyboardObservers() 
        inputAccessoryView?.becomeFirstResponder()

        DBProvider.shared.group_members.child((group?.id)!).observe(.childRemoved, with: { (snapshot) in
            print("Remove from Group key = ", snapshot.key)
            self.showNotificationWhenOutGroup()
            
        }, withCancel: nil)
    }
    
    func showNotificationWhenOutGroup(){
        
        let alert = UIAlertController(title: "Sorry", message: "You are blocked from this group!", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { (alert) in
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(action)
        
        self.present(alert,animated: true)
        
    }
    
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        
    }
    
    @objc func handleAddMember(){   
        if group?.hostId == AuthProvider.shared.userID {
            let managerMemberController = ManagerMemberController()
            managerMemberController.group = self.group
            let navController = UINavigationController(rootViewController: managerMemberController)
            
            present(navController, animated: true, completion: nil)
        }
        else{
            let membersController = MembersController()
            membersController.group = self.group
            let navController = UINavigationController(rootViewController: membersController)
            
            present(navController, animated: true, completion: nil)
        }
    }
    
    @objc func handleKeyboardDidShow(notification: Notification) {
        
        if self.groupMessages.count > 0 {
            let indexPath = IndexPath(item: self.groupMessages.count - 1, section: 0)
            self.collectionView?.scrollToItem(at: indexPath , at: .bottom, animated: true)
        }
    }

    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupMessages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
        
        cell.chatLogController = self
        
        let message = groupMessages[indexPath.row]

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
        
        let message = groupMessages[indexPath.row]
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: height)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
//        if let videoUrl = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as? URL{
//            handleImageSelectedForUrl(url: videoUrl)
//
//        }else {
//            handleImageSelectedForInfo(info: info)
//        }
//        dismiss(animated: true, completion: nil)
        
        
    }
    
//    func handleImageSelectedForUrl(url: URL){
//        let fileName = NSUUID().uuidString + ".mov"
//
//        let uploadTask = StorageProvider.shared.messages_videos.child(fileName).putFile(from: url, metadata: nil) { (metadata, error) in
//            if error != nil {
//                print("Fail to upload of video: ", error!)
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
    
//        uploadTask.observe(.progress) { (snapshot) in
//            print(snapshot.progress?.completedUnitCount as Any)
//        }
//    }

//    func handleImageSelectedForInfo(info: [String: Any]){
//        var selectedImageFromPicker: UIImage?
//
//        if let editedImage = info[KEY_INFO.IMAGE.EDIT] as? UIImage{
//            selectedImageFromPicker = editedImage
//        }else if let originalImage = info[KEY_INFO.IMAGE.ORIGIN] as? UIImage{
//            selectedImageFromPicker = originalImage
//        }
//
//        if let selectedImage = selectedImageFromPicker{
//            uploadToFireBaseStoragesUsingImage(image: selectedImage) { (imageUrl) in
//                self.sendMessageWithImageUrl(imageUrl: imageUrl, image: selectedImage)
//            }
//
//        }
//    }

    
//    override func handleSend(){
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
        let fromID = AuthProvider.shared.userID
        let toID = group?.id
        let timeStamp = Int(NSDate().timeIntervalSince1970)
        
        var values = [KEY_DATA.MESSAGE.FROM_ID: fromID,KEY_DATA.MESSAGE.TO_ID: toID! , KEY_DATA.MESSAGE.TIME_STAMP: timeStamp] as [String: AnyObject]
        
        //append properties dictionary onto values
        //key $0 value $1
        properties.forEach({values[$0.0] = $0.1})
        
        childRef.updateChildValues(values) { (error, dbRef) in
            if error != nil{
                print(error!)
                return
            }
            
            self.inputTextField.text = nil
            if self.groupMessages.count > 0 {
                let indexPath = IndexPath(item: self.groupMessages.count - 1, section: 0)
                self.collectionView?.scrollToItem(at: indexPath , at: .bottom, animated: true)
            }
            let messagesId = childRef.key
            let groupMessagesRef = Database.database().reference().child(KEY_DATA.GROUP_MESSAGES.ROOT).child(toID!)
            groupMessagesRef.updateChildValues([messagesId: 1])
            
            
        }
        
    }
    
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
