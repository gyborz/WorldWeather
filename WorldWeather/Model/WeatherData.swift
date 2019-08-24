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
    let date: String
    
    init(weatherId: Int, city: String, description: String, temperature: Int, pressure: Int, humidity: Int, visibility: Int, wind: Double, cloudiness: Int, date: String) {
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
    
    func getBackgroundPictureNameFromWeatherID(id: Int) -> String {
        let hour = Int(date.components(separatedBy: " ")[1].components(separatedBy: ":")[0])!
        
        switch (id) {
        case 200...232 :
            return "thunderstorm"
            
        case 300...321, 500 :
            if 5 < hour && hour < 19 {
                return "drizzle"
            } else {
                return "rainy"
            }
            
        case 501...531 :
            return "rainy"
            
        case 600...622 :
            return "snow"
            
        case 701...771 :
            if 5 < hour && hour < 19 {
                return "fog"
            } else {
                return "cloudy_moon"
            }
            
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
                return "cloudy_moon"
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
    
    func getIconNameFromWeatherID(id: Int) -> (white: String, black: String) {
        let hour = Int(date.components(separatedBy: " ")[1].components(separatedBy: ":")[0])!
        
        switch (id) {
        case 200...232 :
            return (white: "stormwhite", black: "stormblack")

        case 300...321, 500 :
            return (white: "drizzlewhite", black: "drizzleblack")
            
        case 501...531 :
            return (white: "rainwhite", black: "rainblack")
            
        case 600...622 :
            return (white: "snowwhite", black: "snowblack")
            
        case 701...771 :
            if 5 < hour && hour < 19 {
                return (white: "fogwhite2", black: "fogblack2")
            } else {
                return (white: "fogwhite", black: "fogblack")
            }
            
        case 800 :
            if 5 < hour && hour < 19 {
                return (white: "sunnywhite", black: "sunnyblack")
            } else {
                return (white: "moonwhite", black: "moonblack")
            }
            
        case 801...802 :
            if 5 < hour && hour < 19 {
                return (white: "cloudywhite", black: "cloudyblack")
            } else {
                return (white: "cloudynightwhite", black: "cloudynightblack")
            }
            
        case 803...804 :
            if 5 < hour && hour < 19 {
                return (white: "cloudswhite", black: "cloudsblack")
            } else {
                return (white: "cloudynightwhite", black: "cloudynightblack")
            }
            
        default :
            return (white: "xwhite", black: "xblack")
        }
    }
    
}
