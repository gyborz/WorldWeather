//
//  SearchLocationView.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 08. 03..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class SearchLocationView: UIView {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var getWeatherButton: UIButton!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableViewIndicator: UIActivityIndicatorView!
    
    // we set the segmented control's colors, get weather button's color and add a tapgesture for dismissing the keyboard
    override func awakeFromNib() {
        super.awakeFromNib()
        
        getWeatherButton.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        getWeatherButton.layer.cornerRadius = 15
        getWeatherButton.layer.borderWidth = 1
        getWeatherButton.layer.borderColor = UIColor.white.cgColor
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        self.endEditing(true)
    }

}
