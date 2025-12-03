//
//  WeatherDetails.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import Foundation

protocol WeatherDetailsPresenter: AnyObject {
    func setupDataSource(state layout: WeatherDetailsViewController.StateLayout)
}

protocol WeatherDetailsPresenterOutput: AnyObject {
    func didGetWeather(city: WeatherListItem)
    func didGetWeatherFiveDays(weather: [WeatherFiveDaysItem])
    func didGetWeatherMakeLayout(_ weather: [WeatherFiveDaysItem])
}
