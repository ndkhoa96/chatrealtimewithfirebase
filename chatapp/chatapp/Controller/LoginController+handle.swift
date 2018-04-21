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
    
    func handleRegister(){
        guard let email = emailTextField.text, let password = passwordTextField.text,
            let name = nameTextField.text
            else {
                print("Invalid form")
                return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil{
                print(error!)
                return
            }
            
            guard let uid = user?.uid
                else{
                    return
            }
            
            //succcess
            //let imageName = NSUUID().uuidString
            let storageRef = Storage.storage().reference().child("profile_images").child("\(email).jpg")
            
            if let uploadData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.1) {
                
                storageRef.putData(uploadData, metadata: nil, completion: { (metaData, error) in

                    if error != nil{
                        print(error!)
                        return
                    }
                    if let profileImageUrl = metaData?.downloadURL()?.absoluteString{
                        let values = ["name": name,"email": email, "profileImageUrl": profileImageUrl]
                        self.registerUserIntoDataBaseWithUID(uid: uid, values: values as [String : AnyObject])
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
            //self.messageController?.navigationItem.title = values["name"] as? String
            let user = User(values: values)

            self.messageController?.setupNavBarWithUser(user: user)
            
            self.dismiss(animated: true, completion: nil)
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
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
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
