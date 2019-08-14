//
//  Networking.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 08. 04..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import Foundation
import SwiftyJSON

enum WeatherError: Swift.Error {
    case requestFailed
    case unknownError
}

class RestManager {
    
    let defaults = UserDefaults.standard
    let appId = "3656721177232952a61339c39bec961e"
    
    func getWeatherData(with coordinates: [String: String], completionHandler: @escaping (Result<WeatherData,Error>) -> Void) {
        if let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(coordinates["lat"]!)&lon=\(coordinates["lon"]!)&appid=\(appId)") {
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data, let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode {
                    do {
                        let json = try JSON(data: data)
                        
                        let temperature = self.getTemperatureInCorrectUnit(from: json["main"]["temp"].double!)
                        
                        let weatherData = WeatherData(weatherId: json["weather"][0]["id"].intValue,
                                                      city: json["name"].stringValue + ", " + json["sys"]["country"].stringValue,
                                                      description: json["weather"][0]["description"].stringValue,
                                                      temperature: temperature,
                                                      pressure: json["main"]["pressure"].intValue,
                                                      humidity: json["main"]["humidity"].intValue,
                                                      visibility: json["visibility"].intValue,
                                                      wind: json["wind"]["speed"].double!,
                                                      cloudiness: json["clouds"]["all"].intValue,
                                                      date: Date())
                        completionHandler(.success(weatherData))
                    } catch {
                        completionHandler(.failure(WeatherError.unknownError))
                    }
                }
                
                if error != nil {
                    completionHandler(.failure(WeatherError.requestFailed))
                }
            }.resume()
        } else {
            completionHandler(.failure(WeatherError.unknownError))
        }
    }
    
    func getWeatherData(with text: String, completionHandler: @escaping (_ weatherData: WeatherData) -> Void) {
        let urlString = trimmedString(from: text, isForecast: false)
        
        if let url = URL(string: urlString) {
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    do {
                        let json = try JSON(data: data)
                        
                        let temperature = self.getTemperatureInCorrectUnit(from: json["main"]["temp"].double!)
                        
                        let weatherData = WeatherData(weatherId: json["weather"][0]["id"].intValue,
                                                      city: json["name"].stringValue + ", " + json["sys"]["country"].stringValue,
                                                      description: json["weather"][0]["description"].stringValue,
                                                      temperature: temperature,
                                                      pressure: json["main"]["pressure"].intValue,
                                                      humidity: json["main"]["humidity"].intValue,
                                                      visibility: json["visibility"].intValue,
                                                      wind: json["wind"]["speed"].double!,
                                                      cloudiness: json["clouds"]["all"].intValue,
                                                      date: Date())
                        completionHandler(weatherData)
                    } catch let error {
                        print(error)
                    }
                }
                
                if let error = error {
                    print(error)
                    // TODO: - alert
                }
                }.resume()
            
        }
        
    }
    
    func getWeatherForecastData(with coordinates: [String: String], completionHandler: @escaping (_ forecastWeatherDataFor24Hours: [WeatherData], _ forecastWeatherDataForDays: [WeatherData]) -> Void) {
        if let url = URL(string: "http://api.openweathermap.org/data/2.5/forecast?lat=\(coordinates["lat"]!)&lon=\(coordinates["lon"]!)&appid=\(appId)") {
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    do {
                        let json = try JSON(data: data)
                        
                        let forecastData = self.saveForecastDataFromJson(json: json)
                        completionHandler(forecastData.forHours, forecastData.forDays)
                    } catch let error {
                        print(error)
                    }
                }
                
                if let error = error {
                    print(error)
                    // TODO: - alert
                }
                }.resume()
            
        }
    }
    
    func getWeatherForecastData(with text: String, completionHandler: @escaping (_ forecastWeatherDataFor24Hours: [WeatherData], _ forecastWeatherDataForDays: [WeatherData]) -> Void) {
        let urlString = trimmedString(from: text, isForecast: true)
        
        if let url = URL(string: urlString) {
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    do {
                        let json = try JSON(data: data)
                        
                        let forecastData = self.saveForecastDataFromJson(json: json)
                        completionHandler(forecastData.forHours, forecastData.forDays)
                    } catch let error {
                        print(error)
                    }
                }
                
                if let error = error {
                    print(error)
                    // TODO: - alert
                }
                }.resume()
            
        }
    }
    
    func saveForecastDataFromJson(json: JSON) -> (forHours: [WeatherData], forDays: [WeatherData]) {
        var dayIndex = 0    /// this variable indicates from which list item begins the next day's weather information
        let today = Date()
        let calendar = Calendar.current
        
        var forecastWeatherDataForHours = [WeatherData]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        for index in 0...8 {
            let dateString = json["list"][index]["dt_txt"].stringValue
            let date = dateFormatter.date(from: dateString)!
            let temperature = getTemperatureInCorrectUnit(from: json["list"][index]["main"]["temp"].double!)
            
            let newWeatherData = WeatherData(weatherId: json["list"][index]["weather"][0]["id"].intValue,
                                             city: String(), description: String(),
                                             temperature: temperature,
                                             pressure: Int(), humidity: Int(), visibility: Int(), wind: Double(), cloudiness: Int(),
                                             date: date)
            forecastWeatherDataForHours.append(newWeatherData)
            
            if calendar.component(.day, from: today) < calendar.component(.day, from: date) && dayIndex == 0 {
                // important: the date variable is always showing in UTC time, but the value itself is still the parsed one from the json file
                // example: if the 'date' variable in the equation shows: 2019-08-02 22:00:00 UTC,
                // the value itself is parsed from json so in reality it's 2019-08-03 00:00:00 the next day !!!
                // same equation happens at the ForecastViewController's loadDays() method !!
                dayIndex = index
            }
        }
        
        var forecastWeatherDataForDays = [WeatherData]()
        for index in dayIndex...json["list"].count - 1 {
            let dateString = json["list"][index]["dt_txt"].stringValue
            let date = dateFormatter.date(from: dateString)!
            let temperature = getTemperatureInCorrectUnit(from: json["list"][index]["main"]["temp"].double!)
            
            let newWeatherData = WeatherData(weatherId: json["list"][index]["weather"][0]["id"].intValue,
                                             city: String(), description: String(),
                                             temperature: temperature,
                                             pressure: Int(), humidity: Int(), visibility: Int(), wind: Double(), cloudiness: Int(),
                                             date: date)
            forecastWeatherDataForDays.append(newWeatherData)
        }
        
        return (forecastWeatherDataForHours, forecastWeatherDataForDays)
    }
    
    func getTemperatureInCorrectUnit(from kelvin: Double) -> Int {
        var temperature = 0
        if defaults.integer(forKey: "temperatureUnit") == 0 {
            temperature = Int(kelvin - 273.15)
        } else {
            temperature = Int((kelvin - 273.15) * 9 / 5 + 32)     /// Fahrenheit
        }
        
        return temperature
    }
    
    func trimmedString(from text: String, isForecast: Bool) -> String {
        var urlString: String
        if isForecast {
            if text.split(separator: ",").count == 2 {
                let cityWithWhitespaces = String(text.split(separator: ",")[0])
                let city = cityWithWhitespaces.replacingOccurrences(of: " ", with: "%20")
                let countryWithWhitespaces = String(text.split(separator: ",")[1])
                let country = countryWithWhitespaces.replacingOccurrences(of: " ", with: "%20")
                
                urlString = "http://api.openweathermap.org/data/2.5/forecast?q=\(city),\(country)&appid=\(appId)"
            } else {
                let cityWithWhiteSpaces = String(text.split(separator: ",")[0])
                let city = cityWithWhiteSpaces.replacingOccurrences(of: " ", with: "%20")
                
                urlString = "http://api.openweathermap.org/data/2.5/forecast?q=\(city)&appid=\(appId)"
            }
        } else {
            if text.split(separator: ",").count == 2 {
                let cityWithWhitespaces = String(text.split(separator: ",")[0])
                let city = cityWithWhitespaces.replacingOccurrences(of: " ", with: "%20")
                let countryWithWhitespaces = String(text.split(separator: ",")[1])
                let country = countryWithWhitespaces.replacingOccurrences(of: " ", with: "%20")
                
                urlString = "http://api.openweathermap.org/data/2.5/weather?q=\(city),\(country)&appid=\(appId)"
            } else {
                let cityWithWhiteSpaces = String(text.split(separator: ",")[0])
                let city = cityWithWhiteSpaces.replacingOccurrences(of: " ", with: "%20")
                
                urlString = "http://api.openweathermap.org/data/2.5/weather?q=\(city)&appid=\(appId)"
            }
        }
        
        return urlString
    }
    
}
