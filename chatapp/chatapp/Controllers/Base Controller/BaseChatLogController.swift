//
//  BaseChatLogController.swift
//  chatapp
//
//  Created by Khoa Nguyen on 6/21/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit
import Firebase
import MobileCoreServices
import AVFoundation

class BaseChatLogController: UICollectionViewController, UICollectionViewDelegateFlowLayout  {
    
    //MARK: - PROPERTIES
    let cellId = "cellId"
    
    
    
    //MARK: - UI

    var startingFrame: CGRect?
    var blackBackground: UIView?
    var startingImageView: UIImageView?
    
    override var inputAccessoryView: UIView?{
        get{
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.placeholder = "Enter message..."
        
        return textField
    }()
    
    lazy var inputContainerView : UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 45)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = Theme.shared.whiteColor
        
        let uploadImageView = UIImageView()
        let image = UIImage(named: ASSETS.ICON.UPLOAD)
        uploadImageView.image = image
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.isUserInteractionEnabled = true
        
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        
        containerView.addSubview(uploadImageView)
        // upload ImageView constraints
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
        let sendButton = UIImageView()
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.image = UIImage(named: ASSETS.ICON.SEND)
        sendButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSend)))
        sendButton.isUserInteractionEnabled = true
        containerView.addSubview(sendButton)
        
        //sendButton constrains
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        containerView.addSubview(inputTextField)
        
        //inputTextField constrains
        inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
        inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true

        let separatorView = UIView()
        separatorView.backgroundColor = Theme.shared.lightGrayColor
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(separatorView)
        
        //separatorView constrains
        separatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
    
    //MARK: - VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
 
    }
    
    override func viewDidAppear(_ animated: Bool) {
        inputTextField.becomeFirstResponder()
    }
  
    //MARK: - SETUP VIEWS
    
    func setupViews(){
        collectionView?.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = Theme.shared.lightGrayColor
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
    }

    
    func setupCell(cell: ChatMessageCell,message: Message){
        
        if let fromId = message.fromID{
            DBProvider.shared.users.child(fromId).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let user = User(values: dictionary)
                    user.id = snapshot.key
                    cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: user.profileImageUrl!)
                }
            }, withCancel: nil)
        }
        
        if message.fromID == AuthProvider.shared.userID{
            //outgoing mess
            cell.bubbleView.backgroundColor = Theme.shared.outcommingMessageColor
            cell.profileImageView.isHidden = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.bubbleViewRightAnchor?.isActive = true
        }else{
            //incoming mess
            cell.bubbleView.backgroundColor = Theme.shared.incommingMessageColor
            cell.profileImageView.isHidden = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.bubbleViewRightAnchor?.isActive = false
        }
        
        if let messageImageUrl = message.imageUrl{
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = Theme.shared.incommingMessageColor
            cell.textView.isHidden = true
        } else {
            cell.messageImageView.isHidden = true
            cell.textView.isHidden = false
        }
    }
    
    
    //MARK: - HANDLE FUNCTION
    
    @objc func handleUploadTap(){

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)

        let actionGallery = UIAlertAction(title: "Open Gallery", style: .default) { (alert) in
            GallaryPicker.shared.open(.camera, from: self)
        }
        let actionCamera = UIAlertAction(title: "Open Camera", style: .default) { (alert) in
            GallaryPicker.shared.open(.gallery, from: self)
        }

        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(actionGallery)
        alert.addAction(actionCamera)
        alert.addAction(actionCancel)
        self.present(alert,animated: true)

    }
    
    func handleImageSelectedForInfo(info: [String: Any]){
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[KEY_INFO.IMAGE.EDIT] as? UIImage{
            selectedImageFromPicker = editedImage
        }else if let originalImage = info[KEY_INFO.IMAGE.ORIGIN] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            MessagesHandler.share.uploadPhotoMessage(selectedImageFromPicker: selectedImage) { (imageUrl, error) in
                
                if error != nil {
                    print("ERROR", error as Any)
                }
                
                self.sendMessageWithImageUrl(imageUrl: imageUrl!, image: selectedImage)
            }
        }
    }
    
    func sendMessageWithImageUrl(imageUrl: String, image: UIImage){
        
        let properties = [KEY_DATA.MESSAGE.IMAGE_URL: imageUrl, KEY_DATA.MESSAGE.IMAGE_WIDTH: image.size.width, KEY_DATA.MESSAGE.IMAGE_HEIGHT: image.size.height] as [String: AnyObject]
        
        sendMessageWithProperties(properties: properties)
        
    }
    
    func sendMessageWithProperties(properties: [String: AnyObject]){
        
    }
    
    
    func getThumbnailImageForVideoUrl(fileUrl: URL) -> UIImage? {
        let asset = AVAsset(url: fileUrl)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1,timescale: 60), actualTime: nil)
            
            return UIImage(cgImage: thumbnailCGImage)
        }catch let err {
            print(err)
        }
        
        return nil
        
    }

//    func uploadToFireBaseStoragesUsingImage(image: UIImage, completion: @escaping (_ imageUrl: String) -> ()){
//        let imageName = NSUUID().uuidString
//        let storageRef = Storage.storage().reference().child(KEY_DATA.STORAGE.MESSAGE_IMAGES).child(imageName)
//        
//        if let data = image.jpegData(compressionQuality: 0.1){
//            storageRef.putData(data, metadata: nil, completion: { (metadata, error) in
//                
//                if error != nil{
//                    print("Fail to upload image", error!)
//                    return
//                }
//                
//                if let imageUrl = metadata?.downloadURL()?.absoluteString{
//                    completion(imageUrl)
//                }
//                
//            })
//        }
//    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func estimateFrameForText(text: String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
   
    
    @objc func handleSend(){
        if inputTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return
        }
        
        let properties = [KEY_DATA.MESSAGE.TEXT: inputTextField.text!] as [String: AnyObject]
        
        sendMessageWithProperties(properties: properties)

    }
    
    func performZoomForImageView(startingImageView: UIImageView){
        inputTextField.resignFirstResponder()
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOutTap)))
        
        if let keyWindow = UIApplication.shared.keyWindow{
            
            blackBackground = UIView(frame: keyWindow.frame)
            blackBackground?.backgroundColor = UIColor.black
            blackBackground?.alpha = 0
            
            keyWindow.addSubview(blackBackground!)
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: ANIMATION.SLOW, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                self.blackBackground?.alpha = 1
                self.inputContainerView.alpha = 0
                
                // h2 = h1/w1 * w2
                let height = (self.startingFrame?.height)! / (self.startingFrame?.width)! * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
                
            }, completion: nil)
        }
    }
    
    @objc func handleZoomOutTap(tapGesture: UITapGestureRecognizer){

        if let zoomOutImageView = tapGesture.view{
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: ANIMATION.SLOW, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackground?.alpha = 0
                self.inputContainerView.alpha = 1
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
            
        }
    }
    
    
}
extension BaseChatLogController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}

extension BaseChatLogController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let videoUrl = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as? URL{
            //handleImageSelectedForUrl(url: videoUrl)
            
        }else {
            
            handleImageSelectedForInfo(info: info)
        }
        dismiss(animated: true, completion: nil)
        
        
    }
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
