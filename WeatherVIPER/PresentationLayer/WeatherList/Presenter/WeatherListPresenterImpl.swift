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
    
    func searchCity(_ text: String) {
        interactor.searchCity(text)
    }
    
    func setupDataSource() {
        interactor.setupDataSource()
    }
    
    func showDetailsCityWeather(city: WeatherListItem) {
        interactor.showDetailsCityWeather(city: city)
    }
    
    func showMap() {
        interactor.showMap()
    }
}

extension WeatherListPresenterImpl: WeatherListPresenterOutput {
   
    func didCityWeather(city: [WeatherListItem]) {
        view?.didCityWeather(city: city)
    }
    
    func hideLoadingIndicator() {
        view?.hideLoadingIndicator()
    }
    
    func showLoadingIndicator() {
        view?.showLoadingIndicator()
    }
}
