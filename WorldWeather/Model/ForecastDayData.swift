//
//  ForecastDayData.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 08. 01..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import Foundation

class ForecastDayData {
    
    let maxTemperature: Int
    let minTemperature: Int
    let day: String
    
    init(maxTemperature: Int, minTemperature: Int, day: String) {
        self.maxTemperature = maxTemperature
        self.minTemperature = minTemperature
        self.day = day
    }
    
}
