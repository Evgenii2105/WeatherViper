//
//  WeatherListInteractor.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import Foundation

protocol WeatherListInteractor: AnyObject {
    func search(city: String)
    func setupDataSource()
    func showDetailsCityWeather(city: WeatherList.WeatherListItem)
    func showMap()
    func remove(at index: Int)
    func searchCities(for query: String) 
}
