//
//  MapRouterImpl.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 20.08.2025.
//

import CoreLocation
import UIKit

final class MapRouterImpl: MapRouter {
    
    weak var viewController: UIViewController?
    
    func dismissModule() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
