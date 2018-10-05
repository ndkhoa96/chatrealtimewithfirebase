//
//  InformationAndPhotosHeader.swift
//  chatapp
//
//  Created by Khoa Nguyen on 7/26/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit

class InformationAndPhotosHeader : UICollectionReusableView {
    
    var personalPageVC : PersionalPageViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        setUpView()
    }
    
    func setUpView(){
        
        self.addSubview(btnInfo)
        btnInfo.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        btnInfo.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        btnInfo.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1/2).isActive = true
        btnInfo.heightAnchor.constraint(equalToConstant: self.frame.height - 16).isActive = true
        
        let separateView = UIView()
        separateView.translatesAutoresizingMaskIntoConstraints = false
        separateView.backgroundColor = Theme.shared.lightGrayColor
    
        
        self.addSubview(separateView)
        separateView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        separateView.leftAnchor.constraint(equalTo: btnInfo.rightAnchor).isActive = true
        separateView.widthAnchor.constraint(equalToConstant: 1).isActive = true
        separateView.heightAnchor.constraint(equalToConstant: self.frame.height - 16).isActive = true
        
        self.addSubview(btnPhotos)
        btnPhotos.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        btnPhotos.leftAnchor.constraint(equalTo: separateView.rightAnchor).isActive = true
        btnPhotos.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1/2).isActive = true
        btnPhotos.heightAnchor.constraint(equalToConstant: self.frame.height - 16).isActive = true
        
        let bottSeparateView = UIView()
        bottSeparateView.translatesAutoresizingMaskIntoConstraints = false
        bottSeparateView.backgroundColor = Theme.shared.lightGrayColor
        
        
        self.addSubview(bottSeparateView)
        bottSeparateView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        bottSeparateView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        bottSeparateView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        bottSeparateView.heightAnchor.constraint(equalToConstant: 5).isActive = true
    }
    
    let btnInfo : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Information", for: .normal)
        btn.setTitleColor(Theme.shared.secondaryColor, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.addTarget(self, action: #selector(handleInformation), for: .touchUpInside)
        
        return btn
    }()
    
    
    @objc func handleInformation(){
        personalPageVC?.showUserInformation()
        btnInfo.setTitleColor(Theme.shared.secondaryColor, for: .normal)
        btnPhotos.setTitleColor(Theme.shared.grayColor, for: .normal)
    }
    
    @objc func handlePhotos(){
        personalPageVC?.showUserPhotos()
        btnInfo.setTitleColor(Theme.shared.grayColor, for: .normal)
        btnPhotos.setTitleColor(Theme.shared.secondaryColor, for: .normal)
        
    }
    
    let btnPhotos : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("Photos", for: .normal)
        btn.setTitleColor(Theme.shared.grayColor, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.addTarget(self, action: #selector(handlePhotos), for: .touchUpInside)
        
        return btn
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

