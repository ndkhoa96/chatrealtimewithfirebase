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
    
    class var shared: AuthProvider {
        struct Static {
            static var instance = AuthProvider()
        }
        return Static.instance
    }
    
    private init(){
        
    }
    
    var reference: Auth{
        return Auth.auth()
    }
    
    var isLoggedIn: Bool{
        if Auth.auth().currentUser != nil{
            return true
        }
        return false
    }
    
    var userID: String{
        return Auth.auth().currentUser?.uid ?? ""
    }

    func logOut()->Bool{
        if Auth.auth().currentUser != nil{
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
    
    
    

}

