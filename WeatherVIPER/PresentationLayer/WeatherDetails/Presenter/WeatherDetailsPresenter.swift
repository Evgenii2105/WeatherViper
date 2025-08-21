//
//  WeatherDetails.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import Foundation

protocol WeatherDetailsPresenter: AnyObject {
    func setupDataSource()
}

protocol WeatherDetailsPresenterOutput: AnyObject {
    func didGetWeather(city: WeatherListItem)
}
