//
//  WeatherListView.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import Foundation
import UIKit

protocol WeatherListView: AnyObject {
    func hideLoadingIndicator()
    func showLoadingIndicator()
    func didUpdateSearchResults(_ cities: [String], countries: [String])
    func updateUI(with dataProvider: @escaping () -> [WeatherList.SectionData])
    func updateDataSource(with dataProvider: @escaping () -> [WeatherList.SectionData])
}
