//
//  CustomTabBarController.swift
//  chatapp
//
//  Created by Khoa Nguyen on 4/27/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    let userMessagesController = UserMessagesController()
    let groupsMessagesController = GroupsMessagesController()
    let friendsController = FriendsViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let recentMessagesNavController = UINavigationController(rootViewController: userMessagesController)
        recentMessagesNavController.tabBarItem.image = UIImage(named: ASSETS.ICON.MESSAGE)
        recentMessagesNavController.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -9, right: 0)
        
        let groupsMessagesNavController = UINavigationController(rootViewController: groupsMessagesController)
        groupsMessagesNavController.tabBarItem.image = UIImage(named: ASSETS.ICON.FAMILY)
        groupsMessagesNavController.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -9, right: 0)
        
        let friendsNavController = UINavigationController(rootViewController: friendsController)
        friendsNavController.tabBarItem.image = UIImage(named: ASSETS.ICON.CONTACT)
        friendsNavController.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: -9, right: 0)
        
        viewControllers = [friendsNavController, recentMessagesNavController, groupsMessagesNavController]
    }

}
