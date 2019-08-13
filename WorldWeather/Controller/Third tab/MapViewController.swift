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
    
    let locationManager = CLLocationManager()
    let geoCoder = CLGeocoder()
    let regionInMeters: Double = 10000
    var coordinates = [String: String]()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var getWeatherButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()

        setupMapView()
        
        setupLocationManager()
    }
    
    func setupUI() {
        getWeatherButton.isHidden = true
        
        getWeatherButton.backgroundColor = UIColor.blue.withAlphaComponent(0.1)
        getWeatherButton.layer.cornerRadius = 15
        getWeatherButton.layer.borderWidth = 1
        getWeatherButton.layer.borderColor = UIColor.blue.cgColor
    }
    
    func setupMapView() {
        mapView.delegate = self
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(revealRegionDetailsWithLongPressOnMap(sender:)))
        longPress.minimumPressDuration = 0.5
        longPress.delaysTouchesBegan = true
        longPress.delegate = self
        mapView.addGestureRecognizer(longPress)
    }
    
    func setupLocationManager() {
        /// check if location services are enabled on the device
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            checkLocationAuthorization()
        } else {
            // TODO: - alert
        }
    }
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
        case .denied:
            // TODO: - alert showing how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // TODO: - alert for restriction problem
            break
        case .authorizedAlways:
            /// won't happen
            break
        @unknown default:
            // TODO: - special alert
            break
        }
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
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
                // TODO: - alert
                return
            }
            
            guard let placemark = placemarks?.first else {
                // TODO: - alert
                return
            }
            
            let cityName = placemark.locality ?? ""
            DispatchQueue.main.async {
                self.addAnnotationOnLocation(pointedCoordinate: locationCoordinate, with: cityName)
                self.getWeatherButton.isHidden = false
            }
        }
    }
    
    func centerViewOnTappedLocation(_ location: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated: true)
    }
    
    func addAnnotationOnLocation(pointedCoordinate: CLLocationCoordinate2D, with title: String) {
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = pointedCoordinate
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
    
    private func mapViewRegionDidChangeFromUserInteraction() -> Bool {
        let view = mapView.subviews[0]
        //  Look through gesture recognizers to determine whether this region change is from user interaction
        if let gestureRecognizers = view.gestureRecognizers {
            for recognizer in gestureRecognizers {
                if recognizer.state == UIGestureRecognizer.State.began || recognizer.state == UIGestureRecognizer.State.ended {
                    return true
                }
            }
        }
        return false
    }
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GetWeatherFromMap" {
            let destinationVC = segue.destination as! GetWeatherViewController
            let secondTab = tabBarController?.customizableViewControllers![1]
            destinationVC.delegate = secondTab as? PreviousLocationDelegate
            destinationVC.getWeatherInformation(with: coordinates)
        }
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
}

extension MapViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // ignoring the user
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // activity indicator
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .whiteLarge
        activityIndicator.color = .gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()

        self.view.addSubview(activityIndicator)
        
        // hide search bar and getWeatherButton
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        getWeatherButton.isHidden = true
        
        // search request
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchBar.text
        
        let activeSearch = MKLocalSearch(request: searchRequest)
        
        activeSearch.start { [weak self] (response, error) in
            guard let self = self else { return }
            
            activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            
            if error != nil {
                // TODO: - alert
                return
            }
            
            guard let response = response else {
                // TODO: - alert
                return
            }
            
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

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if mapViewRegionDidChangeFromUserInteraction() {
            getWeatherButton.isHidden = true
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        getWeatherButton.isHidden = false
    }
    
}

extension MapViewController: UIGestureRecognizerDelegate {}

