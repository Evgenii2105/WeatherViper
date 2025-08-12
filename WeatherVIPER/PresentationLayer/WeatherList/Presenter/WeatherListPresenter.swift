//
//  WeatherListPresenter.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import UIKit

protocol WeatherListPresenter: AnyObject {
    func searchCity(_ text: String)
}

protocol WeatherListPresenterOutput: AnyObject {
    
}
