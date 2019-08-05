//
//  GetWeatherViewController.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 08. 04..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class GetWeatherViewController: UIViewController {
    
    var forecastWeatherDataForHours: [WeatherData]!
    var forecastWeatherDataForDays: [WeatherData]!
    var daysData = [ForecastDayData]()
    let restManager = RestManager()
    
    @IBOutlet weak var getWeatherView: GetWeatherView!
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
    
    func loadDays() {
        let daysArray = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        var minTemp = Int.max
        var maxTemp = Int.min
        let calendar = Calendar.current             /// gregorian calendar !!
        var dateFlag = forecastWeatherDataForDays[0].date
        
        for index in 0...forecastWeatherDataForDays.count - 1 {
            if forecastWeatherDataForDays[index].temperature < minTemp {
                minTemp = forecastWeatherDataForDays[index].temperature
            }
            if forecastWeatherDataForDays[index].temperature > maxTemp {
                maxTemp = forecastWeatherDataForDays[index].temperature
            }
            
            if index < forecastWeatherDataForDays.count - 1 {
                // watch out for the dates' values in the equation (see explanation under CurrentLocationViewController - saveForecastDataFromJSON(json:))
                if calendar.component(.day, from: dateFlag) != calendar.component(.day, from: forecastWeatherDataForDays[index + 1].date) {
                    let forecastDay = ForecastDayData(maxTemperature: maxTemp,
                                                      minTemperature: minTemp,
                                                      day: daysArray[(calendar.component(.weekday, from: dateFlag) - 1)]) /// weekday - 1 to get the correct index for daysArray
                    daysData.append(forecastDay)
                    
                    minTemp = Int.max
                    maxTemp = Int.min
                    dateFlag = forecastWeatherDataForDays[index + 1].date
                }
            }
        }
    }
    
    func updateView(with weatherData: WeatherData) {
        getWeatherView.updateUI(weatherData.city,
                                weatherData.temperature,
                                weatherData.description,
                                weatherData.pressure,
                                weatherData.humidity,
                                weatherData.wind,
                                weatherData.cloudiness,
                                weatherData.visibility)
    }
    
    func getWeatherInformation(with text: String) {
        restManager.getWeatherData(with: text) { (weatherData) in
            DispatchQueue.main.async {
                self.updateView(with: weatherData)
            }
        }
        restManager.getWeatherForecastData(with: text) { (forHours, forDays) in
            self.forecastWeatherDataForHours = forHours
            self.forecastWeatherDataForDays = forDays
            self.loadDays()
            DispatchQueue.main.async {
                self.forecastTableView.reloadData()
                self.weatherCollectionView.reloadData()
            }
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}

extension GetWeatherViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastTableViewCell") as! ForecastTableViewCell
        cell.dayLabel.text = daysData[indexPath.row].day
        cell.hottestLabel.text = "\(daysData[indexPath.row].maxTemperature)°"
        cell.coldestLabel.text = "\(daysData[indexPath.row].minTemperature)°"
        return cell
    }
    
}

extension GetWeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if forecastWeatherDataForHours == nil {
            return 0
        } else {
            return forecastWeatherDataForHours.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForecastCollectionViewCell", for: indexPath) as! ForecastCollectionViewCell
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let dateString = dateFormatter.string(from: forecastWeatherDataForHours[indexPath.row].date)
        let hour = Int(dateString.components(separatedBy: " ")[1].components(separatedBy: ":")[0])
        
        cell.hourLabel.text = "\(hour!)"
        cell.degreeLabel.text = "\(forecastWeatherDataForHours[indexPath.row].temperature)°"
        
        return cell
    }
    
}
