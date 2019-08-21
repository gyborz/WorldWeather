//
//  SecondViewController.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 07. 30..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit
import SwipeCellKit

class SearchLocationViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    var isTemperatureInCelsius = Bool()
    var previousLocationsWeather = [WeatherData]()
    var selectedWeatherData: WeatherData!
    let restManager = RestManager()
    var locations = [String : [String: String]]()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBOutlet weak var searchLocationView: SearchLocationView!
    @IBOutlet weak var locationTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        searchLocationView.segmentedControl.selectedSegmentIndex = defaults.integer(forKey: "temperatureUnit")
        
        locationTableView.delegate = self
        locationTableView.dataSource = self
        locationTableView.register(UINib(nibName: "LocationTableViewCell", bundle: nil), forCellReuseIdentifier: "LocationTableViewCell")
        locationTableView.rowHeight = 70
        locationTableView.backgroundColor = .clear
        locationTableView.separatorColor = .black
        
        if defaults.bool(forKey: "isConnected") {
            loadLocations()
        } else {
            let alert = UIAlertController(title: "Network Error", message: "Check your connection", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    func loadLocations() {
        if let previousLocations = defaults.dictionary(forKey: "locations") as? [String: [String: String]] {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            locations = previousLocations
            previousLocationsWeather = []
            var cityIndex = 0
            
            for city in previousLocations {
                if city.value != [:] {
                    restManager.getWeatherData(with: city.value) { [weak self] (result) in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let weatherData):
                                self.previousLocationsWeather.append(weatherData)
                                cityIndex += 1
                                
                                guard self.locationTableView != nil else { return } /// can be nil when accessed from the mapViewC through delegation
                                if cityIndex == previousLocations.count {
                                    self.previousLocationsWeather.sort { $0.city < $1.city }
                                    self.locationTableView.reloadData()
                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                }
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
                } else {
                    restManager.getWeatherData(with: city.key) { [weak self] (result) in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            switch result {
                            case .success(let weatherData):
                                self.previousLocationsWeather.append(weatherData)
                                cityIndex += 1
                                
                                guard self.locationTableView != nil else { return } /// can be nil when accessed from the mapViewC through delegation
                                if cityIndex == previousLocations.count {
                                    self.previousLocationsWeather.sort { $0.city < $1.city }
                                    self.locationTableView.reloadData()
                                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                                }
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
                }   /// city.value if else
            }   /// for loop
            
            isTemperatureInCelsius = self.defaults.integer(forKey: "temperatureUnit") == 0 ? true : false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GetWeather" {
            let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,- ")
            
            if searchLocationView.textField.text! == "" {
                let alert = UIAlertController(title: "Empty textfield", message: "Characters allowed: [A-z], [-,]", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            } else if searchLocationView.textField.text!.rangeOfCharacter(from: characterset.inverted) != nil {
                let alert = UIAlertController(title: "Please don't use special characters", message: "Characters allowed: [A-z], [-,]", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            } else {
                let destinationVC = segue.destination as! GetWeatherViewController
                destinationVC.delegate = self
                
                let locationName = (searchLocationView.textField.text?.folding(options: .diacriticInsensitive, locale: .current))!
                destinationVC.getWeatherInformation(with: locationName)
                searchLocationView.textField.text = ""
            }
        }
        if segue.identifier == "LocationSegue" {
            let destinationVC = segue.destination as! GetWeatherViewController
            
            var coordinates = [String:String]()
            let hasCoordinates = locations.contains { (key, value) -> Bool in
                if key == selectedWeatherData.city && value != [:] {
                    coordinates = value
                    return true
                } else {
                    return false
                }
            }
            if hasCoordinates {
                destinationVC.getWeatherInformation(with: coordinates)
            } else {
                destinationVC.getWeatherInformation(with: selectedWeatherData.city)
            }
        }
    }
    
    @IBAction func chooseTemperatureUnit(_ sender: UISegmentedControl) {
        defaults.set(sender.selectedSegmentIndex, forKey: "temperatureUnit")
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "didChangeTemperatureUnit")))
        locationTableView.reloadData()
    }
    
}

extension SearchLocationViewController: PreviousLocationDelegate {
    
    func addLocation(_ name: String, _ coordinates: [String: String]) {
        if var previousLocations = defaults.dictionary(forKey: "locations") as? [String: [String: String]] {
            let containsCity = previousLocations.contains { (key, value) -> Bool in
                if key == name {
                    return true
                } else {
                    return false
                }
            }
            
            if !containsCity {
                previousLocations[name] = coordinates
                defaults.set(previousLocations, forKey: "locations")
                loadLocations()
            }
        } else {
            var previousLocations = [String: [String: String]]()
            previousLocations[name] = coordinates
            defaults.set(previousLocations, forKey: "locations")
            loadLocations()
        }
    }
    
}

extension SearchLocationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        locationTableView.separatorStyle = previousLocationsWeather.count != 0 ? .none : .singleLine
        return previousLocationsWeather.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell") as! LocationTableViewCell
        let weatherData = previousLocationsWeather[indexPath.row]
        
        cell.delegate = self
        
        cell.cityLabel.text = weatherData.city
        let temperature = weatherData.temperature
        
        if isTemperatureInCelsius {
            if defaults.integer(forKey: "temperatureUnit") == 0 {
                cell.temperatureLabel.text = "\(temperature)°"
            } else {
                cell.temperatureLabel.text = "\(temperature * 9 / 5 + 32)°"     /// to Fahrenheit
            }
        } else {
            if defaults.integer(forKey: "temperatureUnit") == 1 {
                cell.temperatureLabel.text = "\(temperature)°"
            } else {
                cell.temperatureLabel.text = "\((temperature - 32) * 5 / 9)°"   /// to Celsius
            }
        }
        
        let imageName = weatherData.getBackgroundPictureNameFromWeatherID(id: weatherData.weatherId)
        let icons = weatherData.getIconNameFromWeatherID(id: weatherData.weatherId)
        cell.updateUIAccordingTo(backgroundPicture: imageName, with: icons)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if defaults.bool(forKey: "isConnected") {
            selectedWeatherData = previousLocationsWeather[indexPath.row]
            performSegue(withIdentifier: "LocationSegue", sender: locationTableView.cellForRow(at: indexPath))
            locationTableView.deselectRow(at: indexPath, animated: true)
        } else {
            let alert = UIAlertController(title: "Network Error", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
}

extension SearchLocationViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.locationTableView.beginUpdates()
            self.locations.removeValue(forKey: self.previousLocationsWeather[indexPath.row].city)
            self.previousLocationsWeather.remove(at: indexPath.row)
            self.defaults.set(self.locations, forKey: "locations")
        }

        deleteAction.image = UIImage(named: "delete")
        self.locationTableView.endUpdates()
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        options.transitionStyle = .border
        return options
    }
    
}
