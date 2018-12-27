//
//  CollectionViewCell.swift
//  chatapp
//
//  Created by Khoa Nguyen on 10/29/18.
//  Copyright © 2018 KhoaNguyen. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    public static var identifier: String {
        return String(describing: self)
    }
    
    var controller: UIViewController? {
        didSet{
            if let view = controller?.view {
                self.addSubview(view)
                view.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
                view.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
                view.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
                view.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

