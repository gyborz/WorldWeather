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
    case responseError
}

class RestManager {
    
    // MARK: - Constants
    
    private let defaults = UserDefaults.standard
    private let appId = "3656721177232952a61339c39bec961e"
    
    private let currentDate = Date()
    private let format = DateFormatter()
    
    
    // MARK: - URLSession Methods
    
    // we make a request to the openweathermap's api with our api key
    // in our case we use the api with coordinates or name (+ country code if given)
    // we check if there's any error or a response that's the api's fail response (the latter happens when we request by name)
    // if so, then we give back a failure as a result in the completionHandler with the correct error or response error enum case
    // if we get back the requested data we convert it into json and get all the necessary information what we need
    // we check the temperature unit, get the location's current time (according to it's timezone)
    // then we initialize the weatherData which we give back in the completionHandler as a success result
    
    func getWeatherData(with coordinates: [String: String], completionHandler: @escaping (Result<WeatherData,Error>) -> Void) {
        if let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(coordinates["lat"]!)&lon=\(coordinates["lon"]!)&appid=\(appId)") {
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data, let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode {
                    do {
                        let json = try JSON(data: data)
                        
                        let temperature = self.getTemperatureInCorrectUnit(from: json["main"]["temp"].double!)
                        
                        // we get the current time of the location
                        let seconds = json["timezone"].intValue
                        self.format.timeZone = TimeZone(secondsFromGMT: seconds)
                        self.format.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let date = self.format.string(from: self.currentDate)
                        
                        let weatherData = WeatherData(weatherId: json["weather"][0]["id"].intValue,
                                                      city: json["name"].stringValue + ", " + json["sys"]["country"].stringValue,
                                                      description: json["weather"][0]["description"].stringValue,
                                                      temperature: temperature,
                                                      pressure: json["main"]["pressure"].intValue,
                                                      humidity: json["main"]["humidity"].intValue,
                                                      visibility: json["visibility"].intValue,
                                                      wind: json["wind"]["speed"].double!,
                                                      cloudiness: json["clouds"]["all"].intValue,
                                                      date: date)
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
    
    func getWeatherData(with text: String, completionHandler: @escaping (Result<WeatherData,Error>) -> Void) {
        let urlString = trimmedString(from: text, isForecast: false)    /// mark: - supporting methods
        
        if let url = URL(string: urlString) {
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data, let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode {
                    do {
                        let json = try JSON(data: data)
                        
                        let temperature = self.getTemperatureInCorrectUnit(from: json["main"]["temp"].double!)
                        
                        // we get the current time of the location
                        let seconds = json["timezone"].intValue
                        self.format.timeZone = TimeZone(secondsFromGMT: seconds)
                        self.format.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        let date = self.format.string(from: self.currentDate)
                        
                        let weatherData = WeatherData(weatherId: json["weather"][0]["id"].intValue,
                                                      city: json["name"].stringValue + ", " + json["sys"]["country"].stringValue,
                                                      description: json["weather"][0]["description"].stringValue,
                                                      temperature: temperature,
                                                      pressure: json["main"]["pressure"].intValue,
                                                      humidity: json["main"]["humidity"].intValue,
                                                      visibility: json["visibility"].intValue,
                                                      wind: json["wind"]["speed"].double!,
                                                      cloudiness: json["clouds"]["all"].intValue,
                                                      date: date)
                        completionHandler(.success(weatherData))
                    } catch {
                        completionHandler(.failure(WeatherError.unknownError))
                    }
                }
                
                if (response as? HTTPURLResponse)?.statusCode == 404 {  /// searching with wrong city name can cause this response
                    completionHandler(.failure(WeatherError.responseError))
                }
                
                if error != nil {
                    completionHandler(.failure(WeatherError.requestFailed))
                }
            }.resume()
        } else {
            completionHandler(.failure(WeatherError.unknownError))
        }
    }
    
    func getWeatherForecastData(with coordinates: [String: String], completionHandler: @escaping (Result<(forHours: [WeatherData], forDays: [WeatherData]),Error>) -> Void) {
        if let url = URL(string: "http://api.openweathermap.org/data/2.5/forecast?lat=\(coordinates["lat"]!)&lon=\(coordinates["lon"]!)&appid=\(appId)") {
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data, let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode {
                    do {
                        let json = try JSON(data: data)
                        
                        let forecastData = self.saveForecastDataFromJson(json: json)    /// mark: - supporting methods
                        completionHandler(.success((forecastData.forHours, forecastData.forDays)))
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
    
    func getWeatherForecastData(with text: String, completionHandler: @escaping (Result<(forHours: [WeatherData], forDays: [WeatherData]),Error>) -> Void) {
        let urlString = trimmedString(from: text, isForecast: true)     /// mark: - supporting methods
        
        if let url = URL(string: urlString) {
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data, let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode {
                    do {
                        let json = try JSON(data: data)
                        
                        let forecastData = self.saveForecastDataFromJson(json: json)    /// mark: - supporting methods
                        completionHandler(.success((forecastData.forHours, forecastData.forDays)))
                    } catch {
                        completionHandler(.failure(WeatherError.unknownError))
                    }
                }
                
                if (response as? HTTPURLResponse)?.statusCode == 404 {  /// searching with wrong city name can cause this response
                    completionHandler(.failure(WeatherError.responseError))
                }
                
                if error != nil {
                    completionHandler(.failure(WeatherError.requestFailed))
                }
            }.resume()
        } else {
            completionHandler(.failure(WeatherError.unknownError))
        }
    }
    
    // MARK: - Supporting Methods
    
    // we get the json data which in this case contains 40 different items for 5 days worth of forecast
    // each of them containing weather information about the location every 3 hours
    // our goal is to get the first 24 hours of data (which appears in the collection views)
    // and the remaining weather data (which appears as the upcoming days in the table views) separated
    // then give back both of them together in a tuple as arrays
    private func saveForecastDataFromJson(json: JSON) -> (forHours: [WeatherData], forDays: [WeatherData]) {
        
        // first we get the current time adjusted to the location, then we adjust the forecast time to the timezone too
        // in the first loop we get the weather of the next 24 hours
        // simultaneously we check for the beginning of the next day (which occurs somewhere in the first 8 items)
        // we compare the day of the two dates, if they differ, we store the day's index
        var dayIndex = 0    /// this variable indicates from which list item begins the next day's weather information
        var forecastWeatherDataForHours = [WeatherData]()
        
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let seconds = json["city"]["timezone"].intValue
        format.timeZone = TimeZone(secondsFromGMT: seconds)
        let today = self.format.string(from: self.currentDate)  /// get the current time of the location
        let dayOfCurrentDate = Int(today.components(separatedBy: " ")[0].components(separatedBy: "-")[2])
        
        for index in 0...8 {
            format.timeZone = .current
            let forecastTimeString = json["list"][index]["dt_txt"].stringValue  /// get the forecast time from the API in string
            let forecastDate = format.date(from: forecastTimeString)            /// turn the forecast string into date (it's in UTC)
            format.timeZone = TimeZone(secondsFromGMT: seconds)                 /// set the timezone
            let date = format.string(from: forecastDate!)                       /// get the adjusted forecast time in string
            let dayOfDate = Int(date.components(separatedBy: " ")[0].components(separatedBy: "-")[2])
            
            let temperature = getTemperatureInCorrectUnit(from: json["list"][index]["main"]["temp"].double!)
            
            let newWeatherData = WeatherData(weatherId: json["list"][index]["weather"][0]["id"].intValue,
                                             city: String(), description: String(),
                                             temperature: temperature,
                                             pressure: Int(), humidity: Int(), visibility: Int(), wind: Double(), cloudiness: Int(),
                                             date: date)
            forecastWeatherDataForHours.append(newWeatherData)
            
            if dayOfCurrentDate! != dayOfDate! && dayIndex == 0 {
                dayIndex = index
            }
        }
        
        // in the second loop we start from the next day's index (from previous loop)
        // we adjust the time again (see previous loop) and save all the forecast data which are for the next few days
        // the days are gonna be processed in the ForecastViewC's/GetWeatherViewC's loadDays() method
        var forecastWeatherDataForDays = [WeatherData]()
        
        for index in dayIndex...json["list"].count - 1 {
            format.timeZone = .current
            let forecastTimeString = json["list"][index]["dt_txt"].stringValue
            let forecastDate = format.date(from: forecastTimeString)
            format.timeZone = TimeZone(secondsFromGMT: seconds)
            let date = format.string(from: forecastDate!)
            
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
    
    // we check the temperatureUnit's value in the userdefaults and give back the temperature's value accordingly
    private func getTemperatureInCorrectUnit(from kelvin: Double) -> Int {
        var temperature = 0
        if defaults.integer(forKey: "temperatureUnit") == 0 {
            temperature = Int(kelvin - 273.15)
        } else {
            temperature = Int((kelvin - 273.15) * 9 / 5 + 32)     /// Fahrenheit
        }
        
        return temperature
    }
    
    // we prepare the text the function got when it was called to be usable for a request in the api
    // what that means is we replace the whitespaces with %20 and if there's any comma
    // then the user probably typed in the country code too in the textfield, so we get that too
    // the isForecast Bool value tells us if the url needs to be a forecast or just a simple weather request
    private func trimmedString(from text: String, isForecast: Bool) -> String {
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
