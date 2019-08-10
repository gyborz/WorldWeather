//
//  CurrentLocationView.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 07. 30..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class CurrentLocationView: UIView {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var cloudinessLabel: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var forecastButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        forecastButton.backgroundColor = .clear
        forecastButton.layer.cornerRadius = 15
        forecastButton.layer.borderWidth = 1
    }
    
    func updateUI(_ city: String, _ temperature: Int, _ description: String, _ pressure: Int, _ humidity: Int, _ wind: Double, _ cloudiness: Int, _ visibility: Int) {
        cityLabel.text = String(city.split(separator: ",")[0])
        temperatureLabel.text = "\(temperature)°"
        descriptionLabel.text = description.capitalizingFirstLetter()
        pressureLabel.text = "Pressure: \(pressure) hPa"
        humidityLabel.text = "Humidity: \(humidity)%"
        windLabel.text = "Wind: \(Int(wind * 3.6)) km/h"
        cloudinessLabel.text = "Cloudiness: \(cloudiness)%"
        visibilityLabel.text = "Visibility: \(visibility / 1000) km"
    }
    
    func updateBackgroundImage(with imageName: String) {
        let imageNames = ["sunny", "cloudy_moon", "background", "night", "rainy", "thunderstorm"]
        
        UIView.transition(with: self,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: { self.backgroundImage.image = UIImage(named: imageName) },
                          completion: nil)
        
        if imageNames.contains(imageName) {
            cityLabel.textColor = .white
            temperatureLabel.textColor = .white
            descriptionLabel.textColor = .white
            pressureLabel.textColor = .white
            humidityLabel.textColor = .white
            windLabel.textColor = .white
            cloudinessLabel.textColor = .white
            visibilityLabel.textColor = .white
            forecastButton.setTitleColor(.white, for: .normal)
            forecastButton.layer.borderColor = UIColor.white.cgColor
        } else if imageName == "fog" {
            cityLabel.textColor = .black
            temperatureLabel.textColor = .black
            descriptionLabel.textColor = .black
            pressureLabel.textColor = .black
            humidityLabel.textColor = .black
            windLabel.textColor = .black
            cloudinessLabel.textColor = .black
            visibilityLabel.textColor = .black
            forecastButton.setTitleColor(.white, for: .normal)
            forecastButton.layer.borderColor = UIColor.white.cgColor
        } else {
            cityLabel.textColor = .black
            temperatureLabel.textColor = .black
            descriptionLabel.textColor = .black
            pressureLabel.textColor = .black
            humidityLabel.textColor = .black
            windLabel.textColor = .black
            cloudinessLabel.textColor = .black
            visibilityLabel.textColor = .black
            forecastButton.setTitleColor(.black, for: .normal)
            forecastButton.layer.borderColor = UIColor.black.cgColor
        }
    }

}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
