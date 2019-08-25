//
//  AnimatedTabBarController.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 08. 25..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class AnimatedTabBarController: UITabBarController {
    
    private var bounceAnimation: CAKeyframeAnimation = {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.4, 0.9, 1.02, 1.0]
        bounceAnimation.duration = TimeInterval(0.3)
        bounceAnimation.calculationMode = CAAnimationCalculationMode.cubic
        return bounceAnimation
    }()
    
    // we find the index of the selected tab bar item, then find the corresponding view and get its image
    // the view's position is offset by 2 because of the inserted blur effect view (see BlurredTabBar.swift)
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let idx = tabBar.items?.firstIndex(of: item), tabBar.subviews.count > idx + 2, let imageView = tabBar.subviews[idx + 2].subviews.first as? UIImageView else {
            return
        }
        
        imageView.layer.add(bounceAnimation, forKey: nil)
    }
}
