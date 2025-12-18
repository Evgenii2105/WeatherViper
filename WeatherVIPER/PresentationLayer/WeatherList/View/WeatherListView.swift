//
//  WeatherListView.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import Foundation

protocol WeatherListView: AnyObject {
    func hideLoadingIndicator()
    func showLoadingIndicator()
    func didUpdateSearchResults(_ cities: [String], countries: [String])
   // func didSectionsCityWeather(sections: WeatherList.SectionData)
  //  func didSectionsCityWeather(sections: [(type: WeatherList.Section, items: [WeatherList.WeatherListItem])])
    func updateUI(with dataProvider: @escaping () -> [WeatherList.SectionData])
}
