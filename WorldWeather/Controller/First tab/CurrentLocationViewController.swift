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
import Network

class CurrentLocationViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    let locationManager = CLLocationManager()
    var forecastWeatherDataForHours: [WeatherData]!
    var forecastWeatherDataForDays: [WeatherData]!
    let restManager = RestManager()
    var imageName = String()
    let monitor = NWPathMonitor()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let imageNames = ["sunny", "cloudy_moon", "night", "rainy", "thunderstorm"]
        if imageNames.contains(imageName) {
            return .lightContent
        } else {
            return .default
        }
    }
    
    @IBOutlet weak var currentLocationView: CurrentLocationView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var weatherCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNetworkMonitor()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)
        
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
    
    func setupNetworkMonitor() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.setupLocationManager()
                self.defaults.set(true, forKey: "isConnected")
            } else {
                let alert = UIAlertController(title: "Network Error", message: "Check your network connection", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                self.defaults.set(false, forKey: "isConnected")
            }
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
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
        imageName = weatherData.getBackgroundPictureNameFromWeatherID(id: weatherData.weatherId)
        currentLocationView.updateBackgroundImage(with: imageName)
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ForecastSegue" {
            let destinationVC = segue.destination as! ForecastViewController
            destinationVC.forecastWeatherData = forecastWeatherDataForDays
            destinationVC.imageName = imageName
        }
    }
    
    @objc func updateUITemperatureUnit(_ notification: Notification) {
        locationManager.startUpdatingLocation()
    }
    
    func setupLocationManager() {
        /// check if location services are enabled on the device
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            checkLocationAuthorization()
        } else {
            // TODO: - alert
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .denied:
            // TODO: - alert showing how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // TODO: - alert for restriction problem
            break
        case .authorizedAlways:
            /// won't happen
            break
        @unknown default:
            // TODO: - special alert
            break
        }
    }

}

extension CurrentLocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        /// check if the latitude and longitude are valid
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            let coordinates = ["lat": String(location.coordinate.latitude), "lon": String(location.coordinate.longitude)]
            
            restManager.getWeatherData(with: coordinates) { [weak self] (result) in /// using weak on self to avoid retain cycle (updateView(:))
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let weatherData):
                        self.updateView(with: weatherData)
                    case .failure(let error):
                        if error as! WeatherError == WeatherError.requestFailed {
                            let alert = UIAlertController(title: "Network Error", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        } else {
                            let alert = UIAlertController(title: "Unknown Error", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
            
            restManager.getWeatherForecastData(with: coordinates) { [weak self] (result) in /// using weak on self to avoid retain cycle (forecast..ForHours and ..ForDays arrays)
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let forecastData):
                        self.forecastWeatherDataForHours = forecastData.forHours
                        self.forecastWeatherDataForDays = forecastData.forDays
                        self.weatherCollectionView.reloadData()
                    case .failure(let error):
                        if error as! WeatherError == WeatherError.requestFailed {
                            let alert = UIAlertController(title: "Network Error", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        } else {
                            let alert = UIAlertController(title: "Unknown Error", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }
                    }
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
        checkLocationAuthorization()
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
        
        let weatherItem = forecastWeatherDataForHours[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let dateString = dateFormatter.string(from: weatherItem.date)
        let hour = Int(dateString.components(separatedBy: " ")[1].components(separatedBy: ":")[0])
        
        cell.hourLabel.text = "\(hour!)"
        cell.degreeLabel.text = "\(weatherItem.temperature)°"
        
        let icons = weatherItem.getIconNameFromWeatherID(id: weatherItem.weatherId)
        cell.updateUIAccordingTo(backgroundPicture: imageName, with: icons)
        
        return cell
    }
    
}
