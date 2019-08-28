//
//  GetWeatherViewController.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 08. 04..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

// MARK: - PreviousLocationDelegate

protocol PreviousLocationDelegate {
    func addLocation(_ name: String, _ coordinates: [String: String])
}

class GetWeatherViewController: UIViewController {
    
    // MARK: - Constants, variables
    
    private var forecastWeatherDataForHours = [WeatherData]()
    private var forecastWeatherDataForDays = [WeatherData]()
    private var daysData = [ForecastDayData]()
    private let restManager = RestManager()
    private var imageName = "sunny"
    var delegate: PreviousLocationDelegate?
    
    // constants for the pan gesture
    private let minimumVelocityToHide: CGFloat = 1500
    private let minimumScreenRatioToHide: CGFloat = 0.3
    private let animationDuration: TimeInterval = 0.3
    
    // MARK: - Outlets
    
    @IBOutlet weak var getWeatherView: GetWeatherView!
    @IBOutlet weak var weatherCollectionView: UICollectionView!
    @IBOutlet weak var forecastTableView: UITableView!

    // MARK: - View Handling
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // we set the view's frame every time the view appears so the 'card-like' appearance is correctly in place (so it won't glitch while dragging)
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.view.frame.origin = CGPoint(x: 0, y: UIApplication.shared.statusBarFrame.height)
    }
    
    // we set up the view and add a pan gesture to it, set the tableView and the collectionView up as needed
    // we make adjustments to the tableView depending on the screen
    private func setupUI() {
        getWeatherView.layer.cornerRadius = 10
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        getWeatherView.addGestureRecognizer(panGesture)
        getWeatherView.collectionViewIndicator.isHidden = true
        getWeatherView.tableViewIndicator.isHidden = true
        
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
    
    // MARK: - View Update
    
    // we make the activity indicators appear meanwhile we update the UI with the weather data
    // changes: update the background image, the view's labels, their colors according to the background picture
    // we save the background image's name for later use too
    private func updateView(with weatherData: WeatherData) {
        getWeatherView.collectionViewIndicator.isHidden = false
        getWeatherView.tableViewIndicator.isHidden = false
        getWeatherView.collectionViewIndicator.startAnimating()
        getWeatherView.tableViewIndicator.startAnimating()
        
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
    
    // MARK: - Data Preparing
    
    // we prepare the upcoming days' forecast data to be presentable by the tableView
    // the API gives back 40 items, but we already cut off the first 24 hours (hence the 'ForHours' and 'ForDays' array)
    // for each day we need the max. and min. temperature and the midday's weather condition
    private func loadDays() {
        daysData = []
        var idForWeatherImage = Int()
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
                
                // we check if we're at the last item and if we've got 4 days
                // because of the timezones there could be situations when we're 1 or 2 hours short of the last day's forecast
                // the last one being at 22 or at 23 hour, so we would only have 3 days of 'whole day' forecast
                // since those last 1-2 hour of forecast data doesn't make that much of a difference (in a whole day's data)
                // even if those are missing we add the forecast data as a whole day's information so we always offer a 4 day forecast
                if dayOfComparisonDate != dayOfTheNextItem || (index + 1 == forecastWeatherDataForDays.count - 1 && daysData.count != 4) {
                    let dayDate = format.date(from: dateForComparison)!
                    let forecastDay = ForecastDayData(weatherID: idForWeatherImage,
                                                      maxTemperature: maxTemp,
                                                      minTemperature: minTemp,
                                                      day: daysArray[(calendar.component(.weekday, from: dayDate) - 1)]) /// weekday - 1 to get the correct index for daysArray
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
    
    // MARK: - Data Handling Methods
    
    // we make the network indicator appear meanwhile we request the weather data
    // we request by the name when the user searched for a location on the second tab
    // we request by the coordinates when the user ask the location's weather on the third tab's map
    // either way after we get the weather data we call the delegate method which saves the location's "data"
    // to the previously searched locations (see searchLocationViewController - mark: - data preparing)
    // if something fails we show an error
    func getWeatherInformation(with text: String) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        restManager.getWeatherData(with: text) { [weak self] (result) in /// using weak on self to avoid retain cycle (updateView(:), addLocation(_))
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let weatherData):
                    self.updateView(with: weatherData)      /// mark: - view update
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
                    self.loadDays()     /// mark: - data preparing
                    self.forecastTableView.reloadData()
                    self.weatherCollectionView.reloadData()
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.getWeatherView.collectionViewIndicator.stopAnimating()
                    self.getWeatherView.tableViewIndicator.stopAnimating()
                    self.getWeatherView.collectionViewIndicator.isHidden = true
                    self.getWeatherView.tableViewIndicator.isHidden = true
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
                    self.updateView(with: weatherData)      /// mark: - view update
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
                    self.loadDays()     /// mark: - data preparing
                    self.forecastTableView.reloadData()
                    self.weatherCollectionView.reloadData()
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.getWeatherView.collectionViewIndicator.stopAnimating()
                    self.getWeatherView.tableViewIndicator.stopAnimating()
                    self.getWeatherView.collectionViewIndicator.isHidden = true
                    self.getWeatherView.tableViewIndicator.isHidden = true
                case .failure:
                    break
                }
            }
        }
    }
    
    // MARK: - Pan Gesture
    
    @objc func onPan(_ panGesture: UIPanGestureRecognizer) {
        func slideViewVerticallyTo(_ y: CGFloat) {
            self.view.frame.origin = CGPoint(x: 0, y: UIApplication.shared.statusBarFrame.height + y)
        }
        
        switch panGesture.state {
            
        case .began, .changed:
            // if the pan started or is ongoing then
            // we slide the view to follow the finger
            let translation = panGesture.translation(in: view)
            let y = max(0, translation.y)
            slideViewVerticallyTo(y)
            
        case .ended:
            // if the pan ended, we decide if we should close or reset the view
            // based on the final position and the speed of the gesture
            let translation = panGesture.translation(in: view)
            let velocity = panGesture.velocity(in: view)
            let closing = (translation.y > self.view.frame.size.height * minimumScreenRatioToHide) || (velocity.y > minimumVelocityToHide)
            
            if closing {
                UIView.animate(withDuration: animationDuration, animations: {
                    // if the user is closing, we animate the view to the bottom
                    slideViewVerticallyTo(self.view.frame.size.height)
                }, completion: { (isCompleted) in
                    if isCompleted {
                        // we dismiss the view when it disappeared
                        self.dismiss(animated: false, completion: nil)
                    }
                })
            } else {
                // if the user is not closing, we reset the view to the top
                UIView.animate(withDuration: animationDuration, animations: {
                    slideViewVerticallyTo(0)
                })
            }
            
        default:
            // if the gesture state is undefined, we reset the view to the top
            UIView.animate(withDuration: animationDuration, animations: {
                slideViewVerticallyTo(0)
            })
            
        }
    }

}

// MARK: - UITableView Delegate Methods

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

// MARK: - UICollectionView Delegate Methods

extension GetWeatherViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return forecastWeatherDataForHours.count
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
