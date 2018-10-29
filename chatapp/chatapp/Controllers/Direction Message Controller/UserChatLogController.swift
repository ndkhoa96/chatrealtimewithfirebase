//
//  ChatLogController.swift
//  chatapp
//
//  Created by Khoa Nguyen on 3/22/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit

class UserChatLogController: BaseChatLogController {
    
    //MARK: - PROPERTIES
    var recipient: User? {
        didSet {
            navigationItem.title = recipient?.name
            if let recipientID = recipient?.id {
                 MessagesHandler.shared.observeUserChatLog(recipientID: recipientID)
            }
        }
    }
    var messages = [Message]()
    private var timer:Timer?
    
    //MARK: - VIEW LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBarButtonItem()
        setDelegateAndRegister()
    }
    
    //MARK: SET DELEGATE AND REGISTER
    private func setDelegateAndRegister() {
        MessagesHandler.shared.delegateUserChatLog = self
    }
    
    //MARK: - SETUP UI
    private func setupBarButtonItem() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: ASSETS.ICON.INFO), style: .plain, target: self, action: #selector(switchToPersionalController))
    }
    
    //MARK: - HANDLE FUCTION
    @objc func switchToPersionalController() {
        let persionnalPageController = PersionalPageViewController(collectionViewLayout: UICollectionViewFlowLayout())
        persionnalPageController.hidesBottomBarWhenPushed = true
        persionnalPageController.user = self.recipient
        navigationController?.pushViewController(persionnalPageController, animated: true)
    }
    
    private func scrollToNewestMessage() {
        if self.messages.count > 0 {
            let indexPath = IndexPath(item: self.messages.count - 1, section: 0)
            collectionView.scrollToItemIfAvailable(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    private func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: CONSTANT.TIME.REFRESH,
                                          target: self,
                                          selector: #selector(self.handleReloadCollectionData),
                                          userInfo: nil, repeats: false)
    }
    
    @objc private func handleReloadCollectionData() {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
            self.scrollToNewestMessage()
        }
    }
    
    //MARK: - OVERRIDE FUNCTION
    @objc override func handleKeyboardDidShow(){
        scrollToNewestMessage()
    }
    
    override func sendMessageWithProperties(properties: [String: AnyObject]){
        if let recipientID = recipient?.id {
            MessagesHandler.shared.sendDirectUserMessage(toID: recipientID, properties: properties) { (error) in
                if error != nil {
                    print(error!.localizedDescription)
                    AlertMessage.shared.show(tilte: ERROR.DATA.SEND.TITLE, message: ERROR.DATA.SEND.MESSAGE, from: self)
                    return
                }
                self.inputTextField.text = nil
                self.scrollToNewestMessage()
            }
        }
    }
    
    //MARK: - COLLECTION VIEW DELEGATE AND DATASOURCE
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = messages[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BaseChatLogController.identifier, for: indexPath) as! ChatMessageCell
        cell.chatLogController = self
        cell.messages = message
        cell.textView.text = message.text
        cell.playButton.isHidden = message.videoUrl == nil
        setupCell(cell: cell, message: message)
        
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
            cell.textView.isHidden = false
        } else if message.imageUrl != nil{
            cell.bubbleWidthAnchor?.constant = 200
            cell.textView.isHidden = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var height:CGFloat = 80
        let message = messages[indexPath.row]
        let width = UIScreen.main.bounds.width
        
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        return CGSize(width: width, height: height)
    }
    
}
//MARK: - FETCH USER DIRECT MESSAGES DELEGATE
extension UserChatLogController: FetchUserChatLog {
    func dataReceived(messages: [Message]) {
        self.messages = messages
        attemptReloadOfTable()
    }
}

