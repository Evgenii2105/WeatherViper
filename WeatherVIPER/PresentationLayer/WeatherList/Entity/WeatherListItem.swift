//
//  WeatherListItem.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import Foundation

struct WeatherListItem {
    let id: Int
    let name: String
    let currentTemp: Double
    let minTemp: Double
    let maxTemp: Double
    let precipitation: String
    let weatherImage: URL?
}

extension WeatherResponse {
    
    func mapToItem() -> WeatherListItem {
        return WeatherListItem(
            id: self.id,
            name: self.name,
            currentTemp: self.main.temp,
            minTemp: self.main.tempMIN,
            maxTemp: self.main.tempMAX,
            precipitation: self.weather.first?.description ?? "",
            weatherImage: self.weather.first?.iconURL
        )
    }
}
