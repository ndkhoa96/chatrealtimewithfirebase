//
//  GroupMessagesController.swift
//  chatapp
//
//  Created by Khoa Nguyen on 6/19/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit

class GroupsMessagesController: BaseTableViewController {
    
    //MARK: - CONSTANT
    struct Constant {
        static let leaveGroupTitle = "Leave This Group"
        static let changeGroupImageActionTitle = "Change Group Image"
        static let deleteGroupActionTitle = "Delete This Group"
        static let cancelTitle = "Cancel"
        static let deleteGroupTitle = "Delete This Group"
        static let deleteGroupMessage = "This will be permanently delete all the conversation in this group."
        static let confirmDeleteGroupTitle = "Delete This Group"
        static let nameGroupTxfPlaceholder = "Name of group"
        static let createGroupTitle = "Create New Group Chat"
        static let confirmCreateGroupTitle = "Create"
    }

    //MARK: - PROPERTIES
    var groups = [Group]()
    var groupDictionary = [String: Group]()
    var groupMessagesDictionary = [String : Message]()
    static var identifier: String {
        return String(describing: self)
    }
    var timer: Timer?
    
    //MARK: - UI
    lazy var groupImageView: UIImageView =  {
        let groupImageView = UIImageView()
        groupImageView.translatesAutoresizingMaskIntoConstraints = false
        groupImageView.image = #imageLiteral(resourceName: "groups")
        groupImageView.contentMode = .scaleAspectFill
        groupImageView.isUserInteractionEnabled = true
        groupImageView.layer.cornerRadius = 50
        groupImageView.layer.masksToBounds = true
        groupImageView.layer.borderWidth = 1
        groupImageView.layer.borderColor = UIColor.lightGray.cgColor
        groupImageView.isUserInteractionEnabled = true
        groupImageView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                   action: #selector(handleSelectGroupImageView)))
        return groupImageView
    }()
    
    
    lazy var nameGroupTextField : UITextField = {
        let nameGroupTextField = UITextField()
        nameGroupTextField.translatesAutoresizingMaskIntoConstraints = false
        nameGroupTextField.placeholder = Constant.nameGroupTxfPlaceholder
        nameGroupTextField.borderStyle = .roundedRect
        nameGroupTextField.layer.borderColor = UIColor.black.cgColor
        nameGroupTextField.textAlignment = .center
        
        return nameGroupTextField
    }()
    
    lazy var createGroupView : UIView = {
        let createGroupView = UIView()
        createGroupView.backgroundColor = Theme.shared.whiteColor
        createGroupView.translatesAutoresizingMaskIntoConstraints = false
        createGroupView.clipsToBounds = true
        createGroupView.layer.cornerRadius = 10
        
        let headingLabel = UILabel()
        headingLabel.backgroundColor = Theme.shared.secondaryColor
        headingLabel.translatesAutoresizingMaskIntoConstraints = false
        headingLabel.text = Constant.createGroupTitle
        headingLabel.textColor = Theme.shared.whiteColor
        headingLabel.font = UIFont.boldSystemFont(ofSize: 16)
        headingLabel.textAlignment = .center
        
        createGroupView.addSubview(headingLabel)
        headingLabel.topAnchor.constraint(equalTo: createGroupView.topAnchor).isActive = true
        headingLabel.leftAnchor.constraint(equalTo: createGroupView.leftAnchor).isActive = true
        headingLabel.widthAnchor.constraint(equalTo: createGroupView.widthAnchor).isActive = true
        headingLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        createGroupView.addSubview(groupImageView)
        groupImageView.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 20).isActive = true
        groupImageView.centerXAnchor.constraint(equalTo: createGroupView.centerXAnchor).isActive = true
        groupImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        groupImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        createGroupView.addSubview(nameGroupTextField)
        nameGroupTextField.topAnchor.constraint(equalTo: groupImageView.bottomAnchor, constant: 20).isActive = true
        nameGroupTextField.leftAnchor.constraint(equalTo: createGroupView.leftAnchor, constant: 10).isActive = true
        nameGroupTextField.rightAnchor.constraint(equalTo: createGroupView.rightAnchor, constant: -10).isActive = true
        nameGroupTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let btnCreate = UIButton()
        btnCreate.translatesAutoresizingMaskIntoConstraints = false
        btnCreate.setTitle(Constant.confirmCreateGroupTitle, for: .normal)
        btnCreate.tintColor = Theme.shared.whiteColor
        btnCreate.backgroundColor = Theme.shared.secondaryColor
        btnCreate.addTarget(self, action: #selector(handleCreateGroup), for: .touchUpInside)
        
        createGroupView.addSubview(btnCreate)
        btnCreate.bottomAnchor.constraint(equalTo: createGroupView.bottomAnchor).isActive = true
        btnCreate.leftAnchor.constraint(equalTo: createGroupView.leftAnchor).isActive = true
        btnCreate.widthAnchor.constraint(equalTo: createGroupView.widthAnchor, multiplier: 1/2).isActive = true
        btnCreate.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let separateView = UIView()
        separateView.backgroundColor = Theme.shared.whiteColor
        separateView.translatesAutoresizingMaskIntoConstraints = false
        
        createGroupView.addSubview(separateView)
        separateView.bottomAnchor.constraint(equalTo: createGroupView.bottomAnchor, constant: -1).isActive = true
        separateView.leftAnchor.constraint(equalTo: btnCreate.rightAnchor).isActive = true
        separateView.widthAnchor.constraint(equalToConstant: 1).isActive = true
        separateView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let btnCancel = UIButton()
        btnCancel.translatesAutoresizingMaskIntoConstraints = false
        btnCancel.setTitle(Constant.cancelTitle, for: .normal)
        btnCancel.tintColor = Theme.shared.whiteColor
        btnCancel.addTarget(self, action: #selector(handleCancelCreateGroup), for: .touchUpInside)
        btnCancel.backgroundColor = Theme.shared.secondaryColor
        
        createGroupView.addSubview(btnCancel)
        btnCancel.bottomAnchor.constraint(equalTo: createGroupView.bottomAnchor).isActive = true
        btnCancel.leftAnchor.constraint(equalTo: separateView.rightAnchor).isActive = true
        btnCancel.widthAnchor.constraint(equalTo: createGroupView.widthAnchor, multiplier: 1/2).isActive = true
        btnCancel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        return createGroupView
    }()
    
    lazy var blackView : UIView = {
        let blView  = UIView()
        blView.backgroundColor = UIColor(white: 0, alpha: 0.5)
        blView.frame = (window?.frame)!
        blView.addSubview(createGroupView)
        self.createGroupView.centerXAnchor.constraint(equalTo: blView.centerXAnchor).isActive = true
        self.createGroupView.centerYAnchor.constraint(equalTo: blView.centerYAnchor, constant: -50).isActive = true
        self.createGroupView.widthAnchor.constraint(equalTo: blView.widthAnchor, multiplier: 2/3).isActive = true
        self.createGroupView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        return blView
    }()
    
    //MARK: - VIEW LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegateAndRegister()
        MessagesHandler.shared.observeUserGroups()
        print("view did load group messages")
    }
    
    //MARK: SET DELEGATE AND REGISTER
    private func setDelegateAndRegister() {
        tableView.register(GroupCell.self, forCellReuseIdentifier: GroupsMessagesController.identifier)
        MessagesHandler.shared.delegateUserGroups = self
    }
    
    //MARK: - OVERRIDE FUNCTION
    override func setupBarButtonItem() {
        super.setupBarButtonItem()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleNewGroup))
    }
    
    @objc override func showMessageAction(cell: UserCell) {
        let indexTapped = tableView.indexPath(for: cell)
        let group = groups[indexTapped!.row]
        guard let uid = AuthProvider.shared.currentUserID else { return }
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if group.hostId != uid {
            let actionLeaveGroup = UIAlertAction(title: Constant.leaveGroupTitle, style: .destructive) { (alert) in
                self.leaveGroup(group: group)
            }
            alert.addAction(actionLeaveGroup)
        } else {
            let actionDeleteGroup = UIAlertAction(title: Constant.deleteGroupActionTitle, style: .destructive) { (alert) in
                self.confirmDeleteGroup(group: group)
            }
            alert.addAction(actionDeleteGroup)
        }
        
        let actionCancel = UIAlertAction(title: Constant.cancelTitle, style: .cancel, handler: nil)
        alert.addAction(actionCancel)
        self.present(alert,animated: true)
    }

    // MARK: - TABLEVIEW DELEGATE
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: GroupsMessagesController.identifier, for: indexPath) as! GroupCell
        cell.baseTableController = self
        let group =  groups[indexPath.row]
        cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: group.groupImageUrl!)
        cell.textLabel?.text = group.name
        cell.message = groupMessagesDictionary[group.id!]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group =  groups[indexPath.row]
        
        self.showGroupChatLogController(group: group)
    }
    
    //MARK: - HANDLE FUNCTION
    //schedule a table raload in 0.1 sec
    func attemptReloadOfTable() {
        self.timer?.invalidate()  //cancel timer
        self.timer = Timer.scheduledTimer(timeInterval: CONSTANT.TIME.REFRESH, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    @objc func handleReloadTable() {
        self.groups = Array(self.groupDictionary.values)
        if groups.count > 1 {
            self.groups.sort { (g1, g2) -> Bool in
                guard let mesG1 = self.groupMessagesDictionary[g1.id!], let mesG2 = self.groupMessagesDictionary[g2.id!]
                    else { return false }
                
                if (mesG1.timeStamp?.intValue)! > (mesG2.timeStamp?.intValue)! {
                    return true
                }
                return false
            }
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    @objc func handleCancelCreateGroup() {
        UIView.animate(withDuration: ANIMATION.FAST, animations: {
            self.blackView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.blackView.alpha = 0
        }) { (finish) in
            self.blackView.removeFromSuperview()
            self.groupImageView.image = #imageLiteral(resourceName: "groups")
            self.nameGroupTextField.text = nil
        }
    }
    
    @objc func handleCreateGroup() {
        guard !(nameGroupTextField.text?.isReallyEmpty)!
            else {
                createGroupView.shake(count: 5, for: ANIMATION.FAST, withTranslation: 5)
                return
        }
        let sv = UIViewController.displaySpinner (onView: window!)
        nameGroupTextField.resignFirstResponder()
        let nameGroup = nameGroupTextField.text!
        let image = groupImageView.image!
        
        DBProvider.shared.createGroupWith(name: nameGroup, image: image) { (error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            UIViewController.removeSpinner(spinner: sv)
            self.attemptReloadOfTable()
            self.handleCancelCreateGroup() //clear data when finish
        }
    }
    
    @objc func handleNewGroup(){
        window?.addSubview(blackView)
        blackView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        blackView.alpha = 0
        
        UIView.animate(withDuration: ANIMATION.FAST) {
            self.blackView.alpha = 1
            self.blackView.transform = CGAffineTransform.identity
        }
        self.nameGroupTextField.becomeFirstResponder()
    }
    
    func showGroupChatLogController(group: Group) {
        let groupChatLogController = GroupChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        groupChatLogController.groupChat = group
        groupChatLogController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(groupChatLogController, animated: true)
    }
    
    private func leaveGroup(group: Group) {
        guard let groupID = group.id else { return }
        DBProvider.shared.userLeaveGroup(groupID: groupID) { (error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
        }
    }
    
    private func confirmDeleteGroup(group: Group) {
        let alertController = UIAlertController(title: Constant.deleteGroupTitle, message: Constant.deleteGroupMessage, preferredStyle: .alert)
        let actionOk = UIAlertAction(title: Constant.confirmDeleteGroupTitle, style: .destructive) { (alert) in
            self.deleteGroup(group: group)
        }
        let actionCancel = UIAlertAction(title: Constant.cancelTitle, style: .cancel, handler: nil)
        
        alertController.addAction(actionOk)
        alertController.addAction(actionCancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func deleteGroup(group: Group) {
        let sv = UIViewController.displaySpinner(onView: window!)
        guard let groupID = group.id else { return }
        DBProvider.shared.deleteGroup(groupID: groupID) { (error) in
            if error != nil {
                UIViewController.removeSpinner(spinner: sv)
                print(error!.localizedDescription)
                return
            }
            self.groupDictionary.removeValue(forKey: group.id!)
            self.groupMessagesDictionary.removeValue(forKey: group.id!)
            self.attemptReloadOfTable()
            UIViewController.removeSpinner(spinner: sv)
        }
        
    }
    
}

extension GroupsMessagesController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @objc func handleSelectGroupImageView() {
        self.blackView.isHidden = true
        GallaryPicker.shared.showActionPhotoCamera(from: self) { (cancel) in
            if cancel {
               self.blackView.isHidden = false
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        handleImageSelectedForInfo(info: info)
        
        self.dismiss(animated: true) {
            self.blackView.isHidden = false
        }
    }
 
    func handleImageSelectedForInfo(info: [String: Any]) {
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[KEY_INFO.IMAGE.EDIT] as? UIImage {
            selectedImageFromPicker = editedImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            groupImageView.image = selectedImage
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true) {
            self.blackView.isHidden = false
        }
    }

}
//MARK: - FETCH USER GROUPS DELEGATE
extension GroupsMessagesController: FetchUserGroups {
    func dataReceived(groupDictionary: [String : Group], groupMessagesDictionary: [String : Message]) {
        self.groupDictionary = groupDictionary
        self.groupMessagesDictionary = groupMessagesDictionary
        attemptReloadOfTable()
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
