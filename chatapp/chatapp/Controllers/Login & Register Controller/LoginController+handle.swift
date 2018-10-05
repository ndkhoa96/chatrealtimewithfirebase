//
//  LoginController+handle.swift
//  chatapp
//
//  Created by Khoa Nguyen on 3/17/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit
import Firebase

//MARK: - HANDLE FUNCTION
extension LoginAndRegisterController {
    
    @objc func handleLoginRegister(){
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0{
            handleLogin()
        }else{
            handleRegister()
        }
    }
    
    @objc func handleLoginRegisterChange(){
        
        var anim: UIView.AnimationOptions
        var image: UIImage!
        
        if self.loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            anim = UIView.AnimationOptions.transitionFlipFromRight
            image = UIImage(named: ASSETS.IMAGE.LOGO)
            profileImageView.isUserInteractionEnabled = false
            nameSeparatorView.isHidden = true
        }else{
            anim = UIView.AnimationOptions.transitionFlipFromLeft
            profileImageView.isUserInteractionEnabled = true
            image = UIImage(named: ASSETS.ICON.USER)
            nameSeparatorView.isHidden = false
        }
        
        UIView.transition(with: profileImageView, duration: ANIMATION.FLIP_SHAKE, options: anim, animations: {
            self.profileImageView.image = image
        }, completion: nil)
        
        UIView.transition(with: self.loginRegisterButton, duration: ANIMATION.FLIP_SHAKE, options: anim, animations: {
            let title = self.loginRegisterSegmentedControl.titleForSegment(at: self.loginRegisterSegmentedControl.selectedSegmentIndex)
            self.loginRegisterButton.setTitle(title, for: .normal)
        }, completion: nil)
        
        UIView.transition(with: inputsContainerView, duration: ANIMATION.FLIP_SHAKE, options: anim, animations: {
            
            self.inputContainerViewHeightAnchor?.constant = self.loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? Constants.height2Part : Constants.height3Part
            
            //change name textfield height
            self.nameTextfieldHeightAnchor?.isActive = false
            self.nameTextfieldHeightAnchor = self.nameTextField.heightAnchor.constraint(equalTo: self.inputsContainerView.heightAnchor, multiplier: self.loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : RATIO.THREE_PART)
            self.nameTextfieldHeightAnchor?.isActive = true
            
            //change email textfield height
            self.emailTextfieldHeightAnchor?.isActive = false
            self.emailTextfieldHeightAnchor = self.emailTextField.heightAnchor.constraint(equalTo: self.inputsContainerView.heightAnchor, multiplier: self.loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? RATIO.TWO_PART : RATIO.THREE_PART)
            self.emailTextfieldHeightAnchor?.isActive = true
            
            //change password textfield height
            self.passwordTextfieldHeightAnchor?.isActive = false
            self.passwordTextfieldHeightAnchor = self.passwordTextField.heightAnchor.constraint(equalTo: self.inputsContainerView.heightAnchor, multiplier: self.loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? RATIO.TWO_PART : RATIO.THREE_PART)
            self.passwordTextfieldHeightAnchor?.isActive = true
            
        }, completion: nil)
        
    }
    
    private func handleLogin(){
        view.endEditing(true)
        let sv = UIViewController.displaySpinner(onView: view)
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty , let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !password.isEmpty
            else {
                UIViewController.removeSpinner(spinner: sv)
                inputsContainerView.shake(count: ANIMATION.SHAKE_COUNT, for: ANIMATION.SHAKE_TIME, withTranslation: ANIMATION.SHAKE_TRANSLATION)
                return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil{
                UIViewController.removeSpinner(spinner: sv)
                self.inputsContainerView.shake(count: ANIMATION.SHAKE_COUNT, for: ANIMATION.SHAKE_TIME, withTranslation: ANIMATION.SHAKE_TRANSLATION)
                return
            }
            UIViewController.removeSpinner(spinner: sv)
            
            let customTabBarController = CustomTabBarController()
            
            self.present(customTabBarController, animated: true, completion: nil)
        }
    }
    
    
    private func showMessageError(error: Error){
        if let errCode = AuthErrorCode(rawValue: error._code) {
            switch errCode {
            case .networkError:
                self.alert.message = Constants.connectionErrorMessage
            case .invalidEmail:
                self.alert.message = Constants.invalidEmailMessage
            case .emailAlreadyInUse:
                self.alert.message = Constants.existEmailMessage
            case .weakPassword:
                self.alert.message = Constants.invalidPasswordMessage
            default:
                self.alert.message = error as? String
            }
            self.present(self.alert, animated: true, completion: nil)
        }
    }
    
    private func handleRegister(){
        view.endEditing(true)
        let sv = UIViewController.displaySpinner(onView: view)
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty,  let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !password.isEmpty,
            let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty
            else {
                UIViewController.removeSpinner(spinner: sv)
                inputsContainerView.shake(count: ANIMATION.SHAKE_COUNT, for: ANIMATION.SHAKE_TIME, withTranslation: ANIMATION.SHAKE_TRANSLATION)
                return
        }
        
        AuthProvider.shared.reference.createUser(withEmail: email, password: password) { (user, error) in
            if error != nil{
                UIViewController.removeSpinner(spinner: sv)
                self.showMessageError(error: error!)
                return
            }
            
            guard let uid = user?.uid
                else{
                    return
            }
            
            //succcess
            self.uploadProfileImageToDatabase(image: self.profileImageView.image!, uid: uid, name: name, email: email, spinner: sv)
            
        }
    }
    
    private func uploadProfileImageToDatabase(image: UIImage, uid: String, name: String, email: String, spinner: UIView){
        
        let imageName = NSUUID().uuidString
        
        if let uploadData = image.jpegData(compressionQuality: COMPRESSION.IMAGE) {
            
            StorageProvider.shared.profile_images.child("\(imageName)\(Constants.typeImage)").putData(uploadData, metadata: nil, completion: { (metaData1, error1) in
                
                if error1 != nil{
                    print(error1!)
                    return
                }
                
                let bgImage = UIImage(named: ASSETS.ICON.SCENERY)
                
                if let uploadBackgroundImage = bgImage!.jpegData(compressionQuality: COMPRESSION.IMAGE) {
                    
                    StorageProvider.shared.background_images.child("\(imageName)\(Constants.typeImage)")
                        .putData(uploadBackgroundImage, metadata: nil, completion: { (metaData2, error2) in
                            
                            if error2 != nil{
                                print(error2!)
                                return
                            }
                            if let profileImageUrl = metaData1?.downloadURL()?.absoluteString{
                                if let backgroundImageUrl = metaData2?.downloadURL()?.absoluteString{
                                    let values = [KEY_DATA.USER.NAME: name,KEY_DATA.USER.EMAIL: email, KEY_DATA.USER.PROFILE_IMAGE_URL: profileImageUrl, KEY_DATA.USER.BACKGROUND_IMAGE_URL: backgroundImageUrl]
                                    self.registerUserIntoDataBaseWithUID(uid: uid, values: values as [String : AnyObject])
                                    UIViewController.removeSpinner(spinner: spinner)
                                }
                            }
                        })
                }
            })
        }
    }
    
    private func registerUserIntoDataBaseWithUID(uid: String, values: [String: AnyObject]){
        let ref = Database.database().reference()
        let userReference = ref.child(KEY_DATA.USER.ROOT).child(uid)
        
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil{
                print(err!)
                return
            }
            let customTabBarController = CustomTabBarController()
            
            self.present(customTabBarController, animated: true, completion: nil)
            
        })
    }
    
    @objc func handleSelectProfileImageView(){
        GallaryPicker.shared.open(.gallery, from: self)
    }
}
//MARK: - IMPLEMENT IMAGEPICKERCONTROLLER
extension LoginAndRegisterController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
 
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[KEY_INFO.IMAGE.EDIT] as? UIImage{
            selectedImageFromPicker = editedImage
        }
    
        if let selectedImage = selectedImageFromPicker{
            profileImageView.image = selectedImage
            
        }
        
        dismiss(animated: true, completion: nil)
    }

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}
