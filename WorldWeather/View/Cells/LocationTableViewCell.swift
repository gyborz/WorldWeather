//
//  LocationTableViewCell.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 08. 05..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit
import SwipeCellKit

class LocationTableViewCell: SwipeTableViewCell {
    
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundImageView.backgroundColor = .orange
        weatherImageView.backgroundColor = .blue
    }
    
}
