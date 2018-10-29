//
//  FriendsViewController.swift
//  chatapp
//
//  Created by Khoa Nguyen on 7/19/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//  Document file CHAT_APPLICATION_TLPT_01_FriendList.xlsx


import UIKit

class FriendsViewController: BaseTableViewController {

    //MARK: - CONSTANTS
    struct Constant {
        static let searchPlaceHolder = "Search by name"
        static let searchTxfKey = "searchField"
    }
    
    //MARK: - PROPERTIES
    var friends = [User]()
    var usersFillter = [User]()
    static var identifier: String {
        return String(describing: self)
    }
    
    var timer:Timer?
    var letters = [Character]()
    var friendsContact = [Character: [User]]()
    
    //MARK: - UI
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.barStyle = UIBarStyle.blackTranslucent
        searchBar.sizeToFit()
        searchBar.showsCancelButton = true
        searchBar.placeholder = Constant.searchPlaceHolder
        let textFieldInsideSearchBar = searchBar.value(forKey: Constant.searchTxfKey) as? UITextField
        textFieldInsideSearchBar?.textColor = Theme.shared.whiteColor
        return searchBar
    }()
    
    //MARK: - VIEW LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegateAndRegister()
        DBProvider.shared.getAllUser()
    }
    
    //MARK: SET DELEGATE AND REGISTER
    private func setDelegateAndRegister() {
        tableView.register(FriendCell.self, forCellReuseIdentifier: FriendsViewController.identifier)
        searchBar.delegate = self
        DBProvider.shared.delegateAllUser = self
    }
    
    //MARK: - OVERRIDE FUNCTION
    override func setupBarButtonItem() {
        super.setupBarButtonItem()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: ASSETS.ICON.SEARCH),
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(handleSearch))
    }
    
    //MARK: - HANDLE FUNCTION
    @objc func handleSearch() {
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItem = nil
        navigationItem.titleView = nil
        navigationItem.titleView = searchBar
        searchBar.becomeFirstResponder()
        searchBar.text = nil
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
        getListFirstCharacter()
        getFirstCharacterForUsers()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func getListFirstCharacter() {
        letters = friends.map({ (user) -> Character in
            let nameUpcase = user.name!.uppercased()
            return nameUpcase[nameUpcase.startIndex]
        })
        
        letters = letters.sorted()
        letters = letters.reduce([], { (list, character) -> [Character] in
            if !list.contains(character){
                return list + [character]
            }
            return list
        })
    }
    
    func getFirstCharacterForUsers(){
        friendsContact.removeAll()
   
        for user in friends {
            let nameUpcase = user.name!.uppercased()
            if friendsContact[nameUpcase[nameUpcase.startIndex]] == nil {
                friendsContact[nameUpcase[nameUpcase.startIndex]] = [User]()
            }
            friendsContact[nameUpcase[nameUpcase.startIndex]]!.append(user)
        }
    }
    
    func callNumber(phoneNumber:String) {
        if let phoneCallURL = URL(string:"tel://\(phoneNumber)") {
            let application = UIApplication.shared
            if (application.canOpenURL(phoneCallURL)) {
                application.open(phoneCallURL, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]),
                                 completionHandler: nil)
            }
        }
    }
    
    //Procesing 10.(4).1
    func callUser(cell: UITableViewCell) {
        let indexTapped = tableView.indexPath(for: cell)
        let user = friendsContact[letters[(indexTapped?.section)!]]![(indexTapped?.row)!]
        callNumber(phoneNumber: user.phoneNumber!)
    }
    
    //Procesing 10.(4).2
    func handleTapToUserChatLog(cell: UITableViewCell) {
        let indexTapped = tableView.indexPath(for: cell)
        let user = friendsContact[letters[(indexTapped?.section)!]]![(indexTapped?.row)!]
        self.switchToChatLogController(user: user)
    }
    
    func switchToChatLogController(user: User) {
        let userChatLogController = UserChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        userChatLogController.recipient = user
        userChatLogController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(userChatLogController, animated: true)
    }
    
    //Procesing 10.(4).3
    private func switchToPersonalController(user: User) {
        let persionalPageController = PersionalPageViewController(collectionViewLayout: UICollectionViewFlowLayout())
        persionalPageController.hidesBottomBarWhenPushed = true
        persionalPageController.user = user
        navigationController?.pushViewController(persionalPageController, animated: true)
    }
    
    //MARK: - TABLEVIEW DELEGATE AND DATASOURCE
    override func numberOfSections(in tableView: UITableView) -> Int {
        return letters.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let friends = friendsContact[letters[section]]
        return friends!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let user = friendsContact[letters[indexPath.section]]![indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: FriendsViewController.identifier,
                                                 for: indexPath) as! FriendCell
        cell.friendsVC = self
        cell.textLabel?.text = user.name
        cell.btnCall.isEnabled = user.phoneNumber == nil ? false : true
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    //Procesing 10.(4).3
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = friendsContact[letters[indexPath.section]]![indexPath.row]
        switchToPersonalController(user: user)
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

//MARK: - FETCH ALL USER DATA DELEGATE
extension FriendsViewController: FetchAllUserData {
    func dataReceived(users: [User]) {
        self.friends = users
        self.usersFillter = users
        attemptReloadOfTable()
    }
}
//MARK: - SEARCH BAR DELEGATE
extension FriendsViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        friends.removeAll()
        guard !searchText.isEmpty else {
            friends = usersFillter
            handleReloadTable()
            return
        }
        friends = usersFillter.filter({ (user) -> Bool in
            (user.name?.lowercased().contains(searchText.lowercased()))!
        })
        
        handleReloadTable()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        setupNavBarWithUser()
        setupBarButtonItem()
        friends = usersFillter
        handleReloadTable()
    }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
