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
    
    // MARK: - Constants, variables, properties
    
    private let defaults = UserDefaults.standard
    private var isTemperatureInCelsius = Bool()
    private var previousLocationsWeather = [WeatherData]()
    private var selectedWeatherData: WeatherData!
    private let restManager = RestManager.shared
    private var locations = [String : [String: String]]()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Outlets
    
    @IBOutlet weak var searchLocationView: SearchLocationView!
    @IBOutlet weak var locationTableView: UITableView!
    
    // MARK: - View Handling

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // we set up the statusBar, the segmented control and the tableView as needed
    // if there's no internet connection then we show the user an error, otherwise we prepare the locations' data
    private func setupUI() {
        self.setNeedsStatusBarAppearanceUpdate()
        
        searchLocationView.segmentedControl.selectedSegmentIndex = defaults.integer(forKey: "temperatureUnit")
        searchLocationView.tableViewIndicator.isHidden = true
        
        locationTableView.delegate = self
        locationTableView.dataSource = self
        locationTableView.register(UINib(nibName: "LocationTableViewCell", bundle: nil), forCellReuseIdentifier: "LocationTableViewCell")
        locationTableView.rowHeight = 70
        locationTableView.backgroundColor = .clear
        locationTableView.separatorColor = .black
        
        if defaults.bool(forKey: "isConnected") {
            loadLocations(isCalledFromDelegateMethod: false)    /// mark: - data preparing
        } else {
            let alert = UIAlertController(title: "Network Error", message: "Check your connection", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    // MARK: - Data Preparing
    
    // we prepare the previous locations (if there's any) which were searched by the user to be presentable by the tableView
    // we make the indicators appear meanwhile we load up the locations and get their data
    // the locations are stored as a dictionary (in userdefaults) which contains each location's name and coordinates or just the name
    // this depends on how the user searched the location:
    // either by name from the second tab -> only the name gets stored
    // or by the map in the third tab -> the name and the coordinates get stored
    // we go through the dictionary's items and get each location's weather information
    // we do this every time this function is called so we always show the current weather information for each location
    // the locations appear in alphabetical order
    private func loadLocations(isCalledFromDelegateMethod: Bool) {
        if let previousLocations = defaults.dictionary(forKey: "locations") as? [String: [String: String]], previousLocations.count != 0 {
            if !isCalledFromDelegateMethod {   /// check if the function was called through delegation
                searchLocationView.tableViewIndicator.isHidden = false
                searchLocationView.tableViewIndicator.startAnimating()
            }
            
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
                                    
                                    if !isCalledFromDelegateMethod {
                                        self.searchLocationView.tableViewIndicator.stopAnimating()
                                        self.searchLocationView.tableViewIndicator.isHidden = true
                                    }
                                }
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
                                    
                                    if !isCalledFromDelegateMethod {
                                        self.searchLocationView.tableViewIndicator.stopAnimating()
                                        self.searchLocationView.tableViewIndicator.isHidden = true
                                    }
                                }
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
                }   /// city.value if else
            }   /// for loop
            
            isTemperatureInCelsius = self.defaults.integer(forKey: "temperatureUnit") == 0 ? true : false
        }
    }
    
    // MARK: - Segue Preparing
    
    // GetWeatherSegue -> we check if the textfield contains the allowed characterset or anything at all, otherwise we show an error
    // we get rid of the diacritics/accents and present the GetWeatherViewController
    // LocationSegue -> we check if the selected location has coordinates stored too so we get the location's weather information by that,
    // otherwise we use it's name and present the GetWeatherViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GetWeatherSegue" {
            let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ,- ")
            let commaCount = searchLocationView.textField.text!.filter { $0 == "," }.count
            
            if searchLocationView.textField.text! == "" {
                let alert = UIAlertController(title: "Empty textfield", message: "Characters allowed: [A-z], [-,]", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            } else if searchLocationView.textField.text!.rangeOfCharacter(from: characterset.inverted) != nil {
                let alert = UIAlertController(title: "Please don't use special characters", message: "Characters allowed: [A-z], [-,]", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            } else if commaCount > 1 {
                let alert = UIAlertController(title: "Too many commas used", message: "Use 1 comma to add the country code after the city's name", preferredStyle: .alert)
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
    
    // MARK: - Segmented Control
    
    // we set the temperatureUnit and notify the observers about the change, then reload the tableView too so it shows the correct unit
    @IBAction func chooseTemperatureUnit(_ sender: UISegmentedControl) {
        defaults.set(sender.selectedSegmentIndex, forKey: "temperatureUnit")
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "didChangeTemperatureUnit")))
        locationTableView.reloadData()
    }
    
}

// MARK: - PreviousLocationDelegate Method

extension SearchLocationViewController: PreviousLocationDelegate {
    
    // first we check if there's any previously stored location, otherwise we create a new one
    // and save the currently searched location's name (and coordinates if coming from the MapViewC)
    // if there's an already existing locations dictionary, then we check if the currently searched one is already stored or not
    // either way we call the loadLocations(:) method  -> mark: - data preparing
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
                loadLocations(isCalledFromDelegateMethod: true)
            }
        } else {
            var previousLocations = [String: [String: String]]()
            previousLocations[name] = coordinates
            defaults.set(previousLocations, forKey: "locations")
            loadLocations(isCalledFromDelegateMethod: true)
        }
    }
    
}

// MARK: - UITableView Delegate Methods

extension SearchLocationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return previousLocationsWeather.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell") as! LocationTableViewCell
        let weatherData = previousLocationsWeather[indexPath.row]
        
        cell.delegate = self
        
        cell.cityLabel.text = weatherData.city
        let temperature = weatherData.temperature
        
        // we check the temperature unit
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
    
    // we save the selected location's weather data and perform a segue with it
    // but only if the user is connected, otherwise we show an error
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if defaults.bool(forKey: "isConnected") {
            selectedWeatherData = previousLocationsWeather[indexPath.row]
            performSegue(withIdentifier: "LocationSegue", sender: locationTableView.cellForRow(at: indexPath))  /// mark: - segue preparing
            locationTableView.deselectRow(at: indexPath, animated: true)
        } else {
            let alert = UIAlertController(title: "Network Error", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
}

// MARK: - SwipeTableViewCell Delegate Methods

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
