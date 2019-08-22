//
//  BlurredTabBar.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 08. 22..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class BlurredTabBar: UITabBar {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let frost = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        frost.frame = CGRect(origin: bounds.origin, size: CGSize(width: bounds.size.width, height: bounds.size.height + 50))
        frost.autoresizingMask = .flexibleWidth
        insertSubview(frost, at: 0)
        
        self.backgroundColor = .clear
        self.backgroundImage = UIImage()
        self.shadowImage = UIImage()
    }
    
}
