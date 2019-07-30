//
//  FirstViewController.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 07. 30..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class CurrentLocationViewController: UIViewController {
    
    @IBOutlet weak var weatherCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        weatherCollectionView.delegate = self
        weatherCollectionView.dataSource = self
        weatherCollectionView.backgroundColor = .clear
    }

}

extension CurrentLocationViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ForecastViewCell", for: indexPath) as? ForecastCollectionViewCell
        cell?.hourLabel.text = "15"
        cell?.degreeLabel.text = "31°"
        return cell!
    }
    
    
}
