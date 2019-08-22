//
//  GetWeatherViewController.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 08. 04..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

protocol PreviousLocationDelegate {
    func addLocation(_ name: String, _ coordinates: [String: String])
}

class GetWeatherViewController: UIViewController {
    
    var forecastWeatherDataForHours: [WeatherData]!
    var forecastWeatherDataForDays: [WeatherData]!
    var daysData = [ForecastDayData]()
    let restManager = RestManager()
    var delegate: PreviousLocationDelegate?
    var idForWeatherImage = Int()
    var imageName = "background"
    
    let minimumVelocityToHide: CGFloat = 1500
    let minimumScreenRatioToHide: CGFloat = 0.3
    let animationDuration: TimeInterval = 0.3
    
    @IBOutlet weak var getWeatherView: GetWeatherView!
    @IBOutlet weak var weatherCollectionView: UICollectionView!
    @IBOutlet weak var forecastTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getWeatherView.layer.cornerRadius = 10
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        getWeatherView.addGestureRecognizer(panGesture)

        forecastTableView.delegate = self
        forecastTableView.dataSource = self
        forecastTableView.register(UINib(nibName: "ForecastTableViewCell", bundle: nil), forCellReuseIdentifier: "ForecastTableViewCell")
        
        forecastTableView.allowsSelection = false
        forecastTableView.backgroundColor = .clear
        forecastTableView.separatorStyle = .none
        
        if UIScreen.main.bounds.height >= 812 {
            forecastTableView.rowHeight = 65
            forecastTableView.isUserInteractionEnabled = false
        } else if UIScreen.main.bounds.height == 568 {
            forecastTableView.rowHeight = 45
        } else {
            forecastTableView.rowHeight = 60
            forecastTableView.isUserInteractionEnabled = false
        }
        
        weatherCollectionView.delegate = self
        weatherCollectionView.dataSource = self
        weatherCollectionView.register(UINib(nibName: "ForecastCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ForecastCollectionViewCell")
        weatherCollectionView.backgroundColor = .clear
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.view.frame.origin = CGPoint(x: 0, y: UIApplication.shared.statusBarFrame.height)
    }
    
    func loadDays() {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let daysArray = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        var minTemp = Int.max
        var maxTemp = Int.min
        let calendar = Calendar.current             /// gregorian calendar !!
        var dateForComparison = forecastWeatherDataForDays[0].date
        
        // we go through all the forecast data and get the max and min temperatures and the midday's weather id (11-13)
        // we always compare the starting date to the next item's date by day
        // if they differ, we save a forecast day and set the next day's date as the comparison date
        for index in 0...forecastWeatherDataForDays.count - 1 {
            if forecastWeatherDataForDays[index].temperature < minTemp {
                minTemp = forecastWeatherDataForDays[index].temperature
            }
            if forecastWeatherDataForDays[index].temperature > maxTemp {
                maxTemp = forecastWeatherDataForDays[index].temperature
            }
            
            if index < forecastWeatherDataForDays.count - 1 {
                let dayOfComparisonDate = Int(dateForComparison.components(separatedBy: " ")[0].components(separatedBy: "-")[2])
                let dayOfTheNextItem = Int(forecastWeatherDataForDays[index + 1].date.components(separatedBy: " ")[0].components(separatedBy: "-")[2])
                let hourOfIndexedItem = Int(forecastWeatherDataForDays[index].date.components(separatedBy: " ")[1].components(separatedBy: ":")[0])
                
                if dayOfComparisonDate != dayOfTheNextItem || (index + 1 == forecastWeatherDataForDays.count - 1 && daysData.count != 4) {
                    let dayDate = format.date(from: dateForComparison)!
                    let forecastDay = ForecastDayData(maxTemperature: maxTemp,
                                                      minTemperature: minTemp,
                                                      day: daysArray[(calendar.component(.weekday, from: dayDate) - 1)]) /// weekday - 1 to get the correct index for daysArray
                    forecastDay.weatherID = idForWeatherImage
                    daysData.append(forecastDay)
                    
                    minTemp = Int.max
                    maxTemp = Int.min
                    dateForComparison = forecastWeatherDataForDays[index + 1].date
                }
                if [11,12,13].contains(hourOfIndexedItem!) {
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
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        restManager.getWeatherData(with: text) { [weak self] (result) in /// using weak on self to avoid retain cycle (updateView(:), addLocation(_))
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let weatherData):
                    self.updateView(with: weatherData)
                    self.delegate?.addLocation(weatherData.city, [:])
                case .failure(let error):
                    if error as! WeatherError == WeatherError.requestFailed {
                        let alert = UIAlertController(title: "Network Error", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true)
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    } else if error as! WeatherError == WeatherError.responseError {
                        let alert = UIAlertController(title: "Error: City not found", message: "Try again", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true)
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    } else {
                        let alert = UIAlertController(title: "Unknown Error", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true)
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                case .failure:
                    break
                }
            }
        }
    }
    
    func getWeatherInformation(with coordinates: [String: String]) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        restManager.getWeatherData(with: coordinates) { [weak self] (result) in /// using weak on self to avoid retain cycle (updateView(:), addLocation(_))
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let weatherData):
                    self.updateView(with: weatherData)
                    self.delegate?.addLocation(weatherData.city, coordinates)
                case .failure(let error):
                    if error as! WeatherError == WeatherError.requestFailed {
                        let alert = UIAlertController(title: "Network Error", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true)
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    } else {
                        let alert = UIAlertController(title: "Unknown Error", message: nil, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true)
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
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
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                case .failure:
                    break
                }
            }
        }
    }
    
    @objc func onPan(_ panGesture: UIPanGestureRecognizer) {
        func slideViewVerticallyTo(_ y: CGFloat) {
            self.view.frame.origin = CGPoint(x: 0, y: UIApplication.shared.statusBarFrame.height + y)
        }
        
        switch panGesture.state {
            
        case .began, .changed:
            // If pan started or is ongoing then
            // slide the view to follow the finger
            let translation = panGesture.translation(in: view)
            let y = max(0, translation.y)
            slideViewVerticallyTo(y)
            
        case .ended:
            // If pan ended, decide if we should close or reset the view
            // based on the final position and the speed of the gesture
            let translation = panGesture.translation(in: view)
            let velocity = panGesture.velocity(in: view)
            let closing = (translation.y > self.view.frame.size.height * minimumScreenRatioToHide) || (velocity.y > minimumVelocityToHide)
            
            if closing {
                UIView.animate(withDuration: animationDuration, animations: {
                    // If closing, animate to the bottom of the view
                    slideViewVerticallyTo(self.view.frame.size.height)
                }, completion: { (isCompleted) in
                    if isCompleted {
                        // Dismiss the view when it dissapeared
                        self.dismiss(animated: false, completion: nil)
                    }
                })
            } else {
                // If not closing, reset the view to the top
                UIView.animate(withDuration: animationDuration, animations: {
                    slideViewVerticallyTo(0)
                })
            }
            
        default:
            // If gesture state is undefined, reset the view to the top
            UIView.animate(withDuration: animationDuration, animations: {
                slideViewVerticallyTo(0)
            })
            
        }
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
        let hour = Int(weatherItem.date.components(separatedBy: " ")[1].components(separatedBy: ":")[0])
        
        cell.hourLabel.text = "\(hour!)"
        cell.degreeLabel.text = "\(weatherItem.temperature)°"
        
        let icons = weatherItem.getIconNameFromWeatherID(id: weatherItem.weatherId)
        cell.updateUIAccordingTo(backgroundPicture: imageName, with: icons)
        
        return cell
    }
    
}
