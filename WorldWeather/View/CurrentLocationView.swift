//
//  CurrentLocationView.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 07. 30..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class CurrentLocationView: UIView {

    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var cloudinessLabel: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    @IBOutlet weak var collectionViewIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableViewIndicator: UIActivityIndicatorView!
    
    // we update the view's labels with the correct data (in correct form)
    func updateLabels(_ city: String, _ temperature: Int, _ description: String, _ pressure: Int, _ humidity: Int, _ wind: Double, _ cloudiness: Int, _ visibility: Int) {
        cityLabel.text = String(city.split(separator: ",")[0])
        temperatureLabel.text = "\(temperature)°"
        descriptionLabel.text = description.capitalizingFirstLetter()   /// achieved with String extension
        pressureLabel.text = "Pressure: \(pressure) hPa"
        humidityLabel.text = "Humidity: \(humidity)%"
        windLabel.text = "Wind: \(Int(wind * 3.6)) km/h"
        cloudinessLabel.text = "Cloudiness: \(cloudiness)%"
        visibilityLabel.text = "Visibility: \(visibility / 1000) km"
    }
    
    // we update the text colors depending on the background image
    func updateUI(accordingTo backgroundImage: String) {
        let imageNames = ["sunny", "cloudy_moon", "night", "rainy", "thunderstorm", "drizzle"]
        
        if imageNames.contains(backgroundImage) {
            cityLabel.textColor = .white
            temperatureLabel.textColor = .white
            descriptionLabel.textColor = .white
            pressureLabel.textColor = .white
            humidityLabel.textColor = .white
            windLabel.textColor = .white
            cloudinessLabel.textColor = .white
            visibilityLabel.textColor = .white
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

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
