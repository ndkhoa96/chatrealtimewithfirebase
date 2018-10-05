//
//  Dimension.swift
//  AloChat
//
//  Created by DINH TRIEU on 3/6/18.
//  Copyright © 2018 AloOpen. All rights reserved.
//

import UIKit

class Dimension {

    class var shared: Dimension {
        struct Static {
            static var instance = Dimension()
        }
        return Static.instance
    }
    
    var widthScreen: CGFloat = 1.0
    var heightScreen: CGFloat = 1.0
    var widthScale: CGFloat = 1.0
    var heightScale: CGFloat = 1.0
    var screenBounds: CGRect = .zero
    
    private init() {
        self.widthScale = UIScreen.main.bounds.width / 375
        self.heightScale = UIScreen.main.bounds.height / 667
        self.widthScreen = UIScreen.main.bounds.width
        self.heightScreen = UIScreen.main.bounds.height
        self.screenBounds = UIScreen.main.bounds
    }
    
    //MARK: Font size
    var headlineFontSize: CGFloat {
        return 24 * self.heightScale
    }
    
    var titleFontSize: CGFloat {
        return 20 * self.heightScale
    }
    
    var bodyFontSize: CGFloat {
        return 16 * self.heightScale
    }
    
    var captionFontSize: CGFloat {
        return 14 * self.heightScale
    }
    
    var smallCaptionFontSize: CGFloat {
        return 13 * self.heightScale
    }
    
    var defaultButtonFontSize: CGFloat {
        return 14 * self.heightScale
    }
    
    //MARK: Spacing
    var smallHorizontalMargin: CGFloat {
        return 4 * self.widthScale
    }
    
    var smallVerticalMargin: CGFloat {
        return 4 * self.heightScale
    }
    
    var mediumHorizontalMargin: CGFloat {
        return 8 * self.widthScale
    }
    
    var mediumVerticalMargin: CGFloat {
        return 8 * self.heightScale
    }
    
    var normalHorizontalMargin: CGFloat {
        return 16 * self.widthScale
    }
    
    var normalVerticalMargin: CGFloat {
        return 16 * self.heightScale
    }
    
    var largeHorizontalMargin: CGFloat {
        return 24 * self.widthScale
    }
    
    var largeVerticalMargin: CGFloat {
        return 24 * self.heightScale
    }
    
    var largeHorizontalMargin_32: CGFloat {
        return 32 * self.widthScale
    }
    
    var largeVerticalMargin_32: CGFloat {
        return 32 * self.heightScale
    }
    
    var largeVerticalMargin_38: CGFloat {
        return 42 * self.heightScale
    }
    
    var largeHorizontalMargin_42: CGFloat {
        return 42 * self.widthScale
    }
    
    var largeVerticalMargin_42: CGFloat {
        return 42 * self.widthScale
    }
    
    var largeHorizontalMargin_56: CGFloat {
        return 56 * self.widthScale
    }
    
    var largeVerticalMargin_56: CGFloat {
        return 56 * self.heightScale
    }
    
    var largeHorizontalMargin_60: CGFloat {
        return 60 * self.widthScale
    }
    
    var largeVerticalMargin_60: CGFloat {
        return 60 * self.heightScale
    }
    
    var largeHorizontalMargin_90: CGFloat {
        return 90 * self.widthScale
    }
    
    var largeVerticalMargin_90: CGFloat {
        return 90 * self.heightScale
    }
    
    var largeHorizontalMargin_120: CGFloat {
        return 120 * self.widthScale
    }
    
    var largeVerticalMargin_120: CGFloat {
        return 120 * self.heightScale
    }
    
}
