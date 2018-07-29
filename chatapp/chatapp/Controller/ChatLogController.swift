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

class ChatLogController: BaseChatLogController {
    
    var user: User? {
        didSet {
            navigationItem.title = user?.name
            
            observeMessages()
        }
    }
    
    var messages = [Message]()
    
    func observeMessages(){
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id
            else{
                return
        }
        
        let dbRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        dbRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String : AnyObject]
                    else{
                        return
                }
                let message = Message(values: dictionary)
                self.messages.append(message)
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    if self.messages.count > 0 {
                        let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                        self.collectionView?.scrollToItem(at: indexPath , at: .bottom, animated: true)
                    }
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
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: Notification.Name.UIKeyboardDidShow, object: nil)

    }

    @objc func handleKeyboardDidShow(notification: Notification) {

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
    
    private func setupCell(cell: ChatMessageCell,message: Message){
        if let profileImageUrl = self.user?.profileImageUrl{
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        if message.fromID == Auth.auth().currentUser?.uid{
            //outgoing mess
            cell.bubbleView.backgroundColor = Theme.shared.blueColor
            cell.profileImageView.isHidden = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.bubbleViewRightAnchor?.isActive = true
        }else{
            //incoming mess
            cell.bubbleView.backgroundColor = Theme.shared.whiteColor
            cell.profileImageView.isHidden = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.bubbleViewRightAnchor?.isActive = false
        }
        
        if let messageImageUrl = message.imageUrl{
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = UIColor.clear
            cell.textView.isHidden = true
        } else {
            cell.messageImageView.isHidden = true
            cell.textView.isHidden = false
        }
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    private func estimateFrameForText(text: String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let videoUrl = info[UIImagePickerControllerMediaURL] as? URL{
            handleImageSelectedForUrl(url: videoUrl)
            
        }else {
            handleImageSelectedForInfo(info: info)
        }
        dismiss(animated: true, completion: nil)
       
       
    }
    func handleImageSelectedForUrl(url: URL){
        let fileName = NSUUID().uuidString + ".mov"

        let uploadTask = Storage.storage().reference().child("message_videos").child(fileName).putFile(from: url, metadata: nil) { (metadata, error) in
            if error != nil {
                print("Fail to upload of video: ", error!)
            }

            if let videoUrl = metadata?.downloadURL()?.absoluteString{
                if let thumnailImage = self.thumbnailImageForVideoUrl(fileUrl: url){
                    print("thumnailImage width = \(thumnailImage.size.width)")
                    print("thumnailImage height = \(thumnailImage.size.height)")
                    self.uploadToFireBaseStoragesUsingImage(image: thumnailImage, completion: { (imageUrl) in
                        let properties = ["imageUrl": imageUrl, "imageWidth": thumnailImage.size.width, "imageHeight": thumnailImage.size.height, "videoUrl": videoUrl] as [String: AnyObject]
                        self.sendMessageWithProperties(properties: properties)

                    })

                }
            }
        }
        
        uploadTask.observe(.progress) { (snapshot) in
            print(snapshot.progress?.completedUnitCount as Any)
        }
    }
    
    func thumbnailImageForVideoUrl(fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
             let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(1,60), actualTime: nil)
            
            return UIImage(cgImage: thumbnailCGImage)
        }catch let err {
            print(err)
        }
        
        return nil
        
    }
    
    func handleImageSelectedForInfo(info: [String: Any]){
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            uploadToFireBaseStoragesUsingImage(image: selectedImage) { (imageUrl) in
                self.sendMessageWithImageUrl(imageUrl: imageUrl, image: selectedImage)
            }
            
        }
    }
    
    private func uploadToFireBaseStoragesUsingImage(image: UIImage, completion: @escaping (_ imageUrl: String) -> ()){
        let imageName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("message_images").child(imageName)
        
        if let data = UIImageJPEGRepresentation(image, 0.1){
            storageRef.putData(data, metadata: nil, completion: { (metadata, error) in
                
                if error != nil{
                    print("Fail to upload image", error!)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString{
                    completion(imageUrl)
               //     self.sendMessageWithImageUrl(imageUrl: imageUrl, image: image)
                }
                
            })
        }
        
    }
    
    @objc override func handleSend(){
        if inputTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return
        }
        
        let properties = ["text": inputTextField.text!] as [String: AnyObject]
        
        sendMessageWithProperties(properties: properties)
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage){

        let properties = ["imageUrl": imageUrl, "imageWidth": image.size.width, "imageHeight": image.size.height] as [String: AnyObject]
        
        sendMessageWithProperties(properties: properties)

    }
    
    private func sendMessageWithProperties(properties: [String: AnyObject]){
        let dbRef = Database.database().reference().child("messages")
        let childRef = dbRef.childByAutoId()
        let toID = user?.id
        let fromID = Auth.auth().currentUser?.uid
        let timeStamp = Int(NSDate().timeIntervalSince1970)
        
        var values = ["fromID": fromID!, "toID": toID!, "timeStamp": timeStamp] as [String: AnyObject]
        
        //append properties dictionary onto values
        //key $0 value $1
        properties.forEach({values[$0.0] = $0.1})
        
        childRef.updateChildValues(values) { (error, dbRef) in
            if error != nil{
                print(error!)
                return
            }
            
            self.inputTextField.text = nil
            if self.messages.count > 0 {
                let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
                self.collectionView?.scrollToItem(at: indexPath , at: .bottom, animated: true)
            }
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromID!).child(toID!)
            let messagesId = childRef.key
            userMessagesRef.updateChildValues([messagesId: 1])
            
            let recipientUserMessagesRef = Database.database().reference().child("user-messages").child(toID!).child(fromID!)
            recipientUserMessagesRef.updateChildValues([messagesId: 1])
        }
    }
 
}
