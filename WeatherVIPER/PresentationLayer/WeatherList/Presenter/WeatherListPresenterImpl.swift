//
//  WeatherListPresenterImpl.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import UIKit

final class WeatherListPresenterImpl: WeatherListPresenter {
  
    weak var view: WeatherListView?
    private let interactor: WeatherListInteractor
    
    init(interactor: WeatherListInteractor) {
        self.interactor = interactor
    }
    
    func search(city: String) {
        print("в презентер передали поиск по городу \(city)")
        interactor.search(city: city)
    }
    
    func searchCities(for query: String) {
        print("Поиск городов для подсказок: \(query)")
        interactor.searchCities(for: query)
    }
    
    func setupDataSource() {
        interactor.setupDataSource()
    }
    
    func showDetailsCityWeather(city: WeatherList.WeatherListItem) {
        interactor.showDetailsCityWeather(city: city)
    }
    
    func showMap() {
        interactor.showMap()
    }
    
    func remove(at index: Int) {
        interactor.remove(at: index)
    }
}

// MARK: - WeatherListPresenterOutput

extension WeatherListPresenterImpl: WeatherListPresenterOutput {
    
    func didSectionsCityWeather(sections: [(type: WeatherList.Section, items: [WeatherList.WeatherListItem])]) {
        view?.didSectionsCityWeather(sections: sections)
    }

    func didCityWeather(city: [WeatherList.WeatherListItem]) {
        view?.didCityWeather(city: city)
    }
    
    func hideLoadingIndicator() {
        view?.hideLoadingIndicator()
    }
    
    func showLoadingIndicator() {
        view?.showLoadingIndicator()
    }
    
    func didUpdateSearchResults(_ cities: [String], countries: [String]) {
        view?.didUpdateSearchResults(cities, countries: countries)
    }
}
