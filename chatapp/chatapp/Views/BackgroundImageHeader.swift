//
//  BackgroundImageHeader.swift
//  chatapp
//
//  Created by Khoa Nguyen on 7/26/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit

class BackgroundImageHeader : UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let lpg = UILongPressGestureRecognizer(target: self, action: #selector(handleBackgroundImageView))
        lpg.minimumPressDuration = 1
        backgroundImageView.addGestureRecognizer(lpg)
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAvatar)))
        setUpView()
        
    }
    
    var personalPageVC : PersionalPageViewController?
    
    @objc func handleBackgroundImageView(){
        personalPageVC?.viewEditBackgroundImage(header: self)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpView(){
        
        addSubview(backgroundImageView)
        backgroundImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        backgroundImageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        backgroundImageView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        backgroundImageView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        backgroundImageView.addSubview(profileImageView)
        profileImageView.leftAnchor.constraint(equalTo: backgroundImageView.leftAnchor, constant: 8).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -4).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        backgroundImageView.addSubview(nameLabel)
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.widthAnchor.constraint(equalToConstant: 300).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
    }
    
    var backgroundImageView : UIImageView = {
        let imV = UIImageView()
        imV.translatesAutoresizingMaskIntoConstraints = false
        imV.image = UIImage(named: "person_bg2")
        imV.isUserInteractionEnabled = true
        return imV
    }()
    
    var profileImageView : UIImageView = {
        let imV = UIImageView(image: UIImage(named: "test"))
        imV.translatesAutoresizingMaskIntoConstraints = false
        imV.contentMode = .scaleAspectFill
        imV.isUserInteractionEnabled = true
        imV.layer.cornerRadius = 50
        imV.layer.masksToBounds = true
        imV.layer.borderWidth = 1
        imV.layer.borderColor = Theme.shared.whiteColor.cgColor
        imV.isUserInteractionEnabled = true
        
        return imV
    }()
    
    
    var nameLabel : UILabel = {
        let label = UILabel()
        label.text = "Khoa Nguyen"
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = Theme.shared.whiteColor
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        
        
        return label
    }()
    
    @objc func handleAvatar() {
        personalPageVC?.viewEditProfileImage(header: self)
    }
}
