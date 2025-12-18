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
    func showDetailsCityWeather(city: WeatherList.WeatherListItem)
    func showMap()
    func remove(at index: Int)
    func searchCities(for query: String)
    func changeFlag(isFavorite: Bool, cityId: Int)
}

protocol WeatherListPresenterOutput: AnyObject {
    func hideLoadingIndicator()
    func showLoadingIndicator()
    func didUpdateSearchResults(_ cities: [String], countries: [String])
    // func didSectionsCityWeather(sections: [(type: WeatherList.Section, items: [WeatherList.WeatherListItem])])
    func updateUI(with sections: [WeatherList.SectionData])
}
