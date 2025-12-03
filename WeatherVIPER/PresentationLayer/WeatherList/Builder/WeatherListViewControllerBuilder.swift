//
//  WeatherListViewControllerBuilder.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import UIKit

final class WeatherListViewControllerBuilder {
    
    static func build() -> UIViewController {
        let view = WeatherListViewController()
        let router = WeatherListRouterImpl()
        let citiesStorage = CityStorageImpl()
        let alert = AlertFactoryServiceImpl()
        let interactor = WeatherListInteractorImpl(
            alertFactory: alert,
            citiesStorage: citiesStorage,
            router: router
        )
        let presenter = WeatherListPresenterImpl(interactor: interactor)
        
        view.presenter = presenter
        presenter.view = view
        interactor.presenter = presenter
        router.viewController = view
        
        return view
    }
}
