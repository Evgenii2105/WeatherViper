//
//  Extension+UIView.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import UIKit

extension UIView {
    
    func addConstraints(constraints: [NSLayoutConstraint]) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(constraints)
    }
}
