//
//  PhotoCell.swift
//  chatapp
//
//  Created by Khoa Nguyen on 7/12/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit

class PhotoCell : UICollectionViewCell {
    
    var personalPageVC : PersionalPageViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleCellPick)))
        self.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
    }
    
    var imageView : UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.gray
//        imageView.layer.cornerRadius = 8
//        imageView.layer.masksToBounds = true
        
        return imageView
    }()
    
    @objc func handleCellPick(){
        personalPageVC?.handleShowPhoto(cell: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



