//
//  ForecastDayData.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 08. 01..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import Foundation

class ForecastDayData {
    
    var weatherID = Int()
    let maxTemperature: Int
    let minTemperature: Int
    let day: String
    
    init(maxTemperature: Int, minTemperature: Int, day: String) {
        self.maxTemperature = maxTemperature
        self.minTemperature = minTemperature
        self.day = day
    }
    
    func getBackgroundPictureNameFromWeatherID(id: Int) -> String {
        
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
            return "sunny"
            
        case 801...802 :
            return "cloudy1"
            
        case 803...804 :
            return "cloudy2"
            
        default :
            return "background"
        }
    }
    
    func getIconNameFromWeatherID(id: Int) -> (white: String, black: String) {
        
        switch (id) {
        case 200...232 :
            return (white: "stormwhite", black: "stormblack")
            
        case 300...321, 500 :
            return (white: "drizzlewhite", black: "drizzleblack")
            
        case 501...531 :
            return (white: "rainwhite", black: "rainblack")
            
        case 600...622 :
            return (white: "snowwhite", black: "snowblack")
            
        case 800 :
            return (white: "sunnywhite", black: "sunnyblack")
            
        case 801...802 :
            return (white: "cloudywhite", black: "cloudyblack")
            
        case 803...804 :
            return (white: "cloudswhite", black: "cloudsblack")
            
        default :
            return (white: "xwhite", black: "xblack")
        }
    }
    
}
