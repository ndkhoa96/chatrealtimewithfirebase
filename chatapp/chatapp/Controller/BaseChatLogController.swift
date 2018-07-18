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

class BaseChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.placeholder = "Enter message..."
        
        
        return textField
    }()
    
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = Theme.shared.lightGrayColor
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
        collectionView?.keyboardDismissMode = .interactive
        
        inputTextField.resignFirstResponder()
        inputTextField.becomeFirstResponder()
    }
  
    
    lazy var inputContainerView : UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 45)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = Theme.shared.whiteColor
        
        let uploadImageView = UIImageView()
        let image = UIImage(named: "upload_image_icon")
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
        //sendButton.setImage(UIImage(named: "send_icon"), for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        //sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        sendButton.image = UIImage(named: "send_icon")
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
        separatorView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.addSubview(separatorView)
        
        //separatorView constrains
        separatorView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        separatorView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        separatorView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        separatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
    
    @objc func handleUploadTap(){

        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)

        let actionGallery = UIAlertAction(title: "Open Gallery", style: .default) { (alert) in
            self.openGallery()
        }
        let actionCamera = UIAlertAction(title: "Take a picture", style: .default) { (alert) in
            self.openCamera()
        }

        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(actionGallery)
        alert.addAction(actionCamera)
        alert.addAction(actionCancel)
        self.present(alert,animated: true)

    }
    var imageGalleryPickerController = UIImagePickerController()
    var imageCameraController = UIImagePickerController()
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            imageCameraController.delegate = self
            imageCameraController.sourceType = UIImagePickerControllerSourceType.camera
            imageCameraController.allowsEditing = true

            self.present(self.imageCameraController, animated: true, completion: nil)
        }
        else {
            let alertWarning = UIAlertController(title:"Warning", message: "You don't have camera", preferredStyle: .alert)
            let actionOk = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertWarning.addAction(actionOk)

            self.present(alertWarning, animated: true, completion: nil)
        }
    }
    
    func openGallery(){

        imageGalleryPickerController.delegate = self
        imageGalleryPickerController.allowsEditing = true
        imageGalleryPickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        
        self.present(imageGalleryPickerController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
  
    
    override var inputAccessoryView: UIView?{
        get{
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool{
        return true
    }

    
    private func setupCell(cell: ChatMessageCell,message: Message){
        
        if message.fromID == Auth.auth().currentUser?.uid{
            //outgoing mess
            cell.bubbleView.backgroundColor = Theme.shared.blueColor
            cell.profileImageView.isHidden = true
            cell.bubbleViewLeftAnchor?.isActive = false
            cell.bubbleViewRightAnchor?.isActive = true
        }else{
            //incoming mess
            cell.bubbleView.backgroundColor = Theme.shared.grayColor
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
    
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    private func estimateFrameForText(text: String) -> CGRect{
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    @objc func handleSend(){
        
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    var startingFrame: CGRect?
    var blackBackground: UIView?
    var startingImageView: UIImageView?
    
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
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
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
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
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
