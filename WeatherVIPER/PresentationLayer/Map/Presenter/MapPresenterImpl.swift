//
//  MapPresenterImpl.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 20.08.2025.
//

import UIKit
import MapKit

final class MapPresenterImpl: MapPresenter {
    
    weak var view: MapView?
    private let interactor: MapInteractor
    
    init(interactor: MapInteractor) {
        self.interactor = interactor
    }
    
    func handleMapTap(with coordinates: CLLocationCoordinate2D) {
        interactor.handleMapTap(with: coordinates)
    }
    
    func getCurrentInfoCity(_ coordinates: CLLocationCoordinate2D) {
        interactor.getCurrentInfoCity(coordinates)
    }
}

extension MapPresenterImpl: MapPresenterOutput {
    
    func didGetInfoCurrentCity(city: WeatherList.WeatherListItem) {
        view?.didGetCurrentInfo(city: city)
    }
}
