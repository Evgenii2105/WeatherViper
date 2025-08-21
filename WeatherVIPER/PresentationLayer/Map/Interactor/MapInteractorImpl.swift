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
    
    weak var presenter: MapPresenterOutput?
    private let router: MapRouter
    weak var listener: MapListener?
    
    init(router: MapRouter, listener: MapListener? = nil) {
        self.router = router
        self.listener = listener
    }
    
    func handleMapTap(with coordinates: CLLocationCoordinate2D) {
        listener?.didCoordinate(with: coordinates)
    }
    
    func dismissModule() {
        router.dismissModule()
    }
}
