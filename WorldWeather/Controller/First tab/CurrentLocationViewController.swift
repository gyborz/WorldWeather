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
    
    // MARK: - Constants, variables, properties
    
    let defaults = UserDefaults.standard
    let locationManager = CLLocationManager()
    var forecastWeatherDataForHours = [WeatherData]()
    var forecastWeatherDataForDays = [WeatherData]()
    let restManager = RestManager()
    var imageName = String()
    let monitor = NWPathMonitor()
    var daysData = [ForecastDayData]()
    
    // we set the status bar color according to the background image
    override var preferredStatusBarStyle: UIStatusBarStyle {
        let imageNames = ["sunny", "cloudy_moon", "night", "rainy", "thunderstorm", "drizzle"]
        if imageNames.contains(imageName) {
            return .lightContent
        } else {
            return .default
        }
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var currentLocationView: CurrentLocationView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var weatherCollectionView: UICollectionView!
    @IBOutlet weak var forecastTableView: UITableView!
    
    // MARK: - View Handling
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        setupNetworkMonitor()       /// mark: - network monitor
        
        // we set up an observer so whenever the user changes the temperature unit on the second tab, the first tab's information updates too
        NotificationCenter.default.addObserver(self, selector: #selector(updateUITemperatureUnit(_:)), name: NSNotification.Name("didChangeTemperatureUnit"), object: nil)
    }
    
    // every time the view appears, we position the content size according to the device's bounds
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if UIScreen.main.bounds.height == 896 {
            scrollView.isScrollEnabled = false
        } else if UIScreen.main.bounds.height == 812 {
            scrollView.isScrollEnabled = true
            scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height+85)
        } else if UIScreen.main.bounds.height == 736 {
            scrollView.isScrollEnabled = true
            scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height+130)
        } else if UIScreen.main.bounds.height == 667 {
            scrollView.isScrollEnabled = true
            scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height+200)
        } else if UIScreen.main.bounds.height == 568 {
            scrollView.isScrollEnabled = true
            scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height+300)
        }
    }
    
    // we set the UI to the last state it was in, if it's the first load up, then we set it to a basic 'sunny' UI
    // we set up the collectionView and the tableView as needed
    func setupUI() {
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: defaults.string(forKey: "backgroundImage") ?? "sunny")!)
        currentLocationView.updateUI(accordingTo: defaults.string(forKey: "backgroundImage") ?? "sunny")
        self.setNeedsStatusBarAppearanceUpdate()
        
        weatherCollectionView.delegate = self
        weatherCollectionView.dataSource = self
        weatherCollectionView.register(UINib(nibName: "ForecastCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ForecastCollectionViewCell")
        weatherCollectionView.backgroundColor = .clear
        
        forecastTableView.delegate = self
        forecastTableView.dataSource = self
        forecastTableView.register(UINib(nibName: "ForecastTableViewCell", bundle: nil), forCellReuseIdentifier: "ForecastTableViewCell")
        forecastTableView.rowHeight = 55
        forecastTableView.separatorStyle = .none
        forecastTableView.isUserInteractionEnabled = false
        forecastTableView.backgroundColor = .clear
        
        currentLocationView.collectionViewIndicator.isHidden = true
        currentLocationView.tableViewIndicator.isHidden = true
    }
    
    // MARK: - Network Monitor
    
    // we set up a network monitor to always check the connection
    // if there's no internet we show an error, otherwise we set up the location manager
    func setupNetworkMonitor() {
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                self.setupLocationManager()     /// mark - location services
                self.defaults.set(true, forKey: "isConnected")
            } else {
                let alert = UIAlertController(title: "Network Error", message: "Check your connection", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                self.defaults.set(false, forKey: "isConnected")
            }
        }
        
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
    // MARK: - Location Services
    
    // we check if the location services are enabled on the device, otherwise show an error
    func setupLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            checkLocationAuthorization()
        } else {
            let alert = UIAlertController(title: "Location services are disabled", message: "Go to Settings > Privacy > Location Services to turn it on", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    // we check the authorization of the app, show error or request authorization if needed
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()     /// mark: - CLLocationManagerDelegate
        case .denied:
            let alert = UIAlertController(title: "The app is denied to use location services", message: "Go to Settings > Privacy > Location Services to turn it on", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            let alert = UIAlertController(title: "Active restrictions block the app to use location services", message: "Check your parental controls to give access", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        case .authorizedAlways:
            /// won't happen
            break
        @unknown default:
            let alert = UIAlertController(title: "Unknown error", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    // MARK: - View Update
    
    // we make the activity indicators appear meanwhile we update the UI with the weather data
    // changes: update the background image, the view's labels, their colors according to the background picture, and the statusBar
    // we save the background image's name for later use too
    func updateView(with weatherData: WeatherData) {
        currentLocationView.collectionViewIndicator.isHidden = false
        currentLocationView.tableViewIndicator.isHidden = false
        currentLocationView.collectionViewIndicator.startAnimating()
        currentLocationView.tableViewIndicator.startAnimating()
        
        currentLocationView.updateLabels(weatherData.city,
                                         weatherData.temperature,
                                         weatherData.description,
                                         weatherData.pressure,
                                         weatherData.humidity,
                                         weatherData.wind,
                                         weatherData.cloudiness,
                                         weatherData.visibility)
        imageName = weatherData.getBackgroundPictureNameFromWeatherID(id: weatherData.weatherId)
        UIView.transition(with: self.view,
                          duration: 0.5,
                          options: .transitionCrossDissolve,
                          animations: { self.view.backgroundColor = UIColor(patternImage: UIImage(named: self.imageName)!) },
                          completion: nil)
        currentLocationView.updateUI(accordingTo: imageName)
        self.setNeedsStatusBarAppearanceUpdate()
        defaults.set(imageName, forKey: "backgroundImage")
    }
    
    // MARK: - Notification Method
    
    // we reload the user's location's weather data with the correct temperature unit
    @objc func updateUITemperatureUnit(_ notification: Notification) {
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Data Preparing
    
    // we prepare the upcoming days' forecast data to be presentable by the tableView
    // the API gives back 40 items, but we already cut off the first 24 hours (hence the 'ForHours' and 'ForDays' array)
    // for each day we need the max. and min. temperature and the midday's weather condition
    func loadDays() {
        daysData = []
        var idForWeatherImage = Int()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let daysArray = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        var minTemp = Int.max
        var maxTemp = Int.min
        let calendar = Calendar.current             /// gregorian calendar !!
        var dateForComparison = forecastWeatherDataForDays[0].date
        
        // we go through all the forecast data and get the max and min temperatures and the midday's weather id (11-13)
        // we always compare the starting date to the next item's date by day
        // if they differ, we save a forecast day and set the next day's date as the comparison date
        for index in 0...forecastWeatherDataForDays.count - 1 {
            if forecastWeatherDataForDays[index].temperature < minTemp {
                minTemp = forecastWeatherDataForDays[index].temperature
            }
            if forecastWeatherDataForDays[index].temperature > maxTemp {
                maxTemp = forecastWeatherDataForDays[index].temperature
            }
            
            if index < forecastWeatherDataForDays.count - 1 {
                let dayOfComparisonDate = Int(dateForComparison.components(separatedBy: " ")[0].components(separatedBy: "-")[2])
                let dayOfTheNextItem = Int(forecastWeatherDataForDays[index + 1].date.components(separatedBy: " ")[0].components(separatedBy: "-")[2])
                let hourOfIndexedItem = Int(forecastWeatherDataForDays[index].date.components(separatedBy: " ")[1].components(separatedBy: ":")[0])
                
                // we check if we're at the last item and if we've got 4 days
                // because of the timezones there could be situations when we're 1 or 2 hours short of the last day's forecast
                // the last one being at 22 or at 23 hour, so we would only have 3 days of 'whole day' forecast
                // since those last 1-2 hour of forecast data doesn't make that much of a difference (in a whole day's data)
                // even if those are missing we add the forecast data as a whole day's information so we always offer a 4 day forecast
                if dayOfComparisonDate != dayOfTheNextItem || (index + 1 == forecastWeatherDataForDays.count - 1 && daysData.count != 4) {
                    let dayDate = format.date(from: dateForComparison)!
                    let forecastDay = ForecastDayData(weatherID: idForWeatherImage,
                                                      maxTemperature: maxTemp,
                                                      minTemperature: minTemp,
                                                      day: daysArray[(calendar.component(.weekday, from: dayDate) - 1)]) /// weekday - 1 to get the correct index for daysArray
                    daysData.append(forecastDay)
                    
                    minTemp = Int.max
                    maxTemp = Int.min
                    dateForComparison = forecastWeatherDataForDays[index + 1].date
                }
                if [11,12,13].contains(hourOfIndexedItem!) {
                    idForWeatherImage = forecastWeatherDataForDays[index].weatherId
                }
            }
        }
    }

}

// MARK: - CLLocationManagerDelegate Methods

extension CurrentLocationViewController: CLLocationManagerDelegate {
    
    // when the location updates we request the location's weather information with coordinates
    // we update the view with the response data, otherwise we show an error
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // we check if the latitude and longitude are valid
        if location.horizontalAccuracy > 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            locationManager.stopUpdatingLocation()
            let coordinates = ["lat": String(location.coordinate.latitude), "lon": String(location.coordinate.longitude)]
            
            restManager.getWeatherData(with: coordinates) { [weak self] (result) in /// using weak on self to avoid retain cycle (updateView(:))
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let weatherData):
                        self.updateView(with: weatherData)      /// mark: - view update
                    case .failure(let error):
                        if error as! WeatherError == WeatherError.requestFailed {
                            let alert = UIAlertController(title: "Network Error", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true)
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        } else {
                            let alert = UIAlertController(title: "Unknown Error", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true)
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
                        self.loadDays()     /// mark: - data preparing
                        self.weatherCollectionView.reloadData()
                        self.forecastTableView.reloadData()
                        
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        self.currentLocationView.collectionViewIndicator.stopAnimating()
                        self.currentLocationView.tableViewIndicator.stopAnimating()
                        self.currentLocationView.collectionViewIndicator.isHidden = true
                        self.currentLocationView.tableViewIndicator.isHidden = true
                    case .failure(let error):
                        if error as! WeatherError == WeatherError.requestFailed {
                            let alert = UIAlertController(title: "Network Error", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true)
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        } else {
                            let alert = UIAlertController(title: "Unknown Error", message: nil, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true)
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }
                    }
                }
            }
        }
    }
    
    // error handling for different cases
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if case CLError.Code.locationUnknown = error {
            return
        } else if case CLError.Code.headingFailure = error {
            let alert = UIAlertController(title: "Error", message: "Couldn't determine location because of strong interference", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else if case CLError.Code.denied = error {
            let alert = UIAlertController(title: "The app is denied to use location services", message: "Go to Settings > Privacy > Location Services to turn it on", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            locationManager.stopUpdatingLocation()
        }
    }
    
    // we re-check the authorization when it's changed
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()       /// mark: - location services
    }
    
}

// MARK: - UICollectionView Delegate Methods

extension CurrentLocationViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return forecastWeatherDataForHours.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForecastCollectionViewCell", for: indexPath) as! ForecastCollectionViewCell
        
        let weatherItem = forecastWeatherDataForHours[indexPath.row]
        let hour = Int(weatherItem.date.components(separatedBy: " ")[1].components(separatedBy: ":")[0])
        
        cell.hourLabel.text = "\(hour!)"
        cell.degreeLabel.text = "\(weatherItem.temperature)°"
        
        let icons = weatherItem.getIconNameFromWeatherID(id: weatherItem.weatherId)
        cell.updateUIAccordingTo(backgroundPicture: imageName, with: icons)
        
        return cell
    }
    
}

// MARK: - UITableView Delegate Methods

extension CurrentLocationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastTableViewCell") as! ForecastTableViewCell
        
        let day = daysData[indexPath.row]
        
        cell.dayLabel.text = day.day
        cell.hottestLabel.text = "\(day.maxTemperature)°"
        cell.coldestLabel.text = "\(day.minTemperature)°"

        let icons = day.getIconNameFromWeatherID(id: day.weatherID)
        cell.updateUIAccordingTo(backgroundPicture: imageName, with: icons)
        
        return cell
    }
    
}
