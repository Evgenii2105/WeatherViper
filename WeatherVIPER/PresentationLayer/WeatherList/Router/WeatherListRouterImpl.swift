//
//  WeatherListRouterImpl.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import UIKit

final class WeatherListRouterImpl: WeatherListRouter {
    
    weak var viewController: UIViewController?
    
    func showDetailsCityWeather(city: WeatherListItem) {
        let view = WeatherDetailsViewController()
        let router = WeatherDetailsRouterImpl()
        let interactor = WeatherDetailsInteractorImpl(
            city: city,
            router: router
        )
        let presenter = WeatherDetailsPresenterImpl(interactor: interactor)
        
        view.presenter = presenter
        interactor.presenter = presenter
        presenter.view = view

        viewController?.navigationController?.pushViewController(view, animated: true)
    }
    
    func showMap(listiner: MapListener) {
        let view = MapViewController()
        let router = MapRouterImpl()
        let interactor = MapInteractorImpl(router: router, listener: listiner)
        let presenter = MapPresenterImpl(interactor: interactor)
        
        view.presenter = presenter
        interactor.presenter = presenter
        presenter.view = view
        router.viewController = view
        
        viewController?.navigationController?.pushViewController(view, animated: true)
    }
    
    func showError(alert: any AlertContentPresentable) {
        viewController?.present(alert.alert, animated: alert.isAnimated)
    }
}
