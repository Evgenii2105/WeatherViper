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
}
