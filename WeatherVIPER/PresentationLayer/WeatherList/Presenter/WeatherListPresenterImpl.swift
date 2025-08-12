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
}

extension WeatherListPresenterImpl: WeatherListPresenterOutput {
    
}
