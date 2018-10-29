//
//  ManagerMemberController.swift
//  chatapp
//
//  Created by Khoa Nguyen on 6/22/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit
import Firebase

class ManagerMemberController: UITableViewController,UISearchBarDelegate {
    
    let cellId = "CELL"
    var members = [User]()
    var usersNotMember = [User]()
    var userDictionary = [String: User]()
    
    var group : Group? {
        didSet{
            fetchMember(idGroup: (group?.id)!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(MemberCell.self, forCellReuseIdentifier: cellId)
        self.tableView.separatorStyle = .none
        setupNavigationBar()
        fetchUser()
    }
    
    func setupNavigationBar(){
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_drop"), style: .plain, target: self, action: #selector(handleCancel))

        
        memberFriendsSegmentControl.addTarget(self, action: #selector(handleMemberFriendsSegmentControl), for: .valueChanged)
        navigationItem.titleView = memberFriendsSegmentControl
    }
    
    var memberFriendsSegmentControl : UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Members","Friends"])
        segmentedControl.tintColor = Theme.shared.whiteColor
        segmentedControl.selectedSegmentIndex = 0
    
        return segmentedControl;
    }()
    

    
    @objc func handleMemberFriendsSegmentControl(){
        tableView.reloadData()
    }
    
    @objc func handleCancel(){
        dismiss(animated: true, completion: nil)
    }
    var timer:Timer?
    
    func attemptReloadOfTable(){
        self.timer?.invalidate()
        //print("cancel timer")
        self.timer = Timer.scheduledTimer(timeInterval: CONSTANT.TIME.REFRESH, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
        //print("schedule a table raload in 0.1 sec")
    }
    
    @objc func handleReloadTable(){
        for member in members {
            if self.userDictionary.contains(where: { (user) -> Bool in
                return user.key == member.id
            }){
                self.userDictionary.removeValue(forKey: member.id!)
            }
        }
        self.usersNotMember = Array(self.userDictionary.values)
        
        DispatchQueue.main.async {
            print("reload table")
            
            self.tableView.reloadData()
        }
    }
    
    func fetchUser(){
        userDictionary.removeAll()

        let myId = AuthProvider.shared.currentUserID

        DBProvider.shared.usersReference.queryOrdered(byChild: KEY_DATA.USER.NAME).observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let user = User(values: dictionary)
                user.id = snapshot.key
                
                if user.id! != myId {
                    self.userDictionary[user.id!] = user
                    self.attemptReloadOfTable()
                }
            }
            
        }, withCancel: nil)
        
    }
    
    func fetchMember(idGroup: String){
        members.removeAll()
        
        let myId = AuthProvider.shared.currentUserID
        members.removeAll()
        
        
        DBProvider.shared.groupMembersReference.child(idGroup).observe(.childAdded, with: { (snapshot) in
            print("Member: ",snapshot.key)
            DBProvider.shared.usersReference.child(snapshot.key).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let member = User(values: dictionary)
                    member.id = snapshot.key
                    
                    if myId != member.id{
                       self.members.append(member)
                    }
          
                    self.attemptReloadOfTable()
                    
                }
                    
            }, withCancel: nil)

        }, withCancel: nil)

    }
    
    func removeMemberFromGroup(cell: UITableViewCell){
        
        let indexTapped = tableView.indexPath(for: cell)
        let user = members[indexTapped!.row]
        print("Remove \(user.name!)")
        let dbRef = Database.database().reference()
        
        dbRef.child(KEY_DATA.USER_GROUPS.ROOT).child(user.id!).child((self.group?.id)!).removeValue { (error, ref) in
            if(error != nil){
                print("Failed to remove \(error!)")
                return
            }
            dbRef.child(KEY_DATA.GROUP_MEMBERS.ROOT).child((self.group?.id)!).child(user.id!).removeValue(completionBlock: { (error, ref) in
                if(error != nil){
                    print("Failed to remove \(error!)")
                    return
                }
                self.members.remove(at: indexTapped!.row)
                self.userDictionary[user.id!] = user
                self.attemptReloadOfTable()
            })
        }
    }
    
    func addMemberToGroup(cell: UITableViewCell){

        let indexTapped = tableView.indexPath(for: cell)
        let user = usersNotMember[indexTapped!.row]
        print("Add \(user.name!)")
        let dbRef = Database.database().reference()
        
        dbRef.child(KEY_DATA.USER_GROUPS.ROOT).child(user.id!).updateChildValues([(group?.id)!: "member"]) { (error, ref) in
            if(error != nil){
                print("Failed to add \(error!)")
                return
            }
            dbRef.child(KEY_DATA.GROUP_MEMBERS.ROOT).child((self.group?.id)!).updateChildValues([user.id! : "member"], withCompletionBlock: { (error, ref) in
                if(error != nil){
                    print("Failed to add \(error!)")
                    return
                }

                self.fetchMember(idGroup: (self.group?.id)!)
            })
        }

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
  
        if memberFriendsSegmentControl.selectedSegmentIndex == 0 {
            return members.count
        }else{
            return usersNotMember.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MemberCell
        cell.managerMembers = self
        var user : User?
        switch(memberFriendsSegmentControl.selectedSegmentIndex)
        {
        case 0:
            user = members[indexPath.row]
            cell.membersActive()
        case 1:
            user = usersNotMember[indexPath.row]
            cell.friendsActive()
        default:
            break
        }
        cell.textLabel?.text = user?.name
        cell.detailTextLabel?.text = user?.email
        
        if let profileImageUrl = user?.profileImageUrl{
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        return cell
    }


    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }

}
