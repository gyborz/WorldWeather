//
//  GetWeatherView.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 08. 04..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class GetWeatherView: UIView {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var cloudinessLabel: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundImage.layer.cornerRadius = 10
        
        closeButton.backgroundColor = .clear
        closeButton.layer.cornerRadius = 15
        closeButton.layer.borderWidth = 1
        closeButton.layer.borderColor = UIColor.red.cgColor
    }
    
    func updateUI(_ city: String, _ temperature: Int, _ description: String, _ pressure: Int, _ humidity: Int, _ wind: Double, _ cloudiness: Int, _ visibility: Int) {
        cityLabel.text = city
        temperatureLabel.text = "\(temperature)°"
        descriptionLabel.text = description.capitalizingFirstLetter()
        pressureLabel.text = "Pressure: \(pressure) hPa"
        humidityLabel.text = "Humidity: \(humidity)%"
        windLabel.text = "Wind: \(Int(wind * 3.6)) km/h"
        cloudinessLabel.text = "Cloudiness: \(cloudiness)%"
        visibilityLabel.text = "Visibility: \(visibility / 1000) km"
    }
    
    func updateBackgroundImage(with imageName: String) {
        let imageNames = ["sunny", "cloudy_moon", "night", "rainy", "thunderstorm"]
        
        self.backgroundImage.image = UIImage(named: imageName)
        
        if imageNames.contains(imageName) {
            cityLabel.textColor = .white
            temperatureLabel.textColor = .white
            descriptionLabel.textColor = .white
            pressureLabel.textColor = .white
            humidityLabel.textColor = .white
            windLabel.textColor = .white
            cloudinessLabel.textColor = .white
            visibilityLabel.textColor = .white
        } else if imageName == "background" {
            cityLabel.textColor = .black
            temperatureLabel.textColor = .black
            descriptionLabel.textColor = .black
            pressureLabel.textColor = .black
            humidityLabel.textColor = .black
            windLabel.textColor = .black
            cloudinessLabel.textColor = .black
            visibilityLabel.textColor = .black
        } else {
            cityLabel.textColor = .black
            temperatureLabel.textColor = .black
            descriptionLabel.textColor = .black
            pressureLabel.textColor = .black
            humidityLabel.textColor = .black
            windLabel.textColor = .black
            cloudinessLabel.textColor = .black
            visibilityLabel.textColor = .black
        }
    }

}
