
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
    
    init(router: WeatherDetailsRouter) {
        self.router = router
    }
}
