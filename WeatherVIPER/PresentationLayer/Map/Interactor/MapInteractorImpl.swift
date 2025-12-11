//
//  MapInteractorImpl.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 20.08.2025.
//

import UIKit
import MapKit

protocol MapListener: AnyObject {
    func didCoordinate(with coordinates: CLLocationCoordinate2D)
}

final class MapInteractorImpl: MapInteractor {
    
    enum Section {
        case main
    }
    
    weak var presenter: MapPresenterOutput?
    private let router: MapRouter
    weak var listener: MapListener?
    private let dataManager: DataManagerService
    
    init(
        dataManager: DataManagerServiceImpl,
        router: MapRouter,
        listener: MapListener? = nil
    ) {
        self.router = router
        self.listener = listener
        self.dataManager = dataManager
    }
    
    func handleMapTap(with coordinates: CLLocationCoordinate2D) {
        router.dismissModule()
        listener?.didCoordinate(with: coordinates)
    }
    
    func getCurrentInfoCity(_ coordinates: CLLocationCoordinate2D) {
        dataManager.getCurrentCity(
            coordinate: coordinates) { [weak self] result in
                guard let self else { return }
                switch result {
                case .success(let currentCityInfo):
                    for city in currentCityInfo {
                        DispatchQueue.main.async {
                            self.presenter?.didGetInfoCurrentCity(city: city)
                        }
                    }
                case .failure(let error):
                    print("\(error.localizedDescription)")
                }
            }
    }
}
