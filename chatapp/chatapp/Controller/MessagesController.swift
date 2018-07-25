//
//  ViewController.swift
//  chatapp
//
//  Created by Khoa Nguyen on 3/15/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: BaseTableViewController{

    var messages = [Message]()
    var messagesDictionary = [String : Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "new_message_icon"), style: .plain, target: self, action: #selector(handleNewMessage))
        
        observeUserMessages()

    }
    
    
    func observeUserMessages(){
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        guard let uid =  Auth.auth().currentUser?.uid
            else{
                return
        }
        let dbRef = Database.database().reference().child("user-messages").child(uid)
        dbRef.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            dbRef.child(userId).observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                self.fetchMessageWithMessageId(messageId: messageId)
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
        dbRef.observe(.childRemoved, with: { (snapshot) in
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadOfTable()
        }, withCancel: nil)
    }
    
    func fetchMessageWithMessageId(messageId: String){
        
        let messagesRef = Database.database().reference().child("messages").child(messageId)
        messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let message = Message(values: dictionary)
                
                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId] = message
                    
                }
                
                self.attemptReloadOfTable()
                
            }
        }, withCancel: nil)
    }
    
    func attemptReloadOfTable(){
        self.timer?.invalidate()
        //print("cancel timer")
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
        //print("schedule a table raload in 0.1 sec")
    }
    
    var timer:Timer?
    
    @objc func handleReloadTable(){
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return (message1.timeStamp?.intValue)! > (message2.timeStamp?.intValue)!
        })
        
        DispatchQueue.main.async {
            print("reload table")
            self.tableView.reloadData()
        }
    }
    
    
    @objc func handleNewMessage(){
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)

        present(navController, animated: true, completion: nil)
       
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let message =  messages[indexPath.row]
        cell.textLabel?.text = message.text
        cell.message = message
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
                return
        }
        
        let dbRef = Database.database().reference().child("users").child(chatPartnerId)
        dbRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String : AnyObject]
                else{
                    return
            }
            let user = User(values: dictionary)
            user.id = chatPartnerId
            self.showChatControllerForUser(user: user)
            
        }, withCancel: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

        let alertController = UIAlertController(title: "Delete Conversation", message: "This will be permanently delete the conversation history.", preferredStyle: .alert)
        
        let actionOk = UIAlertAction(title: "Delete Conversation", style: .destructive) { (alert) in
            guard let uid = Auth.auth().currentUser?.uid else {
                return
            }
            
            let message = self.messages[indexPath.row]
            if let chatPartnerId = message.chatPartnerId(){
                Database.database().reference().child("user-messages").child(uid).child(chatPartnerId).removeValue { (error, ref) in
                    if error != nil {
                        print("Failed to delete message: ", error!)
                        return
                    }
                    self.messagesDictionary.removeValue(forKey: chatPartnerId)
                    self.attemptReloadOfTable()
                }
            }
        }
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(actionOk)
        alertController.addAction(actionCancel)
        
        self.present(alertController, animated: true, completion: nil)
        
    }

    
    func showChatControllerForUser(user: User){
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        chatLogController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
}



