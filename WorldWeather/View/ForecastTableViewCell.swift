//
//  ForecastTableViewCell.swift
//  WorldWeather
//
//  Created by Gyorgy Borz on 2019. 08. 01..
//  Copyright © 2019. Gyorgy Borz. All rights reserved.
//

import UIKit

class ForecastTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var hottestLabel: UILabel!
    @IBOutlet weak var coldestLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        weatherImageView.backgroundColor = .blue
    }

}
