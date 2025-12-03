//
//  WeatherDetailsView.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import Foundation

protocol WeatherDetailsView: AnyObject {
    func didGetWeather(city: WeatherListItem)
    func didGetWeatherFiveDays(weather: [WeatherFiveDaysItem])
    func updateUI(with dataProvider: @escaping () -> [WeatherFiveDaysItem])
}
