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
    
    override func awakeFromNib() {
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        
        getWeatherButton.backgroundColor = .clear
        getWeatherButton.layer.cornerRadius = 15
        getWeatherButton.layer.borderWidth = 1
        getWeatherButton.layer.borderColor = UIColor.white.cgColor
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard)))
    }
    
    @objc func dismissKeyboard() {
        self.endEditing(true)
    }

}
