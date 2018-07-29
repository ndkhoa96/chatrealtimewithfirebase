//
//  LoginController+handle.swift
//  chatapp
//
//  Created by Khoa Nguyen on 3/17/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit
import Firebase

extension LoginController:UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    
    func handleLogin(){
        view.endEditing(true)
        let sv = UIViewController.displaySpinner(onView: view)
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty , let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !password.isEmpty
            else {
                UIViewController.removeSpinner(spinner: sv)
                inputsContainerView.shake(count: 3, for: timeShakeAnim, withTranslation: 3)
                return
        }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil{
                UIViewController.removeSpinner(spinner: sv)
                self.inputsContainerView.shake(count: 3, for: self.timeShakeAnim, withTranslation: 3)
                return
            }
            UIViewController.removeSpinner(spinner: sv)
            
            let customTabBarController = CustomTabBarController()
            
            self.present(customTabBarController, animated: true, completion: nil)
        }
    }

    
    func handleRegister(){
        view.endEditing(true)
        let sv = UIViewController.displaySpinner(onView: view)
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty,  let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !password.isEmpty,
            let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !name.isEmpty
            else {
                UIViewController.removeSpinner(spinner: sv)
                inputsContainerView.shake(count: 3, for: timeShakeAnim, withTranslation: 3)
                return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil{
                UIViewController.removeSpinner(spinner: sv)
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    switch errCode {
                    case .networkError:
                        self.alert.message = "Please check your connection!"
                        self.present(self.alert, animated: true, completion: nil)
                    case .invalidEmail:
                        self.alert.message = "Invalid email address!"
                        self.present(self.alert, animated: true, completion: nil)
                    case .emailAlreadyInUse:
                        self.alert.message = "Email is already have registered!"
                        self.present(self.alert, animated: true, completion: nil)
                    case .weakPassword:
                        self.alert.message = "Password should be at least 6 characters!"
                        self.present(self.alert, animated: true, completion: nil)
                    default:
                        self.alert.message = error! as? String
                        self.present(self.alert, animated: true, completion: nil)
                    }
                }
                return
            }
            
            guard let uid = user?.uid
                else{
                    return
            }
            
            //succcess
            //let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference()
            
            if let uploadData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.1) {
                
                storageRef.child("profile_images").child("\(email).jpg").putData(uploadData, metadata: nil, completion: { (metaData1, error1) in

                    if error1 != nil{
                        print(error1!)
                        return
                    }
                    
                    let bgImage = UIImage(named: "user_background")
                    
                    if let uploadBackgroundImage = UIImageJPEGRepresentation(bgImage!, 0.1) {
                        
                        storageRef.child("background_images").child("\(email).jpg").putData(uploadBackgroundImage, metadata: nil, completion: { (metaData2, error2) in
                            
                            if error2 != nil{
                                print(error2!)
                                return
                            }
                            if let profileImageUrl = metaData1?.downloadURL()?.absoluteString{
                                if let backgroundImageUrl = metaData2?.downloadURL()?.absoluteString{
                                    let values = ["name": name,"email": email, "profileImageUrl": profileImageUrl, "backgroundImageUrl": backgroundImageUrl]
                                    self.registerUserIntoDataBaseWithUID(uid: uid, values: values as [String : AnyObject])
                                    UIViewController.removeSpinner(spinner: sv)
                                }
                            }
                            
                        })
                        
                    }
                    
                })
            }
            
        }
    }
    
    private func registerUserIntoDataBaseWithUID(uid: String, values: [String: AnyObject]){
        let ref = Database.database().reference()
        let userReference = ref.child("users").child(uid)

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
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }//else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
         //   selectedImageFromPicker = originalImage
        //}
    
        if let selectedImage = selectedImageFromPicker{
            profileImageView.image = selectedImage
            
        }
        
        dismiss(animated: true, completion: nil)
    }

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        nameTextField.resignFirstResponder()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
