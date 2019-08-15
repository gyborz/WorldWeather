//
//  GetWeatherViewController.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 08. 04..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

protocol PreviousLocationDelegate {
    func addLocation(_ name: String)
}

class GetWeatherViewController: UIViewController {
    
    var forecastWeatherDataForHours: [WeatherData]!
    var forecastWeatherDataForDays: [WeatherData]!
    var daysData = [ForecastDayData]()
    let restManager = RestManager()
    var delegate: PreviousLocationDelegate?
    var idForWeatherImage = Int()
    var imageName = "background"
    
    @IBOutlet weak var getWeatherView: GetWeatherView!
    @IBOutlet weak var weatherCollectionView: UICollectionView!
    @IBOutlet weak var forecastTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getWeatherView.layer.cornerRadius = 10

        forecastTableView.delegate = self
        forecastTableView.dataSource = self
        forecastTableView.register(UINib(nibName: "ForecastTableViewCell", bundle: nil), forCellReuseIdentifier: "ForecastTableViewCell")
        forecastTableView.rowHeight = 60
        forecastTableView.allowsSelection = false
        forecastTableView.backgroundColor = .clear
        forecastTableView.separatorStyle = .none
        
        if UIScreen.main.bounds.height >= 812 {
            forecastTableView.isUserInteractionEnabled = false
        }
        
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
                    forecastDay.weatherID = idForWeatherImage
                    daysData.append(forecastDay)
                    
                    minTemp = Int.max
                    maxTemp = Int.min
                    dateFlag = forecastWeatherDataForDays[index + 1].date
                }
                if calendar.component(.hour, from: forecastWeatherDataForDays[index].date) == 12 {
                    idForWeatherImage = forecastWeatherDataForDays[index].weatherId
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
        imageName = weatherData.getBackgroundPictureNameFromWeatherID(id: weatherData.weatherId)
        getWeatherView.updateBackgroundImage(with: imageName)
    }
    
    func getWeatherInformation(with text: String) {
        restManager.getWeatherData(with: text) { [weak self] (result) in /// using weak on self to avoid retain cycle (updateView(:), addLocation(_))
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let weatherData):
                    self.updateView(with: weatherData)
                    self.delegate?.addLocation(weatherData.city)
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
        
        restManager.getWeatherForecastData(with: text) { [weak self] (result) in /// using weak on self to avoid retain cycle (forecast.. arrays, loadDays(), reloadData())
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let forecastData):
                    self.forecastWeatherDataForHours = forecastData.forHours
                    self.forecastWeatherDataForDays = forecastData.forDays
                    self.loadDays()
                    self.forecastTableView.reloadData()
                    self.weatherCollectionView.reloadData()
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
    }
    
    func getWeatherInformation(with coordinates: [String: String]) {
        restManager.getWeatherData(with: coordinates) { [weak self] (result) in /// using weak on self to avoid retain cycle (updateView(:), addLocation(_))
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let weatherData):
                    self.updateView(with: weatherData)
                    let locationName = weatherData.city.folding(options: .diacriticInsensitive, locale: .current)
                    self.delegate?.addLocation(locationName)
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
        
        restManager.getWeatherForecastData(with: coordinates) { [weak self] (result) in /// using weak on self to avoid retain cycle (forecast.. arrays, loadDays(), reloadData())
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let forecastData):
                    self.forecastWeatherDataForHours = forecastData.forHours
                    self.forecastWeatherDataForDays = forecastData.forDays
                    self.loadDays()
                    self.forecastTableView.reloadData()
                    self.weatherCollectionView.reloadData()
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
        
        let weatherItem = forecastWeatherDataForHours[indexPath.row]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let dateString = dateFormatter.string(from: weatherItem.date)
        let hour = Int(dateString.components(separatedBy: " ")[1].components(separatedBy: ":")[0])
        
        cell.hourLabel.text = "\(hour!)"
        cell.degreeLabel.text = "\(weatherItem.temperature)°"
        
        let icons = weatherItem.getIconNameFromWeatherID(id: weatherItem.weatherId)
        cell.updateUIAccordingTo(backgroundPicture: imageName, with: icons)
        
        return cell
    }
    
}
