//
//  GroupChatLogController.swift
//  chatapp
//
//  Created by Khoa Nguyen on 6/21/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit

class GroupChatLogController: BaseChatLogController {
    
    //MARK: - CONSTANT
    struct Constants {
        static let outGroupTitle = "Sorry"
        static let outGroupMessage = "You are blocked from this group!"
        static let okActionTitle = "Ok"
    }
    
    //MARK: - PROPERTIES
    var groupChat: Group? {
        didSet {
            navigationItem.title = groupChat?.name
            if let groupId = groupChat?.id {
                MessagesHandler.shared.observeGroupMessages(groupId: groupId)
            }
        }
    }
    var groupMessages = [Message]()
    private var timer: Timer?
    
    //MARK: - VIEW LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBarButtonItem()
        setDelegateAndRegister()
        observeChildRemoveGroup()
    }
    
    //MARK: SET DELEGATE AND REGISTER
    private func setDelegateAndRegister() {
        MessagesHandler.shared.delegateGroupMessages = self
    }
    
    //MARK: - SETUP UI
    private func setupBarButtonItem() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: ASSETS.ICON.SETTING),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(handleAddMember))
    }
    
    //MARK: - OVERRIDE FUNCTION
    @objc override func handleKeyboardDidShow() {
        scrollToNewestMessage()
    }
    
    override func sendMessageWithProperties(properties: [String: AnyObject]){
        guard let groupId = self.groupChat?.id else { return }
        MessagesHandler.shared.sendDirectGroupMessage(groupID: groupId, properties: properties) { (error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            self.inputTextField.text = nil
        }
    }
    
    //MARK: - HANDLE FUNCTION
    private func observeChildRemoveGroup() {
        guard let groupId = groupChat?.id else { return }
        MessagesHandler.shared.observeGroupMembersChildRemove(groupId: groupId) { (removeId) in
            if removeId == AuthProvider.shared.currentUserID {
                self.showNotificationWhenOutGroup()
            }
        }
    }
    
    
    private func showNotificationWhenOutGroup() {
        let alert = UIAlertController(title: Constants.outGroupTitle, message: Constants.outGroupMessage, preferredStyle: .alert)
        let action = UIAlertAction(title: Constants.okActionTitle, style: .default) { (alert) in
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(action)
        self.present(alert,animated: true)
    }
    
    private func scrollToNewestMessage() {
        if self.groupMessages.count > 0 {
            let indexPath = IndexPath(item: self.groupMessages.count - 1, section: 0)
            self.collectionView.scrollToItemIfAvailable(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    private func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: CONSTANT.TIME.REFRESH,
                                          target: self,
                                          selector: #selector(self.handleReloadMessages),
                                          userInfo: nil, repeats: false)
    }
    
    @objc private func handleReloadMessages() {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
            self.scrollToNewestMessage()
        }
    }
    
    @objc func handleAddMember() {
        if groupChat?.hostId == AuthProvider.shared.currentUserID {
            switchToManagerMemberController()
        } else {
            switchToMemberController()
        }
    }
    
    private func switchToManagerMemberController() {
        let managerMemberController = ManagerMemberController()
        managerMemberController.group = self.groupChat
        let navController = UINavigationController(rootViewController: managerMemberController)
        present(navController, animated: true, completion: nil)
    }
    
    private func switchToMemberController() {
        let membersController = MembersController()
        membersController.group = self.groupChat
        let navController = UINavigationController(rootViewController: membersController)
        present(navController, animated: true, completion: nil)
    }

    //MARK: - COLLECTIONVIEW DELEGATE
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupMessages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = groupMessages[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BaseChatLogController.identifier,
                                                      for: indexPath) as! ChatMessageCell
        cell.chatLogController = self
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
    
}

//MARK: - FETCH GROUP MESSAGES DELEGATE
extension GroupChatLogController: FetchGroupMessages {
    func dataReceived(groupMessages: [Message]) {
        self.groupMessages = groupMessages
        attemptReloadOfTable()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
