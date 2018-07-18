//
//  PersionalPageViewController.swift
//  chatapp
//
//  Created by Khoa Nguyen on 7/4/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit
import Firebase

class PersionalPageViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate  {
    
    var user : User?
    
    let cellInforId = "CellInforId"
    let cellPhotosId = "CellPhotosId"
    let headerBackGroundId = "HeaderBackGroundId"
    let headerSecondId = "HeaderSecondId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(InformationCell.self, forCellWithReuseIdentifier: cellInforId)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: cellPhotosId)
        collectionView?.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerBackGroundId)
        collectionView?.register(HeaderView2.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerSecondId)
        collectionView?.backgroundColor = UIColor.gray
   
        
        self.navigationController?.navigationBar.barTintColor = UIColor.clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = .clear
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.navigationController?.navigationBar.addGestureRecognizer(tapGesture!)
        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"ic_back"), style: .plain, target: self, action: #selector(handleBack))
        self.navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: -12, bottom: 0, right: 12)
        
        collectionView?.contentInset = UIEdgeInsets(top: -70, left: 0, bottom: 30, right: 0)
   
    }
    var heightItem = 60
    var widthItem = Int(UIScreen.main.bounds.width)
    var minimumLineSpacingForSection = 5.0
    var minimumInteritemSpacingForSection = 0.0

    var flag = false
    
    func fetchUserInformation(){
        minimumInteritemSpacingForSection = 0.0
        minimumLineSpacingForSection = 5.0
        heightItem = 60
        widthItem = Int(view.frame.width)
        flag = false
        collectionView?.reloadData()
        
    }
    
    func fetchUserPhotos(){
        heightItem = Int((view.frame.width / 3.0))-1
        widthItem = heightItem
        minimumInteritemSpacingForSection = 1.0
        minimumLineSpacingForSection = 1.0
        flag = true
        collectionView?.reloadData()
    }
    
    func setUpHeader(){
        //collectionView.h
    }
    
    
    var tapGesture : UITapGestureRecognizer?
    
    @objc func handleTap(){
        
    }
    
    var startingFrame: CGRect?
    var blackBackground: UIView?
    var startingImageView: UIImageView?
    var zoomingImageView: UIImageView?
    
    let btnMore : UIButton = {
       let btn = UIButton()
        let origImage = UIImage(named: "ic_more")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        btn.setImage(tintedImage, for: .normal)
        btn.tintColor = Theme.shared.whiteColor
        btn.addTarget(self, action: #selector(handleMore), for: .touchUpInside)
        
        return btn
       
    }()
    
    @objc func handleMore(){
        
        let actionSheetAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actionChange = UIAlertAction(title: "Change Profile Image", style: .default) { (alert) in
            self.changeProfileImageFlag = true
            print(123)

            self.handleChangeAvatar()
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        actionSheetAlert.addAction(actionChange)
        actionSheetAlert.addAction(actionCancel)
        
        self.present(actionSheetAlert, animated: true, completion: nil)
   
       
    }
    
    func handleChangeAvatar(){
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        let actionGallery = UIAlertAction(title: "Open Gallery", style: .default) { (alert) in
            self.openGallery()
        }
        let actionCamera = UIAlertAction(title: "Take a picture", style: .default) { (alert) in
            self.openCamera()
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(actionGallery)
        alert.addAction(actionCamera)
        alert.addAction(actionCancel)
        self.present(alert,animated: true)
    }
    
    var imageGalleryPickerController = UIImagePickerController()
    var imageCameraController = UIImagePickerController()
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            imageCameraController.delegate = self
            imageCameraController.sourceType = UIImagePickerControllerSourceType.camera
            imageCameraController.allowsEditing = true
            
            self.present(self.imageCameraController, animated: true, completion: nil)
        }
        else {
            let alertWarning = UIAlertController(title:"Warning", message: "You don't have camera", preferredStyle: .alert)
            let actionOk = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alertWarning.addAction(actionOk)
            
            self.present(alertWarning, animated: true, completion: nil)
        }
    }
    
    func openGallery(){
        
        imageGalleryPickerController.delegate = self
        imageGalleryPickerController.allowsEditing = true
        
        self.present(imageGalleryPickerController, animated: true, completion: nil)
        
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        handleImageSelectedForInfo(info: info)
    
        dismiss(animated: true, completion: nil)
        
        
    }
    
    var btv: BaseTableViewController?
    
    var changeProfileImageFlag = false
    var changeBackgroundImageFlag = false
    
    
    func handleImageSelectedForInfo(info: [String: Any]){
        var selectedImageFromPicker: UIImage?

        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }
       
        
        if let selectedImage = selectedImageFromPicker{
            
            if changeProfileImageFlag {
                let sv = UIViewController.displaySpinner(onView: view)
                // Create a reference to the file to delete
                let storageRef = Storage.storage().reference().child("profile_images").child((user?.email)!+".jpg")
                
                // Delete the file
                storageRef.delete { error in
                    if error != nil {
                        print(error!)
                        return
                    }
                    print("File deleted successfully")
                    
                    if let data = UIImageJPEGRepresentation(selectedImage, 0.1){
                        storageRef.putData(data, metadata: nil, completion: { (metadata, error) in
                            
                            if error != nil{
                                print("Fail to upload image", error!)
                                return
                            }

                            let userReference = Database.database().reference().child("users").child((self.user?.id)!)
                            
                            if let imageUrl = metadata?.downloadURL()?.absoluteString{
                                userReference.updateChildValues(["profileImageUrl" : imageUrl], withCompletionBlock: { (err, ref) in
                                    if err != nil{
                                        print(err!)
                                        return
                                    }
                                    self.user?.profileImageUrl = imageUrl
                                    //self.btv?.fetchUserAndSetupNavBarTitle()
                                    UIViewController.removeSpinner(spinner: sv)
                                    
                                    DispatchQueue.main.async {
                                        self.collectionView?.reloadData()
                                    }
                                })
                            }
                            
                        })
                    }
                }
                
                
            }else if changeBackgroundImageFlag {
                let sv = UIViewController.displaySpinner(onView: view)
                // Create a reference to the file to delete
                let storageRef = Storage.storage().reference().child("background_images").child((user?.email)!+".jpg")
                
                // Delete the file
                storageRef.delete { error in
                    if error != nil {
                        print(error!)
                        return
                    }
                    print("File deleted successfully")
                    
                    if let data = UIImageJPEGRepresentation(selectedImage, 0.1){
                        storageRef.putData(data, metadata: nil, completion: { (metadata, error) in
                            
                            if error != nil{
                                print("Fail to upload image", error!)
                                return
                            }
                            
                            let userReference = Database.database().reference().child("users").child((self.user?.id)!)
                            
                            if let imageUrl = metadata?.downloadURL()?.absoluteString{
                                userReference.updateChildValues(["backgroundImageUrl" : imageUrl], withCompletionBlock: { (err, ref) in
                                    if err != nil{
                                        print(err!)
                                        return
                                    }
                                    self.user?.backgroundImageUrl = imageUrl
                                    UIViewController.removeSpinner(spinner: sv)
                                    
                                    DispatchQueue.main.async {
                                        self.collectionView?.reloadData()
                                    }
                                })
                            }
                            
                        })
                    }
                    
                }
            }
                
            changeProfileImageFlag = false
            changeBackgroundImageFlag = false
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        changeProfileImageFlag = false
        changeBackgroundImageFlag = false
        dismiss(animated: true, completion: nil)
    }
    
    func performZoomForImageView(startingImageView: UIImageView, hideMoreButton: Bool){
        navigationController?.navigationBar.isHidden = true
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        btnMore.frame = CGRect(x: view.frame.width - 40 , y: 30, width: 35, height: 35)
        
        zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView?.backgroundColor = UIColor.red
        zoomingImageView?.image = startingImageView.image
        zoomingImageView?.isUserInteractionEnabled = true
        zoomingImageView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOutTap)))

        blackBackground = UIView(frame: view.frame)
        blackBackground?.backgroundColor = UIColor.black
        blackBackground?.alpha = 0
        
        view.addSubview(blackBackground!)
        view.addSubview(zoomingImageView!)
        if hideMoreButton {
            view.addSubview(btnMore)
            
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
            self.blackBackground?.alpha = 1
            
            // h2 = h1/w1 * w2
            let height = ((self.startingFrame?.height)! / (self.startingFrame?.width)!) * self.view.frame.width
            
            self.zoomingImageView?.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: height)
            self.zoomingImageView?.center = self.view.center
            
        }, completion: nil)
        
    }
    
    @objc func handleZoomOutTap(tapGesture: UITapGestureRecognizer){
        navigationController?.navigationBar.isHidden = false
        if let zoomOutImageView = tapGesture.view{
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            self.btnMore.removeFromSuperview()
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackground?.alpha = 0
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                
                self.startingImageView?.isHidden = false
            })
            
        }
    }
    
    func viewEditProfileImage(header: HeaderView){

        performZoomForImageView(startingImageView: header.profileImageView, hideMoreButton: true)
        
    }
    
    func viewEditBackgroundImage(header: HeaderView){

        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actionViewImage = UIAlertAction(title: "View Background Image", style: .default) { (alert) in
            self.performZoomForImageView(startingImageView: header.backgroundImageView, hideMoreButton: false)
        }
        alert.addAction(actionViewImage)
        
        let actionChangeImage = UIAlertAction(title: "Change Background Image", style: .default) { (alert) in
            self.changeBackgroundImageFlag = true
            self.handleChangeBackgroundImage()
        }
        
        alert.addAction(actionChangeImage)
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        
        alert.addAction(actionCancel)
        self.present(alert,animated: true)
    }
    
    @objc func handleChangeBackgroundImage(){
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        let actionGallery = UIAlertAction(title: "Open Gallery", style: .default) { (alert) in
            self.openGallery()
        }
        let actionCamera = UIAlertAction(title: "Take a picture", style: .default) { (alert) in
            self.openCamera()
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(actionGallery)
        alert.addAction(actionCamera)
        alert.addAction(actionCancel)
        self.present(alert,animated: true)
    }
    
    @objc func handleBack(){
        self.navigationController?.navigationBar.barTintColor = Theme.shared.secondaryColor
        self.navigationController?.navigationBar.backgroundColor = Theme.shared.secondaryColor
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.removeGestureRecognizer(tapGesture!)
        navigationController?.popViewController(animated: true)
        
    }
    
    func namePhoneEdit(infor: String){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        var value : [String: Any]?
        switch infor {
        case "name":
            alert.title = "Edit nick name"
            alert.addTextField { (tf) in
                tf.text = self.user?.name
            }
        case "fullName":
            alert.title = "Edit full name"
            alert.addTextField { (tf) in
                tf.text = self.user?.fullName
            }
        case "phoneNumber":
            alert.title = "Edit phone number"
            alert.addTextField { (tf) in
                tf.text = self.user?.phoneNumber
                tf.keyboardType = .phonePad
                
            }
        default:
            break
        }
  
        let actionOk = UIAlertAction(title: "Ok", style: .default) { (alertController) in
            let tf = alert.textFields![0] as UITextField

            let userReference = Database.database().reference().child("users").child((self.user?.id)!)
            switch infor {
            case "name":
                value = ["name": tf.text!]
            case "fullName":
                value = ["fullName": tf.text!]
            case "phoneNumber":
                value = ["phoneNumber": tf.text!]
            default:
                break
            }
      
            userReference.updateChildValues(value!, withCompletionBlock: { (err, ref) in
                if err != nil{
                    print(err!)
                    return
                }
                switch infor {
                case "name":
                    self.user?.name = tf.text!
                case "fullName":
                    self.user?.fullName = tf.text!
                case "phoneNumber":
                    self.user?.phoneNumber = tf.text!
                default:
                    break
                }
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            })
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)

        alert.addAction(actionOk)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    var birthDateTextField: UITextField?
    let dateFormatter : DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()
   
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        
        textField.inputView = datePicker
        if let birthDay = self.user?.birthDay{
            textField.text = birthDay
            datePicker.date = dateFormatter.date(from: birthDay)!
        }else{
            textField.text = dateFormatter.string(from: datePicker.date)
        }
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
    }

    
    @objc func datePickerValueChanged(_ sender: UIDatePicker){
     
        birthDateTextField?.text = dateFormatter.string(from: sender.date)
    }
    
    
    func birthDayEdit(){
        let alert = UIAlertController(title: "Edit birthday", message: nil, preferredStyle: .alert)
        alert.addTextField { (tf) in
            self.birthDateTextField = tf
            self.birthDateTextField?.delegate = self


        }
        
        
        
        let actionOk = UIAlertAction(title: "Ok", style: .default) { (alertController) in
            let userReference = Database.database().reference().child("users").child((self.user?.id)!)
            userReference.updateChildValues(["birthDay": (self.birthDateTextField?.text)!], withCompletionBlock: { (err, ref) in
                if err != nil{
                    print(err!)
                    return
                }
                self.user?.birthDay = self.birthDateTextField?.text!
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            })
            
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alert.addAction(actionOk)
        alert.addAction(actionCancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    func handleEditInfor(cell: UICollectionViewCell){
        let indexTapped = collectionView?.indexPath(for: cell)
        switch indexTapped?.item {
        case 1: namePhoneEdit(infor: "name")
        case 2: namePhoneEdit(infor: "fullName")
        case 4: birthDayEdit()
        case 5: namePhoneEdit(infor: "phoneNumber")
        
        default:
            break
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if !flag{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellInforId, for: indexPath) as! InformationCell
            cell.personalViewController = self
            
            switch indexPath.row {
                
            case 0:
                cell.label.text = "Email:"
                cell.imageView.image = UIImage(named: "ic_mail")
                cell.labelInfo.text = user?.email
                cell.btnEdit.isHidden = true
            case 1:
                cell.label.text = "Nick name:"
                cell.imageView.image = UIImage(named: "ic_nickname")
                if user?.id != Auth.auth().currentUser?.uid{
                    cell.btnEdit.isHidden = true
                }else{
                    cell.btnEdit.isHidden = false
                }
                if let name = user?.name {
                    cell.labelInfo.text = name
                    cell.labelInfo.textColor = UIColor.black
                    cell.labelInfo.font = UIFont.systemFont(ofSize: 16)
                }else{
                    cell.labelInfo.text = "Not update..."
                    cell.labelInfo.textColor = UIColor.lightGray
                    cell.labelInfo.font = UIFont.italicSystemFont(ofSize: 16)
                }
                
            case 2:
                cell.label.text = "Full name:"
                cell.imageView.image = UIImage(named: "ic_man")
                if let fullName = user?.fullName {
                    cell.labelInfo.text = fullName
                    cell.labelInfo.textColor = UIColor.black
                    cell.labelInfo.font = UIFont.systemFont(ofSize: 16)
                }else{
                    cell.labelInfo.text = "Not update..."
                    cell.labelInfo.textColor = UIColor.lightGray
                    cell.labelInfo.font = UIFont.italicSystemFont(ofSize: 16)
                }
            case 3:
                cell.label.text = "Gender:"
                cell.imageView.image = UIImage(named: "ic_gender")
                if let gender = user?.gender {
                    cell.labelInfo.text = gender
                    cell.labelInfo.textColor = UIColor.black
                    cell.labelInfo.font = UIFont.systemFont(ofSize: 16)
                }else{
                    cell.labelInfo.text = "Not update..."
                    cell.labelInfo.textColor = UIColor.lightGray
                    cell.labelInfo.font = UIFont.italicSystemFont(ofSize: 16)
                }
            case 4:
                cell.label.text = "Birthday:"
                cell.imageView.image = UIImage(named: "ic_birthday")
                if let birthDay = user?.birthDay {
                    cell.labelInfo.text = birthDay
                    cell.labelInfo.textColor = UIColor.black
                    cell.labelInfo.font = UIFont.systemFont(ofSize: 16)
                }else{
                    cell.labelInfo.text = "Not update..."
                    cell.labelInfo.textColor = UIColor.lightGray
                    cell.labelInfo.font = UIFont.italicSystemFont(ofSize: 16)
                }
            case 5:
                cell.label.text = "Phone:"
                cell.imageView.image = UIImage(named: "ic_phone")
                if let phoneNum = user?.phoneNumber {
                    cell.labelInfo.text = phoneNum
                    cell.labelInfo.textColor = UIColor.black
                    cell.labelInfo.font = UIFont.systemFont(ofSize: 16)
                }else{
                    cell.labelInfo.text = "Not update..."
                    cell.labelInfo.textColor = UIColor.lightGray
                    cell.labelInfo.font = UIFont.italicSystemFont(ofSize: 16)
                }

            default:
                break
            }
            cell.label.underline()
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellPhotosId, for: indexPath) as! PhotoCell
            return cell
        }

    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 0
        }
        if flag {
            return 10
        }else{
            return 6
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let section = indexPath.section
        
        switch section {
        case 0:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerBackGroundId, for: indexPath) as! HeaderView
            headerView.personalPageVC = self
            headerView.nameLabel.text = user?.name!
            
            if let profileImageUrl = user?.profileImageUrl{
                headerView.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
            }
            if let backgroundImageUrl = user?.backgroundImageUrl{
                headerView.backgroundImageView.loadImageUsingCacheWithUrlString(urlString: backgroundImageUrl)
            }
            
            return headerView
        default:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerSecondId, for: indexPath) as! HeaderView2
            headerView.personalPageVC = self
            
            return headerView
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        if section == 0 {
            return CGSize(width: collectionView.frame.width, height: 300)
        }
        return CGSize(width: collectionView.frame.width, height: 40)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {


        return CGSize(width: widthItem, height: heightItem)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(minimumLineSpacingForSection)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(minimumInteritemSpacingForSection)
    }
    
    
    
}

class HeaderView : UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let lpg = UILongPressGestureRecognizer(target: self, action: #selector(handleBackgroundImageView))
        lpg.minimumPressDuration = 1
        backgroundImageView.addGestureRecognizer(lpg)
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAvatar)))
        setUpView()

    }
    
    var personalPageVC : PersionalPageViewController?
    
    @objc func handleBackgroundImageView(){
        personalPageVC?.viewEditBackgroundImage(header: self)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpView(){

        addSubview(backgroundImageView)
        backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        backgroundImageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        backgroundImageView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        backgroundImageView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        backgroundImageView.addSubview(profileImageView)
        profileImageView.leftAnchor.constraint(equalTo: backgroundImageView.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -4).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        backgroundImageView.addSubview(nameLabel)
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.widthAnchor.constraint(equalToConstant: 300).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
  
    }
    
    var backgroundImageView : UIImageView = {
        let imV = UIImageView()
        imV.translatesAutoresizingMaskIntoConstraints = false
        imV.image = UIImage(named: "person_bg2")
        imV.isUserInteractionEnabled = true
        return imV
    }()
    
    var profileImageView : UIImageView = {
        let imV = UIImageView(image: UIImage(named: "test"))
        imV.translatesAutoresizingMaskIntoConstraints = false
        imV.contentMode = .scaleAspectFill
        imV.isUserInteractionEnabled = true
        imV.layer.cornerRadius = 50
        imV.layer.masksToBounds = true
        imV.layer.borderWidth = 1
        imV.layer.borderColor = Theme.shared.whiteColor.cgColor
        imV.isUserInteractionEnabled = true

        return imV
    }()
    
    
    var nameLabel : UILabel = {
        let label = UILabel()
        label.text = "Khoa Nguyen"
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = Theme.shared.whiteColor
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        
        
        return label
    }()
    
    @objc func handleAvatar() {
        personalPageVC?.viewEditProfileImage(header: self)
    }
}

class HeaderView2 : UICollectionReusableView {
    
    var personalPageVC : PersionalPageViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        setUpView()
    }
    
    func setUpView(){
        
        self.addSubview(btnInfo)
        btnInfo.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        btnInfo.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        btnInfo.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1/2).isActive = true
        btnInfo.heightAnchor.constraint(equalToConstant: self.frame.height - 16).isActive = true
        
        let separateView = UIView()
        separateView.translatesAutoresizingMaskIntoConstraints = false
        separateView.backgroundColor = UIColor.gray
        
        self.addSubview(separateView)
        separateView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        separateView.leftAnchor.constraint(equalTo: btnInfo.rightAnchor).isActive = true
        separateView.widthAnchor.constraint(equalToConstant: 1).isActive = true
        separateView.heightAnchor.constraint(equalToConstant: self.frame.height - 16).isActive = true
        
        self.addSubview(btnPhotos)
        btnPhotos.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        btnPhotos.leftAnchor.constraint(equalTo: separateView.rightAnchor).isActive = true
        btnPhotos.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1/2).isActive = true
        btnPhotos.heightAnchor.constraint(equalToConstant: self.frame.height - 16).isActive = true
        
    }
    
    let btnInfo : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Information", for: .normal)
        btn.setTitleColor(Theme.shared.secondaryColor, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.addTarget(self, action: #selector(handleInformation), for: .touchUpInside)
        
        return btn
    }()
    
    
    @objc func handleInformation(){
        personalPageVC?.fetchUserInformation()
        btnInfo.setTitleColor(Theme.shared.secondaryColor, for: .normal)
        btnPhotos.setTitleColor(Theme.shared.grayColor, for: .normal)
    }
    
    @objc func handlePhotos(){
        personalPageVC?.fetchUserPhotos()
        btnInfo.setTitleColor(Theme.shared.grayColor, for: .normal)
        btnPhotos.setTitleColor(Theme.shared.secondaryColor, for: .normal)
        
    }
    
    let btnPhotos : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Photos", for: .normal)
        btn.setTitleColor(Theme.shared.grayColor, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.addTarget(self, action: #selector(handlePhotos), for: .touchUpInside)
        
        return btn
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

