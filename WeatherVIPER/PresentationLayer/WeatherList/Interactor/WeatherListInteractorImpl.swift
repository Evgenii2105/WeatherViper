//
//  WeatherListInteractorImpl.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import UIKit

final class WeatherListInteractorImpl: WeatherListInteractor {
    
    weak var presenter: WeatherListPresenterOutput?
    private let router: WeatherListRouter
    
    init(router: WeatherListRouter) {
        self.router = router
    }
    
    func searchCity(_ text: String) {
        print("Идет поиск")
    }
}
