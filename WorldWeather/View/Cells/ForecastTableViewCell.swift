//
//  ForecastTableViewCell.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 08. 01..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class ForecastTableViewCell: UITableViewCell {
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var hottestLabel: UILabel!
    @IBOutlet weak var coldestLabel: UILabel!

//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//        //self.backgroundColor = .clear
//    }
    
    func updateUIAccordingTo(backgroundPicture imageName: String, with icons: (white: String, black: String)) {
        let imageNames = ["sunny", "cloudy_moon", "fog", "night", "rainy", "thunderstorm"]
        
        self.backgroundImage.image = UIImage(named: imageName)
        
        if imageNames.contains(imageName) {
            dayLabel.textColor = .white
            hottestLabel.textColor = .white
            coldestLabel.textColor = .white
            weatherImageView.image = UIImage(named: icons.white)
        } else {
            dayLabel.textColor = .black
            hottestLabel.textColor = .black
            coldestLabel.textColor = .black
            weatherImageView.image = UIImage(named: icons.black)
        }
    }

}
