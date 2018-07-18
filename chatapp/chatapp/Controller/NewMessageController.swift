//
//  NewMessageViewController.swift
//  chatapp
//
//  Created by Khoa Nguyen on 3/16/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UITableViewController {

    var users = [User]()
    let cellId = "CELL"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        self.tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
    
        fetchUser()
    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    func fetchUser(){
        let myId = Auth.auth().currentUser?.uid
        
        
        Database.database().reference().child("users").queryOrdered(byChild: "name").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let user = User(values: dictionary)
                user.id = snapshot.key
                
                if myId != user.id{
                    self.users.append(user)
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            }
            
        }, withCancel: nil)
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        //cell.detailTextLabel?.text = user.email

        if let profileImageUrl = user.profileImageUrl{
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    var messagesController = MessagesController()
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messagesController.showChatControllerForUser(user: user)
        }
    }
}

