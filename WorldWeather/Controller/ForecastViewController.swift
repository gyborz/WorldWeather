//
//  ForecastViewController.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 08. 01..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class ForecastViewController: UIViewController {
    
    var forecastData: [WeatherData]!
    
    @IBOutlet weak var forecastTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        forecastTableView.delegate = self
        forecastTableView.dataSource = self
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}

extension ForecastViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastTableViewCell") as! ForecastTableViewCell
        
        return cell
    }
    
}
