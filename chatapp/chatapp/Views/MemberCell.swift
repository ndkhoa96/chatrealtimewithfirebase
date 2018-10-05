//
//  MemberCell.swift
//  chatapp
//
//  Created by Khoa Nguyen on 6/22/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//
import UIKit

class MemberCell:UITableViewCell{
    
    var managerMembers : ManagerMemberController?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: (textLabel?.frame.origin.y)! - 2, width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        detailTextLabel?.frame = CGRect(x: 64, y: (detailTextLabel?.frame.origin.y)! + 2, width: (self.frame.width)-150, height: (detailTextLabel?.frame.height)!)
        
    }
    
    let profileImageView :UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var btnAddMember: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Add", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitleColor(Theme.shared.primaryColor, for: .normal)
        btn.layer.borderColor = Theme.shared.primaryColor.cgColor
        btn.layer.cornerRadius = 10
        btn.clipsToBounds = true
        btn.layer.borderWidth = 1
        btn.setBackgroundColor(color: UIColor.darkGray, forState: UIControl.State.highlighted)
        
        return btn
    }()
    
    var btnRemoveMember: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Remove", for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        btn.setTitleColor(Theme.shared.primaryColor, for: .normal)
        btn.layer.borderColor = Theme.shared.primaryColor.cgColor
        btn.layer.cornerRadius = 10
        btn.clipsToBounds = true
        btn.layer.borderWidth = 1
        btn.setBackgroundColor(color: UIColor.darkGray, forState: UIControl.State.highlighted)
   
        return btn
    }()
    
    @objc func handleRemoveMember(){
        managerMembers?.removeMemberFromGroup(cell: self)
    }
    
    @objc func handleAddMember(){
        managerMembers?.addMemberToGroup(cell: self)
    }
    
    func membersActive(){
        btnAddMember.isHidden = true
        btnRemoveMember.isHidden = false
    }
    
    func friendsActive(){
        btnAddMember.isHidden = false
        btnRemoveMember.isHidden = true
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        
        
        // add constrains x,y,w,h
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        addSubview(btnAddMember)
        btnAddMember.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        btnAddMember.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        btnAddMember.widthAnchor.constraint(equalToConstant: 70).isActive = true
        btnAddMember.heightAnchor.constraint(equalToConstant: 30).isActive = true
        btnAddMember.isHidden = true
        btnAddMember.addTarget(self, action: #selector(handleAddMember), for: .touchUpInside)
        
        addSubview(btnRemoveMember)
        btnRemoveMember.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        btnRemoveMember.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        btnRemoveMember.widthAnchor.constraint(equalToConstant: 70).isActive = true
        btnRemoveMember.heightAnchor.constraint(equalToConstant: 30).isActive = true
        btnRemoveMember.addTarget(self, action: #selector(handleRemoveMember), for: .touchUpInside)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("inint has not been implemented")
    }
}
