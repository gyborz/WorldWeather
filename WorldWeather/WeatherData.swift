//
//  WeatherData.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 07. 31..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import Foundation

class WeatherData {
    
    let weatherId: Int
    let city: String
    let description: String
    let temperature: Int
    let pressure: Int
    let humidity: Int
    let visibility: Int
    let wind: Double
    let cloudiness: Int
    
    init(weatherId: Int, city: String, description: String, temperature: Int, pressure: Int, humidity: Int, visibility: Int, wind: Double, cloudiness: Int) {
        self.weatherId = weatherId
        self.city = city
        self.description = description
        self.temperature = temperature
        self.pressure = pressure
        self.humidity = humidity
        self.visibility = visibility
        self.wind = wind
        self.cloudiness = cloudiness
    }
    
}
