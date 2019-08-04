//
//  SecondViewController.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 07. 30..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class SearchLocationViewController: UIViewController {
    
    @IBOutlet weak var searchLocationView: SearchLocationView!
    @IBOutlet weak var locationTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //searchLocationView:.segmentedControl.selectedSegmentIndex = defaults.integer(forKey: "temperatureUnit")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GetWeather" {
            let destinationVC = segue.destination as! GetWeatherViewController
            destinationVC.getWeatherInformation(with: searchLocationView.textField.text!)
        }
    }

}

