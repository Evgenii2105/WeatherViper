//
//  MapPresenter.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 20.08.2025.
//

import Foundation
import CoreLocation

protocol MapPresenter: AnyObject {
    func handleMapTap(with coordinates: CLLocationCoordinate2D)
    func dismissModule()
    func getCurrentInfoCity(_ coordinates: CLLocationCoordinate2D)
}

protocol MapPresenterOutput: AnyObject {
    func didGetInfoCurrentCity(city: WeatherListItem)
}
