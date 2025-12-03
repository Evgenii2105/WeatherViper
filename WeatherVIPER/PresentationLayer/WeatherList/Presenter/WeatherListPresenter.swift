//
//  WeatherListPresenter.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import UIKit

protocol WeatherListPresenter: AnyObject {
    func search(city: String)
    func setupDataSource()
    func showDetailsCityWeather(city: WeatherListItem)
    func showMap()
    func remove(at index: Int)
    func searchCities(for query: String) 
}

protocol WeatherListPresenterOutput: AnyObject {
    func didCityWeather(city: [WeatherListItem])
    func hideLoadingIndicator()
    func showLoadingIndicator()
    func didUpdateSearchResults(_ cities: [String], countries: [String]) 
}
