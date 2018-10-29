//
//  MembersController.swift
//  chatapp
//
//  Created by Khoa Nguyen on 6/28/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit
import Firebase

class MembersController: UITableViewController {
    
    var members = [User]()
    let cellId = "CELL"
    
    var group : Group? {
        didSet{
            fetchMember(idGroup: (group?.id)!)
            self.navigationItem.title = (group?.name)! + " - Members"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_drop"), style: .plain, target: self, action: #selector(handleCancel))
        
        self.tableView.register(UserCell.self, forCellReuseIdentifier: cellId) 
        self.tableView.separatorStyle = .none
    }
    
    func handleLeaveGroup(){
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let dbRef = Database.database().reference()
        
        dbRef.child(KEY_DATA.USER_GROUPS.ROOT).child(uid).child((self.group?.id)!).removeValue { (error, ref) in
            if(error != nil){
                print("Failed to remove \(error!)")
                return
            }
            dbRef.child(KEY_DATA.GROUP_MEMBERS.ROOT).child((self.group?.id)!).child(uid).removeValue(completionBlock: { (error, ref) in
                if(error != nil){
                    print("Failed to remove \(error!)")
                    return
                }
                self.dismiss(animated: true, completion: nil)
            })
        }
    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    
    func fetchMember(idGroup: String){
        let myId = AuthProvider.shared.currentUserID
        members.removeAll()
        DBProvider.shared.groupMembersReference.child(idGroup).observe(.childAdded, with: { (snapshot) in
            print(snapshot.key)
            DBProvider.shared.usersReference.child(snapshot.key).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let member = User(values: dictionary)
                    member.id = snapshot.key
                    
                    if myId != member.id{
                        self.members.append(member)
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        //let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = members[indexPath.row]
        cell.textLabel?.text = user.name
        cell.detailTextLabel?.text = user.email
        
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
            let user = self.members[indexPath.row]
            self.messagesController.switchToChatLogController(user: user)
        }
    }
}

