//
//  ViewController.swift
//  chatapp
//
//  Created by Khoa Nguyen on 3/15/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit

class UserMessagesController: BaseTableViewController {

    //MARK: - CONSTANT
    struct Constant {
        static let deleteTitle = "Delete Conversation"
        static let deleteMessage = "This will be permanently delete the conversation history."
        static let confirmDeleteTitle = "Delete Conversation"
        static let cancelTitle = "Cancel"
    }
    
    //MARK: - PROPERTIES
    private var messages = [Message]()
    private var messagesDictionary = [String : Message]()
    private var timer:Timer?
    static var identifier: String {
        return String(describing: self)
    }
    
    //MARK: - VIEW LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegateAndRegister()
        MessagesHandler.shared.observeUserMessages()
    }
    
    //MARK: SET DELEGATE AND REGISTER
    private func setDelegateAndRegister() {
        MessagesHandler.shared.delegateUserMessages = self
        tableView.register(UserCell.self, forCellReuseIdentifier: UserMessagesController.identifier)
    }
    
    //MARK: - OVERRIDE FUNCTION
    override func setupBarButtonItem() {
        super.setupBarButtonItem()
         self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: ASSETS.ICON.NEW_MESSAGE),
                                                                  style: .plain, target: self,
                                                                  action: #selector(handleNewMessage))
    }
    
    //MARK: - TABLEVIEW DELEGATE AND DATASOURCE
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserMessagesController.identifier,
                                                 for: indexPath) as! UserCell
        let message =  messages[indexPath.row]
        cell.textLabel?.text = message.text
        cell.message = message
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        getUserFromMessage(message: message)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        comfirmDeleteMessages(at: indexPath.row)
    }
    
    //MARK: - HANDLE FUNCTION
    @objc func handleNewMessage(){
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        
        present(navController, animated: true, completion: nil)
    }
    
    private func getUserFromMessage(message: Message) {
        guard let chatPartnerId = message.chatPartnerId() else { return }
        
        DBProvider.shared.getUserWith(id: chatPartnerId) { (user) in
            guard let user = user else { return }
            self.switchToChatLogController(user: user)
        }
    }
    
    private func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: CONSTANT.TIME.REFRESH,
                                          target: self,
                                          selector: #selector(self.handleReloadTable),
                                          userInfo: nil,
                                          repeats: false)
    }
    
    
    @objc private func handleReloadTable() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return (message1.timeStamp?.intValue)! > (message2.timeStamp?.intValue)!
        })
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func comfirmDeleteMessages(at row: Int) {
        let alertController = UIAlertController(title: Constant.deleteTitle,
                                                message: Constant.deleteMessage,
                                                preferredStyle: .alert)
        let actionOk = UIAlertAction(title: Constant.confirmDeleteTitle, style: .destructive) { (alert) in
            if let chatPartnerId = self.messages[row].chatPartnerId() {
                MessagesHandler.shared.deleteUserMessages(with: chatPartnerId, completion: { (error) in
                    if error != nil {
                        print(error!.localizedDescription)
                        AlertMessage.shared.show(tilte: ERROR.DATA.REMOVE.TITLE,
                                                 message: ERROR.DATA.REMOVE.MESSAGE, from: self)
                        return
                    }
                })
            }
        }
        let actionCancel = UIAlertAction(title: Constant.cancelTitle, style: .cancel, handler: nil)
        
        alertController.addAction(actionOk)
        alertController.addAction(actionCancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func switchToChatLogController(user: User) {
        let chatLogController = UserChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.recipient = user
        chatLogController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
}
//MARK: - FETCH USER MESSAGES DELEGATE
extension UserMessagesController: FetchUserMessages {
    func dataReceived(messagesDictionary: [String : Message]) {
        self.messagesDictionary = messagesDictionary
        attemptReloadOfTable()
    }
}


