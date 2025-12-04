//
//  WeatherSections.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 03.12.2025.
//

import Foundation

enum WeatherList {
    
    enum Section: Hashable {
        case current
        case favourites
        case positive
        case negative
        
        var title: String {
            switch self {
            case .current:
                return "Текущий Город"
            case .favourites:
               return "Избранное"
            case .positive:
                return "Тепленько"
            case .negative:
                return "Холод собачий"
            }
        }
    }
    
    struct WeatherListItem: Hashable {
        let id: Int
        let name: String
        let currentTemp: Double
        let minTemp: Double
        let maxTemp: Double
        let precipitation: String
        let weatherImage: URL?
        let isFavorites: Bool
    }
}

extension WeatherResponse {
    
    func mapToItem() -> WeatherList.WeatherListItem {
        return WeatherList.WeatherListItem(
            id: self.id,
            name: self.name,
            currentTemp: self.main.temp,
            minTemp: self.main.tempMIN,
            maxTemp: self.main.tempMAX,
            precipitation: self.weather.first?.description ?? "",
            weatherImage: self.weather.first?.iconURL,
            isFavorites: false
        )
    }
}
