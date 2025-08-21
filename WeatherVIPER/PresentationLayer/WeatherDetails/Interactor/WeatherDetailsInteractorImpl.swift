
//
//  WeatherDetailsInteractorImpl.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import UIKit

final class WeatherDetailsInteractorImpl: WeatherDetailsInteractor {
    
    weak var presenter: WeatherDetailsPresenterOutput?
    private let router: WeatherDetailsRouter
    private let city: WeatherListItem
    
    init(city: WeatherListItem, router: WeatherDetailsRouter) {
        self.city = city
        self.router = router
    }
    
    func setupDataSource() {
        presenter?.didGetWeather(city: city)
    }
}
