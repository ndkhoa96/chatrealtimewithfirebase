//
//  PersionalPageViewController.swift
//  chatapp
//
//  Created by Khoa Nguyen on 7/4/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit
import Firebase

class PersionalPageViewController : UICollectionViewController, UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var user : User? {
        didSet{
            self.fetchUserPhotos()
        }
    }
    var imageUrls = [String]()
    var imageUrlsDictionary = [String : String]()
    
    let cellInforId = "CellInforId"
    let cellPhotosId = "CellPhotosId"
    let headerBackGroundId = "HeaderBackGroundId"
    let headerSecondId = "HeaderSecondId"
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.register(InformationCell.self, forCellWithReuseIdentifier: cellInforId)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: cellPhotosId)
        collectionView?.register(BackgroundImageHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerBackGroundId)
        collectionView?.register(InformationAndPhotosHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerSecondId)
        collectionView?.backgroundColor = Theme.shared.lightGrayColor
   
        
        self.navigationController?.navigationBar.barTintColor = UIColor.clear
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.backgroundColor = .clear

        self.navigationItem.hidesBackButton = true
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named:"ic_back"), style: .plain, target: self, action: #selector(handleBack))
        self.navigationItem.leftBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: -12, bottom: 0, right: 12)
        
        
        if user?.id == Auth.auth().currentUser?.uid {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"ic_add_photo"), style: .plain, target: self, action: #selector(handleAddPhoto))
            self.navigationItem.rightBarButtonItem?.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -6)
            btnMore.isHidden = false
        }
        collectionView?.contentInset = UIEdgeInsets(top: -70, left: 0, bottom: 30, right: 0)

        genderPicker.delegate = self
        genderPicker.dataSource = self
   
    }
    

    
    var heightItem = 60
    var widthItem = Int(UIScreen.main.bounds.width)
    var minimumLineSpacingForSection = 5.0
    var minimumInteritemSpacingForSection = 0.0

    var flag = false
    
    func showUserInformation(){
        
        UIView.transition(with: (collectionView?.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: IndexPath(item: 0, section: 1)))!, duration: 0.3, options: .transitionFlipFromRight, animations: {
            self.minimumInteritemSpacingForSection = 0.0
            self.minimumLineSpacingForSection = 5.0
            self.heightItem = 60
            self.widthItem = Int(self.view.frame.width)
            self.flag = false
        }) { (finish) in
            self.collectionView?.reloadData()
        }
        
    }

    func showUserPhotos(){
        
        UIView.transition(with: (collectionView?.supplementaryView(forElementKind: UICollectionElementKindSectionHeader, at: IndexPath(item: 0, section: 1)))!, duration: 0.3, options: .transitionFlipFromLeft, animations: {
            self.heightItem = Int((self.view.frame.width / 3.0))-1
            self.widthItem = self.heightItem
            self.minimumInteritemSpacingForSection = 1.0
            self.minimumLineSpacingForSection = 1.0
            self.flag = true
        }) { (finish) in
            self.collectionView?.reloadData()
        }
        
    }
    
    func fetchUserPhotos(){

        let dbRef = Database.database().reference().child("user-images").child((user?.id)!)
        dbRef.observe(.childAdded, with: { (snapshot) in
            if let imageUrl = snapshot.value as? String {
                self.imageUrls.append(imageUrl)
                self.imageUrlsDictionary[snapshot.key] = imageUrl

            }

        }, withCancel: nil)
        
    }
    var indexPhotoDelete: Int?
    
    func handleShowPhoto(cell: PhotoCell){
        let indexTapped = collectionView?.indexPath(for: cell)
        indexPhotoDelete = indexTapped?.row
        
        performZoomForImageView(startingImageView: cell.imageView, showMoreButton: true)
    }
    
    @objc func handleAddPhoto(){
        addPhotoFlag = true
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        let actionGallery = UIAlertAction(title: "Open Gallery", style: .default) { (alert) in
            self.openGallery()
        }
        let actionCamera = UIAlertAction(title: "Take a picture", style: .default) { (alert) in
            self.openCamera()
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            self.addPhotoFlag = false
        }
        
        alert.addAction(actionGallery)
        alert.addAction(actionCamera)
        alert.addAction(actionCancel)
        self.present(alert,animated: true)
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
        btn.isHidden = true
        return btn
       
    }()

    
    @objc func handleMore(){
        
        let actionSheetAlert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if profileImageViewIsShowFlag {
            let actionChange = UIAlertAction(title: "Change Profile Image", style: .default) { (alert) in
                
                self.handleChangeAvatar()
            }
            actionSheetAlert.addAction(actionChange)
        }else{
            let actionDelete = UIAlertAction(title: "Delete This Photo", style: .destructive) { (alert) in
                
                self.handleDeletePhoto()
            }
            actionSheetAlert.addAction(actionDelete)
        }
        
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        actionSheetAlert.addAction(actionCancel)
        
        self.present(actionSheetAlert, animated: true, completion: nil)
   
       
    }
    
    func handleDeletePhoto(){
        
        if let index = indexPhotoDelete {
            let sv = UIViewController.displaySpinner(onView: view)
            
            let dbRef = Database.database().reference().child("user-images").child((user?.id)!)
            
            if let key = self.imageUrlsDictionary.someKey(forValue: self.imageUrls[index]){
                dbRef.child(key).removeValue(completionBlock: { (error, ref) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    print("Delete successfully")
                    self.imageUrls.remove(at: index)
                    self.imageUrlsDictionary.removeValue(forKey: key)
                    self.handleZoomOutTap()
                    
                    UIViewController.removeSpinner(spinner: sv)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                })
            }
            
        }
    }
    
    func handleChangeAvatar(){
        changeProfileImageFlag = true
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        let actionGallery = UIAlertAction(title: "Open Gallery", style: .default) { (alert) in
            self.openGallery()
        }
        let actionCamera = UIAlertAction(title: "Take a picture", style: .default) { (alert) in
            self.openCamera()
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            self.changeProfileImageFlag = false
        }
        
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
    
    var changeProfileImageFlag = false
    var changeBackgroundImageFlag = false
    var addPhotoFlag = false
    
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
                                    self.handleZoomOutTap()
                                    self.user?.profileImageUrl = imageUrl
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
            }else if addPhotoFlag {
                print("add photo")
                let sv = UIViewController.displaySpinner(onView: view)
                let imageName = NSUUID().uuidString
                let storageRef = Storage.storage().reference().child("user_images").child((user?.email)!).child(imageName+".jpg")
                if let data = UIImageJPEGRepresentation(selectedImage, 0.1){
                    storageRef.putData(data, metadata: nil, completion: { (metadata, error) in
                        
                        if error != nil{
                            print("Fail to upload image", error!)
                            return
                        }
                        
                        let userReference = Database.database().reference().child("user-images").child((self.user?.id)!).childByAutoId()
                        
                        if let imageUrl = metadata?.downloadURL()?.absoluteString{
                            userReference.setValue(imageUrl, withCompletionBlock: { (err, ref) in
                                if err != nil{
                                    print(err!)
                                    return
                                }

                                UIViewController.removeSpinner(spinner: sv)
                                
                                DispatchQueue.main.async {
                                    self.collectionView?.reloadData()
                                }
                            })
                        }
                        
                    })
                }
            }
            
            addPhotoFlag = false
            changeProfileImageFlag = false
            changeBackgroundImageFlag = false
            
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        changeProfileImageFlag = false
        changeBackgroundImageFlag = false
        addPhotoFlag = false
        dismiss(animated: true, completion: nil)
    }
    
    func performZoomForImageView(startingImageView: UIImageView, showMoreButton: Bool){
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
        if showMoreButton {
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
    
    @objc func handleZoomOutTap(){
        navigationController?.navigationBar.isHidden = false
        if let zoomOutImageView = zoomingImageView {
            zoomOutImageView.layer.cornerRadius = profileImageViewIsShowFlag ? 50 : 8
            zoomOutImageView.clipsToBounds = true
            self.btnMore.removeFromSuperview()
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackground?.alpha = 0
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.profileImageViewIsShowFlag = false
                self.startingImageView?.isHidden = false
            })
            
        }
    }
    
    var profileImageViewIsShowFlag = false
    
    func viewEditProfileImage(header: BackgroundImageHeader){
        profileImageViewIsShowFlag = true
        performZoomForImageView(startingImageView: header.profileImageView, showMoreButton: true)
        
    }
    
    func viewEditBackgroundImage(header: BackgroundImageHeader){

        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let actionViewImage = UIAlertAction(title: "View Background Image", style: .default) { (alert) in
            self.performZoomForImageView(startingImageView: header.backgroundImageView, showMoreButton: false)
        }
        alert.addAction(actionViewImage)
        
        if user?.id == Auth.auth().currentUser?.uid {
            let actionChangeImage = UIAlertAction(title: "Change Background Image", style: .default) { (alert) in
                self.handleChangeBackgroundImage()
            }
            alert.addAction(actionChangeImage)
        }
        
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        
        alert.addAction(actionCancel)
        self.present(alert,animated: true)
    }
    
    @objc func handleChangeBackgroundImage(){
        self.changeBackgroundImageFlag = true
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        let actionGallery = UIAlertAction(title: "Open Gallery", style: .default) { (alert) in
            self.openGallery()
        }
        let actionCamera = UIAlertAction(title: "Take a picture", style: .default) { (alert) in
            self.openCamera()
        }
        
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            self.changeBackgroundImageFlag = false
        }
        
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
    
    var genderTextField: UITextField?
    var genderPicker = UIPickerView()
    var dataGender = ["Male","Female"]
    
    
    
    func genderEdit(){

        let alert = UIAlertController(title: "Edit Gender", message: nil, preferredStyle: .alert)
        alert.addTextField { (tf) in
            self.genderTextField = tf
            if let gender = self.user?.gender {
                self.genderTextField?.text = gender
                if gender == self.dataGender[1]{
                    self.genderPicker.selectRow(1, inComponent: 0, animated: true)
                }
                
            }else{
                self.genderTextField?.text = self.dataGender[0]
            }
            self.genderTextField?.inputView = self.genderPicker
 
        }
        
        let actionOk = UIAlertAction(title: "Ok", style: .default) { (alertController) in
            let userReference = Database.database().reference().child("users").child((self.user?.id)!)
            userReference.updateChildValues(["gender": (self.genderTextField?.text)!], withCompletionBlock: { (err, ref) in
                if err != nil{
                    print(err!)
                    return
                }
                self.user?.gender = self.genderTextField?.text!

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
        case 3: genderEdit()
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
            
            if user?.id != Auth.auth().currentUser?.uid{
                cell.btnEdit.isHidden = true
            }else{
                cell.btnEdit.isHidden = false
            }
            
            switch indexPath.row {
                
            case 0:
                cell.label.text = "Email:"
                cell.imageView.image = UIImage(named: "ic_mail")
                cell.labelInfo.text = user?.email
                cell.btnEdit.isHidden = true
            case 1:
                cell.label.text = "Nick name:"
                cell.imageView.image = UIImage(named: "ic_nickname")

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
            cell.personalPageVC = self
            cell.imageView.loadImageUsingCacheWithUrlString(urlString: imageUrls[indexPath.row])
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
            return imageUrls.count
        }else{
            return 6
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.alpha = 0
        cell.layer.transform = CATransform3DMakeScale(0.5, 0.5, 0.5)
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            cell.alpha = 1
            cell.layer.transform = CATransform3DScale(CATransform3DIdentity, 1, 1, 1)
        })
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let section = indexPath.section
        
        switch section {
        case 0:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerBackGroundId, for: indexPath) as! BackgroundImageHeader
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
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: headerSecondId, for: indexPath) as! InformationAndPhotosHeader
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
extension PersionalPageViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataGender.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataGender[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        genderTextField?.text = dataGender[row]
    }
    
}

