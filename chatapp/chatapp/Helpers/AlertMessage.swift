//
//  AlertMessage.swift
//  chatapp
//
//  Created by Khoa Nguyen on 10/7/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit

class AlertMessage: NSObject {
    
    private override init() {
        
    }
    
    static let shared = AlertMessage()
    
    private lazy var alert : UIAlertController = {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.addAction(actionOk)
        return alert
    }()
    
    private var actionOk = UIAlertAction(title: "Ok", style: .default, handler: nil)
    
    func show(tilte: String?, message: String, from controller: UIViewController){
        alert.title = tilte
        alert.message = message
        
        controller.present(alert, animated: true, completion: nil)
    }
    
}
