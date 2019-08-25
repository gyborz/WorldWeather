//
//  LocationTableViewCell.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 08. 05..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit
import SwipeCellKit

class LocationTableViewCell: SwipeTableViewCell {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    // we update the background image, the text colors, and add the correct weather icon depending on the background image
    func updateUIAccordingTo(backgroundPicture imageName: String, with icons: (white: String, black: String)) {
        let imageNames = ["sunny", "cloudy_moon", "night", "rainy", "thunderstorm", "drizzle"]
        
        self.backgroundImage.image = UIImage(named: imageName)
        
        if imageNames.contains(imageName) {
            cityLabel.textColor = .white
            temperatureLabel.textColor = .white
            weatherImageView.image = UIImage(named: icons.white)
        } else {
            cityLabel.textColor = .black
            temperatureLabel.textColor = .black
            weatherImageView.image = UIImage(named: icons.black)
        }
    }
    
}
