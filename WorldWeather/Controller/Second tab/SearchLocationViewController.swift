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
    @IBOutlet weak var searchLocationView: SearchLocationView!
    @IBOutlet weak var locationTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchLocationView.segmentedControl.selectedSegmentIndex = defaults.integer(forKey: "temperatureUnit")
        
        locationTableView.delegate = self
        locationTableView.dataSource = self
        locationTableView.register(UINib(nibName: "LocationTableViewCell", bundle: nil), forCellReuseIdentifier: "LocationTableViewCell")
        locationTableView.rowHeight = 70
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GetWeather" {
            let destinationVC = segue.destination as! GetWeatherViewController
            destinationVC.getWeatherInformation(with: searchLocationView.textField.text!)
        }
    }
    
    @IBAction func chooseTemperatureUnit(_ sender: UISegmentedControl) {
        defaults.set(sender.selectedSegmentIndex, forKey: "temperatureUnit")
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "didChangeTemperatureUnit")))
    }
    
}

extension SearchLocationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationTableViewCell") as! LocationTableViewCell
        cell.cityLabel.text = "Rio de Janeiro, BR"
        cell.temperatureLabel.text = "123°"
        return cell
    }
    
}
