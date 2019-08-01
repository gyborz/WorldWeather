//
//  FirstViewController.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 07. 30..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit
import SwiftyJSON
import CoreLocation

class CurrentLocationViewController: UIViewController {
    
    let locationManager = CLLocationManager()
    let appId = "3656721177232952a61339c39bec961e"
    var forecastWeatherDataFor24Hours: [WeatherData]!
    var forecastWeatherDataForDays: [WeatherData]!
    var weatherData: WeatherData!
    
    @IBOutlet weak var currentLocationView: CurrentLocationView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var weatherCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        weatherCollectionView.delegate = self
        weatherCollectionView.dataSource = self
        weatherCollectionView.backgroundColor = .clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if UIScreen.main.bounds.height >= 812 {
            scrollView.isScrollEnabled = false
        } else if UIScreen.main.bounds.height == 736 {
            scrollView.isScrollEnabled = true
            scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height+50)
        } else if UIScreen.main.bounds.height == 667 {
            scrollView.isScrollEnabled = true
            scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height+125)
        } else if UIScreen.main.bounds.height == 568 {
            scrollView.isScrollEnabled = true
            scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height+225)
        }
    }
    
    func getWeatherData(with coordinates: [String: String]) {
        if let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(coordinates["lat"]!)&lon=\(coordinates["lon"]!)&appid=\(appId)") {
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    do {
                        let json = try JSON(data: data)
                        DispatchQueue.main.async {
                            self.updateWeatherData(with: json)
                        }
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
    
    func getWeatherForecastData(with coordinates: [String: String]) {
        if let url = URL(string: "http://api.openweathermap.org/data/2.5/forecast?lat=\(coordinates["lat"]!)&lon=\(coordinates["lon"]!)&appid=\(appId)") {
            
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let data = data {
                    do {
                        let json = try JSON(data: data)
                        print(json)
                        print(url)
                        self.saveForecastDataFromJson(json: json)
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
    
    func updateWeatherData(with json: JSON) {
        weatherData = WeatherData(weatherId: json["weather"][0]["id"].intValue,
                                  city: json["name"].stringValue,
                                  description: json["weather"][0]["description"].stringValue,
                                  temperature: Int(json["main"]["temp"].double! - 273.15),
                                  pressure: json["main"]["pressure"].intValue,
                                  humidity: json["main"]["humidity"].intValue,
                                  visibility: json["visibility"].intValue,
                                  wind: json["wind"]["speed"].double!,
                                  cloudiness: json["clouds"]["all"].intValue,
                                  date: Date())
        
        currentLocationView.updateUI(weatherData.city,
                                     weatherData.temperature,
                                     weatherData.description,
                                     weatherData.pressure,
                                     weatherData.humidity,
                                     weatherData.wind,
                                     weatherData.cloudiness,
                                     weatherData.visibility)
    }
    
    func saveForecastDataFromJson(json: JSON) {
        var dayIndex = 0    /// this variable indicates from which list item begins the next day's weather information
        let today = Date()
        let calendar = Calendar.current
        
        forecastWeatherDataFor24Hours = [WeatherData]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        for index in 0...8 {
            let dateString = json["list"][index]["dt_txt"].stringValue
            let date = dateFormatter.date(from: dateString)!
            
            let newWeatherData = WeatherData(weatherId: json["list"][index]["weather"][0]["id"].intValue,
                                             city: String(), description: String(),
                                             temperature: Int(json["list"][index]["main"]["temp"].double! - 273.15),
                                             pressure: Int(), humidity: Int(), visibility: Int(), wind: Double(), cloudiness: Int(),
                                             date: date)
            forecastWeatherDataFor24Hours.append(newWeatherData)
            
            if calendar.component(.day, from: today) < calendar.component(.day, from: date) {
                dayIndex = index
            }
        }
        DispatchQueue.main.async {
            self.weatherCollectionView.reloadData()
        }
        
        forecastWeatherDataForDays = [WeatherData]()
        for index in dayIndex...json["list"].count - 1 {
            let dateString = json["list"][index]["dt_txt"].stringValue
            let date = dateFormatter.date(from: dateString)!
            
            let newWeatherData = WeatherData(weatherId: json["list"][index]["weather"][0]["id"].intValue,
                                             city: String(), description: String(),
                                             temperature: Int(json["list"][index]["main"]["temp"].double! - 273.15),
                                             pressure: Int(), humidity: Int(), visibility: Int(), wind: Double(), cloudiness: Int(),
                                             date: date)
            forecastWeatherDataForDays.append(newWeatherData)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ForecastSegue" {
            let destinationVC = segue.destination as! ForecastViewController
            destinationVC.forecastWeatherData = forecastWeatherDataForDays
        }
    }

}

extension CurrentLocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            let coordinates = ["lat": String(location.coordinate.latitude), "lon": String(location.coordinate.longitude)]
            getWeatherData(with: coordinates)
            getWeatherForecastData(with: coordinates)
        } else {
            // TODO: - alert
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // TODO: - alert
    }
    
}

extension CurrentLocationViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if forecastWeatherDataFor24Hours == nil {
            return 0
        } else {
            return forecastWeatherDataFor24Hours.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForecastViewCell", for: indexPath) as? ForecastCollectionViewCell
    
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let dateString = dateFormatter.string(from: forecastWeatherDataFor24Hours[indexPath.row].date)
        let hour = Int(dateString.components(separatedBy: " ")[1].components(separatedBy: ":")[0])
        
        cell?.hourLabel.text = "\(hour!)"
        cell?.degreeLabel.text = "\(forecastWeatherDataFor24Hours[indexPath.row].temperature)°"
        return cell!
    }
    
    
}
