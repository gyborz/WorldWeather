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
        forecastButton.layer.borderColor = UIColor.white.cgColor
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
    
    @IBAction func forecastButtonTapped(_ sender: UIButton) {
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
