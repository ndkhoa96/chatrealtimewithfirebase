//
//  BaseChatLogController.swift
//  chatapp
//
//  Created by Khoa Nguyen on 6/21/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit

class BaseChatLogController: UICollectionViewController {
    
    //MARK: - CONSTANT
    struct Constant {
        static let inputTxfPlaceHolder = "Enter message..."
    }
    
    //MARK: - PROPERTIES
    static var identifier: String {
        return String(describing: self)
    }

    //MARK: - UI
    var startingFrame: CGRect?
    var blackBackground: UIView?
    var startingImageView: UIImageView?
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.placeholder = Constant.inputTxfPlaceHolder
        return textField
    }()
    
    lazy var uploadImageView: UIImageView = {
        let uploadImageView = UIImageView()
        uploadImageView.image = UIImage(named: ASSETS.ICON.UPLOAD)
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
        return uploadImageView
    }()
    
    lazy var sendButton: UIImageView = {
        let sendButton = UIImageView()
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.image = UIImage(named: ASSETS.ICON.SEND)
        sendButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSend)))
        sendButton.isUserInteractionEnabled = true
        return sendButton
    }()
    
    var separatorView: UIView = {
        let separatorView = UIView()
        separatorView.backgroundColor = Theme.shared.lightGrayColor
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        return separatorView
    }()
    
    
    lazy var inputContainerView : UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 45)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = Theme.shared.whiteColor
        
        containerView.addSubview(uploadImageView)
        // upload ImageView constraints
        uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        
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
        
        containerView.addSubview(separatorView)
        //separatorView constrains
        separatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
    
    //MARK: - VIEW LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupKeyboardObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        inputTextField.becomeFirstResponder()
    }
    
    //MARK: OVERRIDE PROPERTIES
    override var inputAccessoryView: UIView?{
        get{
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }
    
    //MARK: - SETUP UI
    //setup collectionView
    func setupViews(){
        collectionView?.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = Theme.shared.lightGrayColor
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: BaseChatLogController.identifier)
        collectionView?.keyboardDismissMode = .interactive
    }

    //setup cell
    func setupCell(cell: ChatMessageCell, message: Message) {
        if let fromId = message.fromID{
            DBProvider.shared.getUserWith(id: fromId) { (user) in
                if let imageUrl = user?.profileImageUrl {
                    cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: imageUrl)
                }
            }
        }
        
        if message.fromID == AuthProvider.shared.currentUserID {
            //outgoing mess
            cell.bubbleView.backgroundColor = Theme.shared.outcommingMessageColor
            cell.profileImageView.isHidden = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.bubbleViewRightAnchor?.isActive = true
        } else {
            //incoming mess
            cell.bubbleView.backgroundColor = Theme.shared.incommingMessageColor
            cell.profileImageView.isHidden = false
            cell.bubbleViewLeftAnchor?.isActive = true
            cell.bubbleViewRightAnchor?.isActive = false
        }
        
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = Theme.shared.incommingMessageColor
            cell.textView.isHidden = true
        } else {
            cell.messageImageView.isHidden = true
            cell.textView.isHidden = false
        }
    }
    
    
    //MARK: - HANDLE UI
    func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    @objc func handleKeyboardDidShow() {
        
    }
    
    @objc func handleUploadTap() {
        GallaryPicker.shared.showActionPhotoVideoCamera(from: self, withCancel: nil)
    }
    
    func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }

    func performZoomForImageView(startingImageView: UIImageView) {
        inputTextField.resignFirstResponder()
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOutTap)))
        
        animateZoomIn(with: zoomingImageView)
    }
    
    private func animateZoomIn(with zoomingImageView: UIImageView) {
        if let keyWindow = UIApplication.shared.keyWindow {
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
    
    @objc func handleZoomOutTap(tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            animateZoomOut(with: zoomOutImageView)
        }
    }
    
    private func animateZoomOut(with zoomOutView: UIView) {
        UIView.animate(withDuration: ANIMATION.SLOW, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            zoomOutView.frame = self.startingFrame!
            self.blackBackground?.alpha = 0
            self.inputContainerView.alpha = 1
        }, completion: { (completed) in
            zoomOutView.removeFromSuperview()
            self.startingImageView?.isHidden = false
        })
    }
    
    //MARK: HANDLE IN DATABASE
    @objc func handleSend() {
        if (inputTextField.text?.isReallyEmpty)! {
            return
        }
        
        let properties = [KEY_DATA.MESSAGE.TEXT: inputTextField.text!] as [String: AnyObject]
        
        sendMessageWithProperties(properties: properties)
    }
    
    func handleImageSelectedForInfo(info: [String: Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[KEY_INFO.IMAGE.EDIT] as? UIImage {
            selectedImageFromPicker = editedImage
        }else if let originalImage = info[KEY_INFO.IMAGE.ORIGIN] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            MessagesHandler.shared.uploadImageMessage(image: selectedImage) { (imageUrl, error) in
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                self.sendMessageWithImageUrl(imageUrl: imageUrl!, image: selectedImage)
            }
        }
    }
    
    func sendMessageWithImageUrl(imageUrl: String, image: UIImage) {
        let properties = [KEY_DATA.MESSAGE.IMAGE_URL: imageUrl, KEY_DATA.MESSAGE.IMAGE_WIDTH: image.size.width, KEY_DATA.MESSAGE.IMAGE_HEIGHT: image.size.height] as [String: AnyObject]
        
        sendMessageWithProperties(properties: properties)
    }
    
    func handleImageSelectedForUrl(url: URL) {
        if let thumnailImage = MessagesHandler.shared.getThumbnailImageForVideoUrl(fileUrl: url) {
            MessagesHandler.shared.uploadVideoMessage(url: url) { (videoUrl, thumbnailUrl, error) in
                if error != nil {
                    print(error!.localizedDescription)
                    AlertMessage.shared.show(tilte: ERROR.DATA.UPLOAD.TITLE, message: ERROR.DATA.UPLOAD.MESSAGE, from: self)
                    return
                }
                
                let properties = [KEY_DATA.MESSAGE.IMAGE_URL: thumbnailUrl!, KEY_DATA.MESSAGE.IMAGE_WIDTH: thumnailImage.size.width, KEY_DATA.MESSAGE.IMAGE_HEIGHT: thumnailImage.size.height, KEY_DATA.MESSAGE.VIDEO_URL: videoUrl!] as [String: AnyObject]
                self.sendMessageWithProperties(properties: properties)
            }
        }
    }
    
    func sendMessageWithProperties(properties: [String: AnyObject]) {
        
    }
}

//MARK: - UITEXTFIELD DELEGATE
extension BaseChatLogController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
}

//MARK: - IMAGE PICKER CONTROLLER DELEGATE
extension BaseChatLogController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if let videoUrl = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.mediaURL)] as? URL{
            handleImageSelectedForUrl(url: videoUrl)
        } else {
            handleImageSelectedForInfo(info: info)
        }
        dismiss(animated: true, completion: nil)
    }
}
//MARK: - COLLECTION VIEW DELEGATE FLOW LAYOUT
extension BaseChatLogController: UICollectionViewDelegateFlowLayout {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
