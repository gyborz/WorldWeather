//
//  GetWeatherViewController.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 08. 04..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class GetWeatherViewController: UIViewController {
    
    @IBOutlet weak var weatherCollectionView: UICollectionView!
    @IBOutlet weak var forecastTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        forecastTableView.delegate = self
        forecastTableView.dataSource = self
        forecastTableView.register(UINib(nibName: "ForecastTableViewCell", bundle: nil), forCellReuseIdentifier: "ForecastTableViewCell")
        forecastTableView.rowHeight = 60
        forecastTableView.allowsSelection = false
        
        weatherCollectionView.delegate = self
        weatherCollectionView.dataSource = self
        weatherCollectionView.register(UINib(nibName: "ForecastCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ForecastCollectionViewCell")
        weatherCollectionView.backgroundColor = .clear
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}

extension GetWeatherViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return daysData.count
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastTableViewCell") as! ForecastTableViewCell
//        cell.dayLabel.text = daysData[indexPath.row].day
//        cell.hottestLabel.text = "\(daysData[indexPath.row].maxTemperature)°"
//        cell.coldestLabel.text = "\(daysData[indexPath.row].minTemperature)°"
        cell.dayLabel.text = "Monday"
        cell.hottestLabel.text = "25°"
        cell.coldestLabel.text = "14°"
        return cell
    }
    
}

extension GetWeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if forecastWeatherDataFor24Hours == nil {
//            return 0
//        } else {
//            return forecastWeatherDataFor24Hours.count
//        }
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForecastCollectionViewCell", for: indexPath) as! ForecastCollectionViewCell
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        //let dateString = dateFormatter.string(from: forecastWeatherDataFor24Hours[indexPath.row].date)
        //let hour = Int(dateString.components(separatedBy: " ")[1].components(separatedBy: ":")[0])
        
        //cell?.hourLabel.text = "\(hour!)"
        //cell?.degreeLabel.text = "\(forecastWeatherDataFor24Hours[indexPath.row].temperature)°"
        
        cell.hourLabel.text = "12"
        cell.degreeLabel.text = "28°"
        
        return cell
    }
    
}
