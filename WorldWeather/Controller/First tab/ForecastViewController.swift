//
//  ForecastViewController.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 08. 01..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class ForecastViewController: UIViewController {
    
    var forecastWeatherData: [WeatherData]!
    var daysData = [ForecastDayData]()
    var idForWeatherImage = Int()
    var imageName = "background"
    
    @IBOutlet weak var forecastView: UIView!
    @IBOutlet weak var forecastTableView: UITableView!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDays()
        
        loadUI()
    }
    
    func loadDays() {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let daysArray = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        var minTemp = Int.max
        var maxTemp = Int.min
        let calendar = Calendar.current             /// gregorian calendar !!
        var dateForComparison = forecastWeatherData[0].date
        
        // we go through all the forecast data and get the max and min temperatures and the midday's weather id (11-13)
        // we always compare the starting date to the next item's date by day
        // if they differ, we save a forecast day and set the next day's date as the comparison date
        for index in 0...forecastWeatherData.count - 1 {
            if forecastWeatherData[index].temperature < minTemp {
                minTemp = forecastWeatherData[index].temperature
            }
            if forecastWeatherData[index].temperature > maxTemp {
                maxTemp = forecastWeatherData[index].temperature
            }
            
            if index < forecastWeatherData.count - 1 {
                let dayOfComparisonDate = Int(dateForComparison.components(separatedBy: " ")[0].components(separatedBy: "-")[2])
                let dayOfTheNextItem = Int(forecastWeatherData[index + 1].date.components(separatedBy: " ")[0].components(separatedBy: "-")[2])
                let hourOfIndexedItem = Int(forecastWeatherData[index].date.components(separatedBy: " ")[1].components(separatedBy: ":")[0])
                
                if dayOfComparisonDate! != dayOfTheNextItem! {
                    let dayDate = format.date(from: dateForComparison)!
                    let forecastDay = ForecastDayData(maxTemperature: maxTemp,
                                                      minTemperature: minTemp,
                                                      day: daysArray[(calendar.component(.weekday, from: dayDate) - 1)]) /// weekday - 1 to get the correct index for daysArray
                    forecastDay.weatherID = idForWeatherImage
                    daysData.append(forecastDay)
                    
                    minTemp = Int.max
                    maxTemp = Int.min
                    dateForComparison = forecastWeatherData[index + 1].date
                }
                if [11,12,13].contains(hourOfIndexedItem!) {
                    idForWeatherImage = forecastWeatherData[index].weatherId
                }
            }
        }
    }
    
    func loadUI() {
        let imageNames = ["sunny", "cloudy_moon", "night", "rainy", "thunderstorm"]
        
        forecastView.layer.cornerRadius = 10
        forecastView.layer.borderWidth = 2
        forecastView.layer.borderColor = imageNames.contains(imageName) ? UIColor.white.cgColor : UIColor.black.cgColor
        forecastView.backgroundColor = imageNames.contains(imageName) ? UIColor(white: 1, alpha: 0.5) : UIColor(white: 0.45, alpha: 0.5)
        
        closeButton.backgroundColor = UIColor.red.withAlphaComponent(0.1)
        closeButton.layer.cornerRadius = 15
        closeButton.layer.borderWidth = 1
        closeButton.layer.borderColor = UIColor.red.cgColor
        
        forecastTableView.delegate = self
        forecastTableView.dataSource = self
        forecastTableView.register(UINib(nibName: "ForecastTableViewCell", bundle: nil), forCellReuseIdentifier: "ForecastTableViewCell")
        forecastTableView.rowHeight = 60
        forecastTableView.separatorStyle = .none
        forecastTableView.isUserInteractionEnabled = false
    }
    
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

}

extension ForecastViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ForecastTableViewCell") as! ForecastTableViewCell
        
        let day = daysData[indexPath.row]
        
        cell.dayLabel.text = day.day
        cell.hottestLabel.text = "\(day.maxTemperature)°"
        cell.coldestLabel.text = "\(day.minTemperature)°"
        
        let imageName = day.getBackgroundPictureNameFromWeatherID(id: day.weatherID)
        let icons = day.getIconNameFromWeatherID(id: day.weatherID)
        cell.updateUIAccordingTo(backgroundPicture: imageName, with: icons)
        
        return cell
    }
    
}
