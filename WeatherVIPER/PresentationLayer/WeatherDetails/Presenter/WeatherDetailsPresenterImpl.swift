//
//  WeatherDetailsPresenterImpl.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import UIKit

final class WeatherDetailsPresenterImpl: WeatherDetailsPresenter {
    
    weak var view: WeatherDetailsView?
    private let interactor: WeatherDetailsInteractor
    
    init(interactor: WeatherDetailsInteractor) {
        self.interactor = interactor
    }
    
    func setupDataSource(state layout: WeatherDetailsViewController.StateLayout) {
        interactor.setupDataSource(state: layout)
    }
}

extension WeatherDetailsPresenterImpl: WeatherDetailsPresenterOutput {
    
    func didGetWeather(city: WeatherListItem) {
        view?.didGetWeather(city: city)
    }
    
    func didGetWeatherFiveDays(weather: [WeatherFiveDaysItem]) {
        view?.didGetWeatherFiveDays(weather: weather)
    }
    
    func didGetWeatherMakeLayout(_ weather: [WeatherFiveDaysItem]) {
        view?.updateUI { weather }
    }
}
