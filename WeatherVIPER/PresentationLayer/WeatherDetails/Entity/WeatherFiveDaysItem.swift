//
//  WeatherFiveDaysItem.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 17.11.2025.
//

import Foundation

struct WeatherFiveDaysItem: Hashable {
    
    let date: String
    let icon: URL?
    let temp: Double
}

extension MainFiveWeatherResponse {

    func mapToItemFiveDays() -> [WeatherFiveDaysItem] {
        return self.list.map({ dailyWeather in
            WeatherFiveDaysItem(
                date: dailyWeather.date,
                icon: dailyWeather.weather.first?.iconURL,
                temp: dailyWeather.main.temp
            )
        })
    }
}
