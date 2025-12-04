//
//  WeatherListView.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import Foundation

protocol WeatherListView: AnyObject {
    func didCityWeather(city: [WeatherList.WeatherListItem])
    func hideLoadingIndicator()
    func showLoadingIndicator()
    func didUpdateSearchResults(_ cities: [String], countries: [String])
    func didSectionsCityWeather(sections: [(type: WeatherList.Section, items: [WeatherList.WeatherListItem])])
}
