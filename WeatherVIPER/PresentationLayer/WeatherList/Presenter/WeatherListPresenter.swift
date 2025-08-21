//
//  WeatherListPresenter.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import UIKit

protocol WeatherListPresenter: AnyObject {
    func searchCity(_ text: String)
    func setupDataSource()
    func showDetailsCityWeather(city: WeatherListItem)
    func showMap()
}

protocol WeatherListPresenterOutput: AnyObject {
    func didCityWeather(city: [WeatherListItem])
    func hideLoadingIndicator()
    func showLoadingIndicator()
}
