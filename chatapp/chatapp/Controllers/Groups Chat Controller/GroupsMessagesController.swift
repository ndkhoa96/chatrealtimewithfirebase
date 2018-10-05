//
//  GroupMessagesController.swift
//  chatapp
//
//  Created by Khoa Nguyen on 6/19/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit
import Firebase

class GroupsMessagesController: BaseTableViewController {
    
    var groups = [Group]()
    var groupDictionary = [String: Group]()
    var groupMessagesDictionary = [String : Message]()
    let cellId2 = "cellGroup"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleNewGroup))

        tableView.register(GroupCell.self, forCellReuseIdentifier: cellId2)
        observeGroups()
    }
    
    
    func observeGroups(){
        groups.removeAll()
        groupMessagesDictionary.removeAll()
        tableView.reloadData()
        
        let uid =  AuthProvider.shared.userID
        
        let dbRef = Database.database().reference().child(KEY_DATA.USER_GROUPS.ROOT).child(uid)
        dbRef.observe(.childAdded, with: { (snapshot) in
            
            let groupId = snapshot.key
            
            Database.database().reference().child("groups").child(groupId).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject]{
                    let group = Group(values: dictionary)
                    group.id = snapshot.key
                    
                    self.groupDictionary[group.id!] = group
                    self.attemptReloadOfTable()
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        
                    }
                }
            }, withCancel: nil)
            print("Group ID: \(groupId)")
            self.observeGroupMessages(groupId: groupId)
            
        }, withCancel: nil)
        
        
        dbRef.observe(.childRemoved, with: { (snapshot) in
            print("User-Groups Remove key: ",snapshot.key)
            self.groupMessagesDictionary.removeValue(forKey: snapshot.key)
            self.groupDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadOfTable()
        }, withCancel: nil)
        
    }
    
    
    func observeGroupMessages(groupId: String ){
        
        let dbRef = Database.database().reference().child(KEY_DATA.GROUP_MESSAGES.ROOT).child(groupId)
        dbRef.observe(.childAdded, with: { (snapshot) in
            
            let messageId = snapshot.key
            self.fetchGroupMessageWithMessageId(messageId: messageId)
            
        }, withCancel: nil)
    }
    
    func fetchGroupMessageWithMessageId(messageId: String){
        
        let messagesRef = Database.database().reference().child(KEY_DATA.MESSAGE.ROOT).child(messageId)
        messagesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{
                let message = Message(values: dictionary)
                
                if let chatMemberId = message.toID {
                    self.groupMessagesDictionary[chatMemberId] = message
                    
                }
                
                self.attemptReloadOfTable()
            }
        }, withCancel: nil)
    }
    var timer:Timer?
    
    func attemptReloadOfTable(){
        self.timer?.invalidate()
        //print("cancel timer")
        self.timer = Timer.scheduledTimer(timeInterval: TIME.REFRESH, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
        //print("schedule a table raload in 0.1 sec")
    }
    
    @objc func handleReloadTable(){
        self.groups = Array(self.groupDictionary.values)
        if(groups.count > 1){
            self.groups.sort { (g1, g2) -> Bool in
                guard let mesG1 = self.groupMessagesDictionary[g1.id!], let mesG2 = self.groupMessagesDictionary[g2.id!]
                    else {
                        return false
                }
                
                if (mesG1.timeStamp?.intValue)! > (mesG2.timeStamp?.intValue)! {
                    return true
                }
                return false
            }
        }
        
        DispatchQueue.main.async {
            print("reload table")
            
            self.tableView.reloadData()
        }
    }
    
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
        groupImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectProfileImageView)))
        return groupImageView
    }()
    
    
    lazy var nameGroupTextField : UITextField = {
        let nameGroupTextField = UITextField()
        nameGroupTextField.translatesAutoresizingMaskIntoConstraints = false
        nameGroupTextField.placeholder = "Name of group"
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
        headingLabel.text = "Create Group Chat"
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
        btnCreate.setTitle("Create", for: .normal)
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
        btnCancel.setTitle("Cancel", for: .normal)
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
    
    
    @objc func handleCancelCreateGroup(){
        
        UIView.animate(withDuration: ANIMATION.FAST, animations: {
            self.blackView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.blackView.alpha = 0
            
        }) { (finish) in
            self.blackView.removeFromSuperview()
            self.groupImageView.image = #imageLiteral(resourceName: "groups")
            self.nameGroupTextField.text = nil
        }
        
    }
    let window = UIApplication.shared.keyWindow
    
    @objc func handleCreateGroup(){
        
        guard !(nameGroupTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)!
            else {
                createGroupView.shake(count: 5, for: ANIMATION.FAST, withTranslation: 5)
                return
        }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let sv = UIViewController.displaySpinner (onView: window!)
        nameGroupTextField.resignFirstResponder()
        
        let storageRef = Storage.storage().reference().child(KEY_DATA.STORAGE.GROUP_IMAGES).child("\(nameGroupTextField.text!).jpg")
        
        if let uploadData = self.groupImageView.image!.jpegData(compressionQuality: 0.1) {
            
            storageRef.putData(uploadData, metadata: nil, completion: { (metaData, error) in
                
                if error != nil{
                    print(error!)
                    return
                }
                if let groupImageUrl = metaData?.downloadURL()?.absoluteString{
                    
                    let values = [KEY_DATA.USER.NAME: self.nameGroupTextField.text!, KEY_DATA.GROUP.GROUP_IMAGE_URL: groupImageUrl, KEY_DATA.GROUP.HOST_ID: uid]
                    let dbRefGroup = Database.database().reference().child("groups").childByAutoId()
                    let keyAutoId = dbRefGroup.key
                    dbRefGroup.updateChildValues(values, withCompletionBlock: { (err, ref) in
                        
                        if err != nil {
                            print("ERROR: \(err!)")
                            return
                        }
                        self.updateUserGroupAndGroupMember(childId: uid, idGroup: keyAutoId, nameGroup: self.nameGroupTextField.text!)
                        UIViewController.removeSpinner(spinner: sv)
                        self.handleCancelCreateGroup()
                        
                    })
                }
                
            })
        }
    }
    let role = "admin"
    
    func updateUserGroupAndGroupMember(childId: String, idGroup: String, nameGroup: String){

        DBProvider.shared.user_groups.child(childId).updateChildValues([idGroup: role])
        DBProvider.shared.group_members.child(idGroup).updateChildValues([childId: role])
        sendMessageWithProperties(childId: childId, idGroup: idGroup, nameGroup: nameGroup)
        
        attemptReloadOfTable()
    }
    
    func sendMessageWithProperties(childId: String, idGroup: String, nameGroup: String){
        let dbRef = DBProvider.shared.messages
        let childRef = dbRef.childByAutoId()
        let timeStamp = Int(NSDate().timeIntervalSince1970)
        
        let values = [KEY_DATA.MESSAGE.FROM_ID: childId,KEY_DATA.MESSAGE.TO_ID: idGroup , KEY_DATA.MESSAGE.TIME_STAMP: timeStamp, KEY_DATA.MESSAGE.TEXT: "Create the group - \(nameGroup)"] as [String: AnyObject]
        
        childRef.updateChildValues(values) { (error, dbRef) in
            if error != nil{
                print(error!)
                return
            }
            
            let messagesId = childRef.key
            let groupMessagesRef = DBProvider.shared.group_messages.child(idGroup)
            groupMessagesRef.updateChildValues([messagesId: 1])
            
            
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
    
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId2, for: indexPath) as! GroupCell
        cell.baseTableController = self
        let group =  groups[indexPath.row]
        cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: group.groupImageUrl!)
        cell.textLabel?.text = group.name
        cell.message = groupMessagesDictionary[group.id!]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group =  groups[indexPath.row]
        
        self.showChatControllerForUser(group: group)
        
    }
    
    
    func showChatControllerForUser(group: Group){
        let groupChatLogController = GroupChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        groupChatLogController.group = group
        groupChatLogController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(groupChatLogController, animated: true)
    }
    
    var indexGroupChange: Int?
    
    @objc override func showActionSheet(cell: UserCell) {
        let indexTapped = tableView.indexPath(for: cell)
        let group = groups[indexTapped!.row]
        indexGroupChange = indexTapped!.row
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
 
        
        if group.hostId != uid {
            let actionLeaveGroup = UIAlertAction(title: "Leave This Group", style: .destructive) { (alert) in
                self.leaveGroup(group: group)
            }
            alert.addAction(actionLeaveGroup)
        }else{
            let actionChangeImage = UIAlertAction(title: "Change Group Image", style: .default) { (alert) in
                self.changeGroupImage()
            }
            alert.addAction(actionChangeImage)
            
            let actionDeleteGroup = UIAlertAction(title: "Delete This Group", style: .destructive) { (alert) in
                self.confirmDeleteGroup(group: group)
            }
            alert.addAction(actionDeleteGroup)
            
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        
        alert.addAction(actionCancel)
        self.present(alert,animated: true)
    }
    
    
    private func changeGroupImage(){
        changeGroupImageFlag = true
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        let actionGallery = UIAlertAction(title: "Open Gallery", style: .default) { (alert) in
            GallaryPicker.shared.open(.gallery, from: self)
        }
        let actionCamera = UIAlertAction(title: "Take a picture", style: .default) { (alert) in
            GallaryPicker.shared.open(.camera, from: self)
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(actionGallery)
        alert.addAction(actionCamera)
        alert.addAction(actionCancel)
        self.present(alert,animated: true)
    }
    
//    var imageGalleryPickerController = UIImagePickerController()
//    var imageCameraPickerController = UIImagePickerController()
//
//    func openCamera() {
//        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
//            imageCameraPickerController.delegate = self
//            imageCameraPickerController.sourceType = UIImagePickerController.SourceType.camera
//            imageCameraPickerController.allowsEditing = true
//
//            self.present(self.imageCameraPickerController, animated: true, completion: nil)
//        }
//        else {
//            let alertWarning = UIAlertController(title:"Warning", message: "You don't have camera", preferredStyle: .alert)
//            let actionOk = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
//            alertWarning.addAction(actionOk)
//
//            self.present(alertWarning, animated: true, completion: nil)
//        }
//    }
    
    var changeGroupImageFlag = false
    
//    func openGallery(){
//
//        imageGalleryPickerController.delegate = self
//        imageGalleryPickerController.allowsEditing = true
//
//        self.present(imageGalleryPickerController, animated: true, completion: nil)
//
//
//    }
    
    private func leaveGroup(group: Group){
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        DBProvider.shared.group_members.child(group.id!).child(uid).removeValue { (error, ref) in
            if error != nil {
                print("Failed to leave group: ", error!)
                return
            }
        }
        Database.database().reference().child(KEY_DATA.USER_GROUPS.ROOT).child(uid).child(group.id!).removeValue{ (error, ref) in
            if error != nil {
                print("Failed to leave group: ", error!)
                return
            }
        }
        
        
    }
    
    private func confirmDeleteGroup(group: Group){
        let alertController = UIAlertController(title: "Delete This Group", message: "This will be permanently delete all the conversation in this group.", preferredStyle: .alert)
        let actionOk = UIAlertAction(title: "Delete This Group", style: .destructive) { (alert) in
            self.deleteGroup(group: group)
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(actionOk)
        alertController.addAction(actionCancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func deleteGroup(group: Group){
        
        let sv = UIViewController.displaySpinner(onView: window!)
        
        DBProvider.shared.group_members.child(group.id!).observe(.childAdded, with: { (snapshot) in
            Database.database().reference().child(KEY_DATA.USER_GROUPS.ROOT).child(snapshot.key).child(group.id!).removeValue{ (error, ref) in
                if error != nil {
                    print("Failed to delete group: ", error!)
                    return
                }
            }
            
        }, withCancel: nil)
        
        
        Database.database().reference().child("groups").child(group.id!).removeValue { (error, ref) in
            if error != nil {
                print("Failed to delete group: ", error!)
                return
            }
            DBProvider.shared.group_members.child(group.id!).removeValue { (error, ref) in
                if error != nil {
                    print("Failed to delete group: ", error!)
                    return
                }
            }
            self.groupDictionary.removeValue(forKey: group.id!)
            self.groupMessagesDictionary.removeValue(forKey: group.id!)
            self.attemptReloadOfTable()
            UIViewController.removeSpinner(spinner: sv)
        }
        
    }
    
    
}

extension GroupsMessagesController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    @objc func handleSelectProfileImageView(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        self.blackView.isHidden = true
        self.present(picker, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        
        handleImageSelectedForInfo(info: info)
        
        self.dismiss(animated: true) {
            self.blackView.isHidden = false
        }
    }
    
    
    
    func handleImageSelectedForInfo(info: [String: Any]){
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[KEY_INFO.IMAGE.EDIT] as? UIImage{
            selectedImageFromPicker = editedImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            if changeGroupImageFlag {
                let sv = UIViewController.displaySpinner(onView: view)
                // Create a reference to the file to delete
                let storageRef = Storage.storage().reference().child(KEY_DATA.STORAGE.GROUP_IMAGES).child(groups[indexGroupChange!].name!+".jpg")

                // Delete the file
                storageRef.delete { error in
                    if error != nil {
                        print(error!)
                        return
                    }
                    print("File deleted successfully")

                    if let data = selectedImage.jpegData(compressionQuality: 0.1){
                        storageRef.putData(data, metadata: nil, completion: { (metadata, error) in

                            if error != nil{
                                print("Fail to upload image", error!)
                                return
                            }

                            let groupReference = Database.database().reference().child("groups").child(self.groups[self.indexGroupChange!].id!)

                            if let imageUrl = metadata?.downloadURL()?.absoluteString{
                                groupReference.updateChildValues([KEY_DATA.GROUP.GROUP_IMAGE_URL : imageUrl], withCompletionBlock: { (err, ref) in
                                    if err != nil{
                                        print(err!)
                                        return
                                    }
                                    self.groups[self.indexGroupChange!].groupImageUrl = imageUrl
                                    UIViewController.removeSpinner(spinner: sv)
                                    self.changeGroupImageFlag = false
                                    self.indexGroupChange = nil
                                    self.attemptReloadOfTable()
                                })
                            }

                        })
                    }
                }
            }else{
                groupImageView.image = selectedImage
            }
        }
    }
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true) {
            self.blackView.isHidden = false
            self.changeGroupImageFlag = false
            self.indexGroupChange = nil
        }
    }
    
    
}


// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
