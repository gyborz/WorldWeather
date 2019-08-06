//
//  SecondViewController.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 07. 30..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class SearchLocationViewController: UIViewController {
    
    let defaults = UserDefaults.standard
    var previousLocationNames = [String]()
    var previousLocationsWeather = [WeatherData]()
    let restManager = RestManager()
    
    @IBOutlet weak var searchLocationView: SearchLocationView!
    @IBOutlet weak var locationTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchLocationView.segmentedControl.selectedSegmentIndex = defaults.integer(forKey: "temperatureUnit")
        
        locationTableView.delegate = self
        locationTableView.dataSource = self
        locationTableView.register(UINib(nibName: "LocationTableViewCell", bundle: nil), forCellReuseIdentifier: "LocationTableViewCell")
        locationTableView.rowHeight = 70
        
        loadPreviousLocations()
    }
    
    func loadPreviousLocations() {
        if let previousLocations = defaults.array(forKey: "previousLocations") as? [String] {
            previousLocationNames = previousLocations
            previousLocationsWeather = []
            for location in previousLocationNames {
                restManager.getWeatherData(with: location) { (weatherData) in
                    DispatchQueue.main.async {
                        self.previousLocationsWeather.append(weatherData)
                        self.locationTableView.reloadData()
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GetWeather" {
            let destinationVC = segue.destination as! GetWeatherViewController
            destinationVC.delegate = self
            destinationVC.getWeatherInformation(with: searchLocationView.textField.text!)
        }
    }
    
    @IBAction func chooseTemperatureUnit(_ sender: UISegmentedControl) {
        defaults.set(sender.selectedSegmentIndex, forKey: "temperatureUnit")
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "didChangeTemperatureUnit")))
        loadPreviousLocations()
        //locationTableView.reloadData()
    }
    
}

extension SearchLocationViewController: PreviousLocationDelegate {
    
    func addLocation(_ name: String) {
        if !previousLocationNames.contains(name) {
            previousLocationNames.append(name)
            defaults.set(previousLocationNames, forKey: "previousLocations")
            loadPreviousLocations()
            //locationTableView.reloadData()
        }
    }
    
}

extension SearchLocationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return previousLocationsWeather.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell") as! LocationTableViewCell
        
        cell.cityLabel.text = previousLocationsWeather[indexPath.row].city
        cell.temperatureLabel.text = "\(previousLocationsWeather[indexPath.row].temperature)°"
        
        return cell
    }
    
}
