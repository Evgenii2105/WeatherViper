//
//  WeatherDetailsInteractor.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import Foundation

protocol WeatherDetailsInteractor: AnyObject {
    func setupDataSource(state layout: WeatherDetailsViewController.StateLayout)
}
