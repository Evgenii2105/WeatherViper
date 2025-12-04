//
//  WeatherListRouterImpl.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import UIKit

final class WeatherListRouterImpl: WeatherListRouter {
    
    weak var viewController: UIViewController?
    
    func showDetailsCityWeather(city: WeatherList.WeatherListItem) {
        let view = WeatherDetailsViewController()
        let router = WeatherDetailsRouterImpl()
        let dataManager = DataManagerServiceImpl()
        let interactor = WeatherDetailsInteractorImpl(
            dataManager: dataManager,
            city: city,
            router: router
        )
        let presenter = WeatherDetailsPresenterImpl(interactor: interactor)
        
        view.presenter = presenter
        interactor.presenter = presenter
        presenter.view = view
        router.viewController = view
        
        viewController?.navigationController?.pushViewController(view, animated: true)
      //  viewController?.present(view, animated: true)
    }
    
    func showMap(listiner: MapListener) {
        let view = MapViewController()
        let router = MapRouterImpl()
        let dataManager = DataManagerServiceImpl()
        let interactor = MapInteractorImpl(
            dataManager: dataManager,
            router: router,
            listener: listiner
        )
        let presenter = MapPresenterImpl(interactor: interactor)
        
        view.presenter = presenter
        interactor.presenter = presenter
        presenter.view = view
        router.viewController = view
        
        viewController?.navigationController?.pushViewController(view, animated: true)
        //viewController?.present(view, animated: true)
    }
    
    func showError(alert: any AlertContentPresentable) {
        viewController?.present(alert.alert, animated: alert.isAnimated)
    }
}
