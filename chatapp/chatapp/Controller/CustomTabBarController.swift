//
//  CustomTabBarController.swift
//  chatapp
//
//  Created by Khoa Nguyen on 4/27/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let messagesController = MessagesController()
        let recentMessagesNavController = UINavigationController(rootViewController: messagesController)
        recentMessagesNavController.tabBarItem.image = UIImage(named: "ic_conversation")
        recentMessagesNavController.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -9, right: 0)
        
        let groupMessagesController = GroupMessagesController()
        let groupMessagesNavController = UINavigationController(rootViewController: groupMessagesController)
        groupMessagesNavController.tabBarItem.image = UIImage(named: "people")
        groupMessagesNavController.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -9, right: 0)
        
        viewControllers = [recentMessagesNavController,groupMessagesNavController]
    }

}
