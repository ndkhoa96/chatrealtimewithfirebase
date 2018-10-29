//
//  AuthProvider.swift
//  chatapp
//
//  Created by Khoa Nguyen on 9/27/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import Foundation
import FirebaseAuth

class AuthProvider{

    //MARK: - SHARE INSTANCE
    static let shared = AuthProvider()

    //MARK: - INIT
    private init(){
        
    }
    
    //MARK: - PROPERTIES
    var isLoggedIn: Bool {
        if Auth.auth().currentUser != nil {
            return true
        }
        return false
    }
    
    var currentUserID: String? {
        return Auth.auth().currentUser?.uid ?? nil
    }

    //MARK: - METHOD LOGOUT
    func logOut() -> Bool {
        if Auth.auth().currentUser != nil {
            do{
                try Auth.auth().signOut()
                return true
            } catch let logoutError{
                print(logoutError)
                return false
            }
        }
        return true
    }
    
    
    //MARK: - METHOD LOGIN
    func loginWith(email: String, password: String, completion: @escaping (_ error: Error?) -> ()) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error!)
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    
    //MARK: - METHOD CREATE USER
    func createUserWith(email: String, password: String, name: String, profileImage: UIImage, backgroundImage: UIImage, completion: @escaping (_ error: Error?) -> ()) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil{
                print(error!)
                completion(error)
                return
            }
            //succcess
            if let uid = user?.uid {
                self.uploadDataToDatabase(uid: uid, email: email, name: name, profileImage: profileImage, backgroundImage: backgroundImage, completion: { (error) in
                    if error != nil {
                        print(error?.localizedDescription as Any)
                        completion(error)
                        return
                    }
                    completion(nil)
                })
            }
        }
    }
    
    private func uploadDataToDatabase(uid: String, email: String, name: String, profileImage: UIImage, backgroundImage: UIImage, completion: @escaping (_ error: Error?) -> ()) {
        uploadProfileImageToDatabase(with: profileImage) { (profileImageUrl, error) in
            if error != nil {
                completion(error!)
                return
            }
            //succcess
            self.uploadBackgroundImageToDatabase(with: backgroundImage, completion: { (backgroundImageUrl, error) in
                if error != nil {
                    completion(error!)
                    return
                }
                //succcess
                let values = [KEY_DATA.USER.NAME: name, KEY_DATA.USER.EMAIL: email, KEY_DATA.USER.PROFILE_IMAGE_URL: profileImageUrl!, KEY_DATA.USER.BACKGROUND_IMAGE_URL: backgroundImageUrl!]
                self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject], completion: { (error) in
                    if error != nil {
                        completion(error)
                        return
                    }
                    //succcess
                    completion(nil)
                })
            })
        }
    }
    
    private func uploadProfileImageToDatabase(with image: UIImage, completion: @escaping (_ imageUrl: String?, _ error: Error?) -> ()) {
        let imageName = NSUUID().uuidString
        
        if let uploadData = image.jpegData(compressionQuality: CONSTANT.IMAGE.COMPRESSION) {
            StorageProvider.shared.profileImagesReference.child("\(imageName)\(CONSTANT.IMAGE.TYPE)").putData(uploadData, metadata: nil, completion: { (metaData, error) in
                if error != nil{
                    completion(nil,error)
                    return
                }
                //succcess
                if let profileImageUrl = metaData?.downloadURL()?.absoluteString{
                    completion(profileImageUrl,nil)
                }
            })
        }
    }
    
    private func uploadBackgroundImageToDatabase(with image: UIImage, completion: @escaping (_ imageUrl: String?, _ error: Error?) -> ()) {
        let imageName = NSUUID().uuidString
        
        if let uploadData = image.jpegData(compressionQuality: CONSTANT.IMAGE.COMPRESSION) {
            StorageProvider.shared.backgroundImagesReference.child("\(imageName)\(CONSTANT.IMAGE.TYPE)").putData(uploadData, metadata: nil, completion: { (metaData, error) in
                if error != nil{
                    completion(nil,error)
                    return
                }
                //succcess
                if let backgroundImageUrl = metaData?.downloadURL()?.absoluteString{
                    completion(backgroundImageUrl,nil)
              
                }
            })
        }
    }
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject], completion: @escaping (_ error: Error?) -> ()) {
        let userReference = DBProvider.shared.usersReference.child(uid)
        
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil{
                completion(err)
                return
            }
            //succcess
            completion(nil)
        })
    }
}

