//
//  ForecastCollectionViewCell.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 07. 30..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class ForecastCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var hourLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var degreeLabel: UILabel!
    
    // we update the text colors and add the correct weather icon depending on the background image
    func updateUIAccordingTo(backgroundPicture imageName: String, with icons: (white: String, black: String)) {
        let imageNames = ["sunny", "cloudy_moon", "night", "rainy", "thunderstorm", "drizzle"]
        if imageNames.contains(imageName) {
            hourLabel.textColor = .white
            degreeLabel.textColor = .white
            weatherImageView.image = UIImage(named: icons.white)
        } else {
            hourLabel.textColor = .black
            degreeLabel.textColor = .black
            weatherImageView.image = UIImage(named: icons.black)
        }
    }
    
}
