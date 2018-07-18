//
//  InformationCell.swift
//  chatapp
//
//  Created by Khoa Nguyen on 7/12/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit

class InformationCell : UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        setUpView()
    }
    
    var personalViewController : PersionalPageViewController?
    
    func setUpView(){
        addSubview(imageView)
        imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        addSubview(label)
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 8).isActive = true
        label.widthAnchor.constraint(equalToConstant: 100).isActive = true
        label.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        addSubview(labelInfo)
        labelInfo.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        labelInfo.leftAnchor.constraint(equalTo: label.rightAnchor, constant: 8).isActive = true
        labelInfo.widthAnchor.constraint(equalToConstant: 200).isActive = true
        labelInfo.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        btnEdit.addTarget(self, action: #selector(handleEdit), for: .touchUpInside)
        addSubview(btnEdit)
        btnEdit.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        btnEdit.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        btnEdit.widthAnchor.constraint(equalToConstant: 20).isActive = true
        btnEdit.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    var imageView : UIImageView = {
        let imv = UIImageView()
        imv.translatesAutoresizingMaskIntoConstraints = false
        imv.image = UIImage(named: "camera")
        imv.contentMode = .scaleAspectFit
        
        return imv
    }()
    
    var label: UILabel  = {
        let label = UILabel()
        label.text = "Real name: "
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.underline()
        
        return label
    }()
    
    var labelInfo: UILabel  = {
        let labelInfo = UILabel()
        labelInfo.text = "Nguyen Dang Khoa"
        labelInfo.textColor = UIColor.black
        labelInfo.font = UIFont.systemFont(ofSize: 16)
        labelInfo.translatesAutoresizingMaskIntoConstraints = false
        
        return labelInfo
    }()
    
    var btnEdit : UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(UIImage(named: "ic_edit"), for: .normal)
        btn.contentMode = .scaleAspectFit
        
        return btn
    }()
    
    @objc func handleEdit(){
        personalViewController?.handleEditInfor(cell: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
