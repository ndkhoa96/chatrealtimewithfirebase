//
//  NewMessageViewController.swift
//  chatapp
//
//  Created by Khoa Nguyen on 3/16/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit

class NewMessageController: UITableViewController {

    var users = [User]()
    static var identifier: String {
        return String(describing: self)
    }
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        self.tableView.register(UserCell.self, forCellReuseIdentifier: NewMessageController.identifier)
        self.tableView.separatorStyle = .none
        DBProvider.shared.delegateAllUser = self
        DBProvider.shared.getAllUser()

    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        let cell = tableView.dequeueReusableCell(withIdentifier: NewMessageController.identifier, for: indexPath) as! UserCell
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
    
    var messagesController = UserMessagesController()
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messagesController.switchToChatLogController(user: user)
        }
    }
    
    
    func attemptReloadOfTable() {
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: CONSTANT.TIME.REFRESH,
                                          target: self,
                                          selector: #selector(self.handleReloadTable),
                                          userInfo: nil,
                                          repeats: false)
    }
    
    @objc func handleReloadTable() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
extension NewMessageController: FetchAllUserData {
    func dataReceived(users: [User]) {
        self.users = users
        attemptReloadOfTable()
    }
}
