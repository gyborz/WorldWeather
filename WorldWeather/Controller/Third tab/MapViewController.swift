//
//  MapViewController.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 08. 08..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    // MARK: - Constants, variables
    
    private let locationManager = CLLocationManager()
    private let geoCoder = CLGeocoder()
    private let regionInMeters: Double = 10000
    private var coordinates = [String: String]()
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var getWeatherButton: UIButton!
    
    // MARK: - View Handling
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()

        setupMapView()
        
        setupLocationManager()
    }
    
    // we hide the get weather button and add cornerradius to it
    private func setupUI() {
        getWeatherButton.isHidden = true
        getWeatherButton.layer.cornerRadius = 15
    }
    
    // we set up the mapView's delegate and add a long press gesture to it
    private func setupMapView() {
        mapView.delegate = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(revealRegionDetailsWithLongPressOnMap(sender:)))
        longPress.minimumPressDuration = 0.5
        longPress.delaysTouchesBegan = true
        longPress.delegate = self
        mapView.addGestureRecognizer(longPress)
    }
    
    // MARK: - Location Services
    
    // we check if the location services are enabled on the device, otherwise show an error
    private func setupLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            checkLocationAuthorization()
        } else {
            let alert = UIAlertController(title: "Location services are disabled", message: "Go to Settings > Privacy > Location Services to turn it on", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    // we check the authorization of the app, show error or request authorization if needed
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
        case .denied:
            let alert = UIAlertController(title: "The app is denied to use location services", message: "Go to Settings > Privacy > Location Services to turn it on", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            let alert = UIAlertController(title: "Active restrictions block the app to use location services", message: "Check your parental controls to give access", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        case .authorizedAlways:
            /// won't happen
            break
        @unknown default:
            let alert = UIAlertController(title: "Unknown error", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    // if we have the coordinates, then we can center the view and zoom in on the user
    private func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    // MARK: - Long Press Gesture
    
    // we get the long pressed location's coordinates and center the view on it, zoom in if needed
    // we get the location's name, then we add an annotation on the map with the name as it's title
    // we make the get weather button to appear
    @objc func revealRegionDetailsWithLongPressOnMap(sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizer.State.began { return }
        
        let touchLocation = sender.location(in: mapView)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        coordinates = ["lat": String(locationCoordinate.latitude), "lon": String(locationCoordinate.longitude)]

        centerViewOnTappedLocation(locationCoordinate)
        
        let location = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
        geoCoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if error != nil {
                let alert = UIAlertController(title: "Error", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            
            guard let placemark = placemarks?.first else { return }
            
            let cityName = placemark.locality ?? ""
            DispatchQueue.main.async {
                self.addAnnotationOnLocation(pointedCoordinate: locationCoordinate, with: cityName)
                self.getWeatherButton.isHidden = false
            }
        }
    }
    
    // we center the view on the long pressed location
    // we zoom in if the map is zoomed out
    private func centerViewOnTappedLocation(_ location: CLLocationCoordinate2D) {
        if mapView.visibleMapRect.width > 99000 {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        } else {
            mapView.setCenter(location, animated: true)
        }
    }
    
    // we add an annotation to the map on the location and add a title to it
    private func addAnnotationOnLocation(pointedCoordinate: CLLocationCoordinate2D, with title: String) {
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = pointedCoordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
    
    // MARK: - Supporting Methods
    
    // if the user taps on the visible get weather button, we segue to the GetWeatherViewC and get the location's weather
    // we also set the second tab as the GetWeatherViewC's delegate so it can save the location's name and coordinates
    // (searchLocationViewC - mark: - previouslocation delegate method)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GetWeatherFromMapSegue" {
            let destinationVC = segue.destination as! GetWeatherViewController
            let secondTab = tabBarController?.customizableViewControllers![1]
            destinationVC.delegate = secondTab as? PreviousLocationDelegate
            destinationVC.getWeatherInformation(with: coordinates)
        }
    }
    
    // we go through the gesture recognizers to determine whether this region change is from user interaction
    private func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = mapView.subviews[0]
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if recognizer.state == UIGestureRecognizer.State.began || recognizer.state == UIGestureRecognizer.State.ended {
                    return true
                }
            }
        }
        return false
    }
    
    // MARK: - Search Button Method
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true)
    }
    
}

// MARK: - CLLocationManager Delegate Methods

extension MapViewController: CLLocationManagerDelegate {
    
    // we re-check the authorization when it's changed
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()        /// mark: - location services
    }
    
}

// MARK: - UISearchBar Delegate Methods

extension MapViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // we ignore the user
        view.isUserInteractionEnabled = false
        
        // we show an activity indicator
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.color = .gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()

        self.view.addSubview(activityIndicator)
        
        // we hide the search bar and the getWeatherButton
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        getWeatherButton.isHidden = true
        
        // we create a search request
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        // we stop the indicator and stop ingoring the user, if something fails we show an error
        // we get the location and the location's name from the response
        // then we center the view on the location and add an annotation to it
        activeSearch.start { [weak self] (response, error) in
            guard let self = self else { return }
            
            activityIndicator.stopAnimating()
            self.view.isUserInteractionEnabled = true
            
            if error != nil {
                let alert = UIAlertController(title: "Error", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            
            guard let response = response else { return }
            
            let latitude = response.boundingRegion.center.latitude
            let longitude = response.boundingRegion.center.longitude
            let locationCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            self.coordinates = ["lat": String(latitude), "lon": String(longitude)]
            let cityName = response.mapItems.first?.placemark.locality ?? ""
            DispatchQueue.main.async {
                self.centerViewOnTappedLocation(locationCoordinate)
                self.addAnnotationOnLocation(pointedCoordinate: locationCoordinate, with: cityName)
            }
            
        }
    }
    
}

// MARK: - MKMapView Delegate Methods

extension MapViewController: MKMapViewDelegate {
    
    // if the region changes we hide the get weather button
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if mapViewRegionDidChangeFromUserInteraction() {
            getWeatherButton.isHidden = true
        }
    }
    
    // if the user selects it's own location on the map, then we don't want the button to appear
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        getWeatherButton.isHidden = view.annotation?.title == "My Location" ? true : false
    }
    
}

// MARK: - UIGestureRecognizerDelegate Methods

extension MapViewController: UIGestureRecognizerDelegate {}

