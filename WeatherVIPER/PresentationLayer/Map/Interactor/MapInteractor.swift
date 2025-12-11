//
//  MapInteractor.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 20.08.2025.
//

import CoreLocation

protocol MapInteractor: AnyObject {
    func handleMapTap(with coordinates: CLLocationCoordinate2D)
    func getCurrentInfoCity(_ coordinates: CLLocationCoordinate2D)
}
