//
//  MapView.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 20.08.2025.
//

import MapKit

protocol MapView: AnyObject {
    func addPointAnnotation(_ annotation: MKAnnotation)
    func didGetCurrentInfo(city: WeatherListItem)
}
