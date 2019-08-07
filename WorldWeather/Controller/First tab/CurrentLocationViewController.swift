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
    
    let defaults = UserDefaults.standard
    let locationManager = CLLocationManager()
    var forecastWeatherDataForHours: [WeatherData]!
    var forecastWeatherDataForDays: [WeatherData]!
    let restManager = RestManager()
    
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
        weatherCollectionView.register(UINib(nibName: "ForecastCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ForecastCollectionViewCell")
        weatherCollectionView.backgroundColor = .clear
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUITemperatureUnit(_:)), name: NSNotification.Name("didChangeTemperatureUnit"), object: nil)
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
    
    func updateView(with weatherData: WeatherData) {
        currentLocationView.updateUI(weatherData.city,
                                     weatherData.temperature,
                                     weatherData.description,
                                     weatherData.pressure,
                                     weatherData.humidity,
                                     weatherData.wind,
                                     weatherData.cloudiness,
                                     weatherData.visibility)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ForecastSegue" {
            let destinationVC = segue.destination as! ForecastViewController
            destinationVC.forecastWeatherData = forecastWeatherDataForDays
        }
    }
    
    @objc func updateUITemperatureUnit(_ notification: Notification) {
        locationManager.startUpdatingLocation()
    }

}

extension CurrentLocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            let coordinates = ["lat": String(location.coordinate.latitude), "lon": String(location.coordinate.longitude)]
            
            restManager.getWeatherData(with: coordinates) { (weatherData) in
                DispatchQueue.main.async {
                    self.updateView(with: weatherData)
                }
            }
            
            restManager.getWeatherForecastData(with: coordinates) { (forHours, forDays) in
                self.forecastWeatherDataForHours = forHours
                self.forecastWeatherDataForDays = forDays
                DispatchQueue.main.async {
                    self.weatherCollectionView.reloadData()
                }
            }
        } else {
            // TODO: - alert
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // TODO: - alert
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // TODO: - alert
    }
    
}

extension CurrentLocationViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if forecastWeatherDataForHours == nil {
            return 0
        } else {
            return forecastWeatherDataForHours.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForecastCollectionViewCell", for: indexPath) as! ForecastCollectionViewCell
    
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let dateString = dateFormatter.string(from: forecastWeatherDataForHours[indexPath.row].date)
        let hour = Int(dateString.components(separatedBy: " ")[1].components(separatedBy: ":")[0])
        
        cell.hourLabel.text = "\(hour!)"
        cell.degreeLabel.text = "\(forecastWeatherDataForHours[indexPath.row].temperature)°"
        return cell
    }
    
    
}
