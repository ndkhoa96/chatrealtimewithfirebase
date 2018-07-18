//
//  Themes.swift
//  AloChat
//
//  Created by DINH TRIEU on 3/6/18.
//  Copyright © 2018 AloOpen. All rights reserved.
//

import UIKit

class Theme {
    class var shared: Theme {
        struct Static {
            static var instance = Theme()
        }
        return Static.instance
    }
    
    private init() {}
    
    //MARK: Color
    var primaryColor: UIColor {
        return UIColor(r: 12, g: 29, b: 53)
    }
    
    var secondaryColor: UIColor {
        //return UIColor(r: 28, g: 52, b: 84)
        return UIColor(r: 56, g: 45, b: 175)
    }
    
    var whiteColor: UIColor {
        return UIColor(r: 255, g: 255, b: 255)
    }
    
    var blueColor: UIColor{
        return UIColor(r: 25, g: 220, b: 255)
    }
    
    var lightGrayColor : UIColor {
        return UIColor(r: 240 , g: 240, b: 240)
    }
    
    var grayColor: UIColor{
        //return UIColor(r: 240 , g: 240, b: 240)
        return UIColor.lightGray
    }
    
    var blackColor: UIColor{
        return UIColor.black
    }
}
