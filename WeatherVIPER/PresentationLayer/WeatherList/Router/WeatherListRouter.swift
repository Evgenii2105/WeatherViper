//
//  WeatherListRouter.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import Foundation

protocol WeatherListRouter: AnyObject {
    func showDetailsCityWeather(city: WeatherListItem)
    func showError(alert: AlertContentPresentable)
    func showMap(listiner: MapListener)
}
