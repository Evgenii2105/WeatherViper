//
//  WeatherListView.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import Foundation

protocol WeatherListView: AnyObject {
    func didCityWeather(city: [WeatherListItem])
    func hideLoadingIndicator()
    func showLoadingIndicator()
}
