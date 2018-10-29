//
//  FriendCell.swift
//  chatapp
//
//  Created by Khoa Nguyen on 7/19/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit
import Firebase

class FriendCell:UITableViewCell {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64,
                                  y: (textLabel?.frame.origin.y)!,
                                  width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        detailTextLabel?.frame = CGRect(x: 64,
                                        y: (detailTextLabel?.frame.origin.y)!,
                                        width: (self.frame.width)-150,
                                        height: (detailTextLabel?.frame.height)!)
    }
    
    let profileImageView: UIImageView = {
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.layer.cornerRadius = 24
        profileImageView.layer.masksToBounds = true
        profileImageView.contentMode = .scaleAspectFill
        return profileImageView
    }()
    
    let btnChat : UIButton = {
        let btnChat = UIButton()
        btnChat.setImage(UIImage(named: ASSETS.ICON.CHAT), for: .normal)
        btnChat.translatesAutoresizingMaskIntoConstraints = false
        return btnChat
    }()
    
    let btnCall : UIButton = {
        let btnCall = UIButton()
        btnCall.setImage(UIImage(named: ASSETS.ICON.PHONE), for: .normal)
        btnCall.translatesAutoresizingMaskIntoConstraints = false
        return btnCall
    }()
    
    var friendsVC : FriendsViewController?
    
    @objc func handleChat() {
        friendsVC?.handleTapToUserChatLog(cell: self)
    }
    
    @objc func handleCall() {
        friendsVC?.callUser(cell: self)
    }
    
    var baseTableController: BaseTableViewController?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        // add constrains x,y,w,h
        addSubview(profileImageView)
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        addSubview(btnChat)
        btnChat.addTarget(self, action: #selector(handleChat), for: .touchUpInside)
        btnChat.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        btnChat.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        btnChat.widthAnchor.constraint(equalToConstant: 35).isActive = true
        btnChat.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        addSubview(btnCall)
        btnCall.addTarget(self, action: #selector(handleCall), for: .touchUpInside)
        btnCall.rightAnchor.constraint(equalTo: btnChat.leftAnchor, constant: -16).isActive = true
        btnCall.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        btnCall.widthAnchor.constraint(equalToConstant: 30).isActive = true
        btnCall.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("inint has not been implemented")
    }
}
