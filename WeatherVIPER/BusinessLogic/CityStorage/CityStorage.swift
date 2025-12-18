//
//  CityStorage.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.11.2025.
//

import Foundation

protocol CityStorage: AnyObject {
    func saveCities(cities: [WeatherList.WeatherListItem])
    func getCities() -> [WeatherList.WeatherListItem]
}

final class CityStorageImpl: CityStorage {
    
    private let userDefaults = UserDefaults.standard
    private let citiesKey = "cities"
    
    func saveCities(cities: [WeatherList.WeatherListItem]) {
        let citiesData = cities.map({ city in
            return [
                "id": city.id,
                "name" : city.name,
                "currentTemp" : city.currentTemp,
                "maxTemp" : city.maxTemp,
                "minTemp" : city.minTemp,
                "precipitation" : city.precipitation,
                "weatherImage" : city.weatherImage?.absoluteString ?? "",
                "isFavorites" : city.isFavorites
            ]
        })
        userDefaults.set(citiesData, forKey: self.citiesKey)
        userDefaults.synchronize()
        print("сохранено \(cities.count) городов")
    }
    
    func getCities() -> [WeatherList.WeatherListItem] {
        guard let citiesData = userDefaults.array(forKey: citiesKey) as? [[String: Any]] else {
            print("нет сохраненных городов")
            return []
        }
        
        let cities = citiesData.compactMap { dict -> WeatherList.WeatherListItem? in
            guard let id = dict["id"] as? Int,
                  let name = dict["name"] as? String,
                  let currentTemp = dict["currentTemp"] as? Double,
                  let maxTemp = dict["maxTemp"] as? Double,
                  let minTemp = dict["minTemp"] as? Double,
                  let precipitation = dict["precipitation"] as? String,
                  let isFavorites = dict["isFavorites"] as? Bool else {
                print("Ошибка получения города из UserDefaults")
                return nil
            }
            
            let weatherImageString = dict["weatherImage"] as? String
            let weatherImage = weatherImageString?.isEmpty == false ? URL(string: weatherImageString!) : nil
            
            return WeatherList.WeatherListItem(
                id: id,
                name: name,
                currentTemp: currentTemp,
                minTemp: minTemp,
                maxTemp: maxTemp,
                precipitation: precipitation,
                weatherImage: weatherImage,
                isFavorites: isFavorites,
            )
        }
        return cities
    }
}
