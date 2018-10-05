//
//  FriendsViewController.swift
//  chatapp
//
//  Created by Khoa Nguyen on 7/19/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit
import Firebase

class FriendsViewController: BaseTableViewController, UISearchBarDelegate {
    
    var users = [User]()
    let friendCellId = "friendCellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(FriendCell.self, forCellReuseIdentifier: friendCellId)
        searchBar.delegate = self
        rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "search"), style: .plain, target: self, action: #selector(handleSearch))
        leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "ic_menu"), style: .plain, target: self, action: #selector(handleShowMenu))
        
        fetchUser()
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.barStyle = UIBarStyle.blackTranslucent
        searchBar.sizeToFit()
        searchBar.showsCancelButton = true
        searchBar.placeholder = "Search by name"
        let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = Theme.shared.whiteColor
        
        return searchBar
    }()
    var usersFillter = [User]()
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        users.removeAll()
        
        guard !searchText.isEmpty else{
            users = usersFillter
            attemptReloadOfTable()
            return
        }
        users = usersFillter.filter({ (user) -> Bool in
            (user.name?.lowercased().contains(searchText.lowercased()))!
        })

        attemptReloadOfTable()
    }
    
    
    var rightBarButtonItem : UIBarButtonItem!
    var leftBarButtonItem : UIBarButtonItem!
    
    func setupNavigationBar(){
        fetchUserAndSetupNavBarTitle()
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        setupNavigationBar()
        users = usersFillter
        attemptReloadOfTable()
    }
    
    @objc func handleSearch(){
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItem = nil
        navigationItem.titleView = nil
        navigationItem.titleView = searchBar
        searchBar.becomeFirstResponder();
        searchBar.text = ""
    }

    
    func fetchUser(){
        let myId = AuthProvider.shared.userID
 
        DBProvider.shared.users.queryOrdered(byChild: KEY_DATA.USER.NAME).observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let user = User(values: dictionary)
                user.id = snapshot.key
                
                if myId != user.id{
                    self.users.append(user)
                    self.usersFillter.append(user)
                }
                
                self.attemptReloadOfTable()
                
            }
        }, withCancel: nil)

    }
    
    var timer:Timer?
    
    func attemptReloadOfTable(){
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: TIME.REFRESH, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    @objc func handleReloadTable(){
        getFirstCharacter()
        
        DispatchQueue.main.async {

            self.tableView.reloadData()
        }
    }
    
    var letters = [Character]()
    var friendsContact = [Character: [User]]()

    func getFirstCharacter(){
        friendsContact.removeAll()
        
        letters = users.map({ (user) -> Character in
            return user.name![user.name!.startIndex]
        })
        
        letters = letters.sorted()
        letters = letters.reduce([], { (list, user) -> [Character] in
            if !list.contains(user){
                return list + [user]
            }
            return list
            
        })
   
        for user in users {
            if friendsContact[user.name![user.name!.startIndex]] == nil {
                friendsContact[user.name![user.name!.startIndex]] = [User]()
            }
            
            friendsContact[user.name![user.name!.startIndex]]!.append(user)
        }
        
        for (letter, list) in friendsContact {
            friendsContact[letter] = list.sorted(by: { (user1, user2) -> Bool in
                return user1.name! < user2.name!
            })
        
        }

    }
    
    func callNumber(phoneNumber:String) {
        if let phoneCallURL = URL(string:"tel://\(phoneNumber)") {
            let application = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
        }
    }
    
    func callUser(cell: UITableViewCell){
        let indexTapped = tableView.indexPath(for: cell)
        let user = friendsContact[letters[(indexTapped?.section)!]]![(indexTapped?.row)!]
        
        callNumber(phoneNumber: user.phoneNumber!)
    }
    
    func showChatWithUser(cell: UITableViewCell){
        
        let indexTapped = tableView.indexPath(for: cell)
        let user = friendsContact[letters[(indexTapped?.section)!]]![(indexTapped?.row)!]
        
        let dbRef = DBProvider.shared.users.child(user.id!)
        dbRef.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String : AnyObject]
                else{
                    return
            }
            let user = User(values: dictionary)
            user.id = snapshot.key
            self.showChatControllerForUser(user: user)
            
        }, withCancel: nil)
    }
    
    func showChatControllerForUser(user: User){
        let chatLogController = SingleChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        chatLogController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return letters.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let friends = friendsContact[letters[section]]
        
        return friends!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: friendCellId, for: indexPath) as! FriendCell
        cell.friendsVC = self
        let user = friendsContact[letters[indexPath.section]]![indexPath.row]
        cell.textLabel?.text = user.name
        
        cell.btnCall.isEnabled = user.phoneNumber == nil ? false : true
        
        if let profileImageUrl = user.profileImageUrl{
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    var messagesController = RecentMessagesController()
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = friendsContact[letters[indexPath.section]]![indexPath.row]
        let persionnalPageController = PersionalPageViewController(collectionViewLayout: UICollectionViewFlowLayout())
        
        persionnalPageController.hidesBottomBarWhenPushed = true
        persionnalPageController.user = user
        navigationController?.pushViewController(persionnalPageController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = Theme.shared.whiteColor
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = String(letters[section])
        label.textColor = UIColor.lightGray
        label.textAlignment = .left

        
        view.addSubview(label)
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8).isActive = true
        
        
        
        return view
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: ANIMATION.NORMAL) {
            cell.transform = CGAffineTransform.identity
        }
    }

}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
