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
        
        let groupsMessagesController = GroupsMessagesController()
        let groupsMessagesNavController = UINavigationController(rootViewController: groupsMessagesController)
        groupsMessagesNavController.tabBarItem.image = UIImage(named: "people")
        groupsMessagesNavController.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -9, right: 0)
        
        let friendsController = FriendsViewController()
        let friendsNavController = UINavigationController(rootViewController: friendsController)
        friendsNavController.tabBarItem.image = UIImage(named: "ic_friends")
        friendsNavController.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -9, right: 0)
        
        viewControllers = [recentMessagesNavController, groupsMessagesNavController, friendsNavController]
    }

}
