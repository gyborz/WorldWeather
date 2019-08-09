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
    let date: Date
    
    init(weatherId: Int, city: String, description: String, temperature: Int, pressure: Int, humidity: Int, visibility: Int, wind: Double, cloudiness: Int, date: Date) {
        self.weatherId = weatherId
        self.city = city
        self.description = description
        self.temperature = temperature
        self.pressure = pressure
        self.humidity = humidity
        self.visibility = visibility
        self.wind = wind
        self.cloudiness = cloudiness
        self.date = date
    }
    
    func getPictureNameFromWeatherID(id: Int) -> String {
        let hour = Int(Calendar.current.component(.hour, from: Date()))
        
        switch (id) {
        case 200...232 :
            return "thunderstorm"
            
        case 300...321 :
            return "drizzle"
            
        case 500...531 :
            return "rainy"
            
        case 600...622 :
            return "snow"
            
        case 701...771 :
            return "fog"
            
        case 800 :
            if 5 < hour && hour < 19 {
                return "sunny"
            } else {
                return "night"
            }
            
        case 801...802 :
            if 5 < hour && hour < 19 {
                return "cloudy1"
            } else {
                return "night"
            }
            
        case 803...804 :
            if 5 < hour && hour < 19 {
                return "cloudy2"
            } else {
                return "cloudy_moon"
            }
            
        default :
            return "background"
        }
    }
    
}
