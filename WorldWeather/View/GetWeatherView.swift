//
//  GetWeatherView.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 08. 04..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class GetWeatherView: UIView {

    @IBOutlet weak var handle: UIView!
    @IBOutlet weak var handleArea: UIView!
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var cloudinessLabel: UILabel!
    @IBOutlet weak var visibilityLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundImage.roundCorners([.topLeft, .topRight], radius: 30)
        handle.layer.cornerRadius = 2
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
        let imageNames = ["sunny", "cloudy_moon", "night", "rainy", "thunderstorm", "drizzle"]
        
        self.backgroundImage.image = UIImage(named: imageName)
        
        if imageNames.contains(imageName) {
            handle.backgroundColor = .white
            cityLabel.textColor = .white
            temperatureLabel.textColor = .white
            descriptionLabel.textColor = .white
            pressureLabel.textColor = .white
            humidityLabel.textColor = .white
            windLabel.textColor = .white
            cloudinessLabel.textColor = .white
            visibilityLabel.textColor = .white
        } else {
            handle.backgroundColor = .lightGray
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

extension UIView {
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
}
