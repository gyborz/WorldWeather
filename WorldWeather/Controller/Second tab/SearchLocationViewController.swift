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
    var previousLocationNames = [String]()
    var previousLocationsWeather = [WeatherData]()
    var selectedWeatherData: WeatherData!
    let restManager = RestManager()
    
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
        
        loadPreviousLocations()
    }
    
    func loadPreviousLocations() {
        if let previousLocations = defaults.array(forKey: "previousLocations") as? [String] {
            previousLocationNames = previousLocations
            previousLocationsWeather = []
            for location in previousLocationNames {
                self.restManager.getWeatherData(with: location) { (weatherData) in
                    DispatchQueue.main.async {
                        self.previousLocationsWeather.append(weatherData)
                        self.locationTableView.reloadData()
                    }
                }
            }
            isTemperatureInCelsius = self.defaults.integer(forKey: "temperatureUnit") == 0 ? true : false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GetWeather" {
            let destinationVC = segue.destination as! GetWeatherViewController
            destinationVC.delegate = self
            destinationVC.getWeatherInformation(with: searchLocationView.textField.text!)
        }
        if segue.identifier == "LocationSegue" {
            let destinationVC = segue.destination as! GetWeatherViewController
            destinationVC.getWeatherInformation(with: selectedWeatherData.city)
        }
    }
    
    @IBAction func chooseTemperatureUnit(_ sender: UISegmentedControl) {
        defaults.set(sender.selectedSegmentIndex, forKey: "temperatureUnit")
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "didChangeTemperatureUnit")))
        locationTableView.reloadData()
    }
    
}

extension SearchLocationViewController: PreviousLocationDelegate {
    
    func addLocation(_ name: String) {
        if !previousLocationNames.contains(name) {
            previousLocationNames.append(name)
            defaults.set(previousLocationNames, forKey: "previousLocations")
            loadPreviousLocations()
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
        
        cell.delegate = self
        
        cell.cityLabel.text = previousLocationsWeather[indexPath.row].city
        let temperature = previousLocationsWeather[indexPath.row].temperature
        
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedWeatherData = previousLocationsWeather[indexPath.row]
        performSegue(withIdentifier: "LocationSegue", sender: locationTableView.cellForRow(at: indexPath))
        locationTableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension SearchLocationViewController: SwipeTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            self.locationTableView.beginUpdates()
            self.previousLocationNames.removeAll() { $0 == self.previousLocationsWeather[indexPath.row].city }
            self.previousLocationsWeather.remove(at: indexPath.row)
            self.defaults.set(self.previousLocationNames, forKey: "previousLocations")
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
