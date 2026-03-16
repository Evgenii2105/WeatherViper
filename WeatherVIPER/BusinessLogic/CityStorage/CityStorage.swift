//
//  CityStorage.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.11.2025.
//

import Foundation
import UIKit

protocol CityStorage: AnyObject {
    func saveCities(cities: [WeatherList.WeatherListItem])
    func getCities() -> [WeatherList.WeatherListItem]
}

final class CityStorageImpl: CityStorage {
    
    private let userDefaults = UserDefaults.standard
    private let citiesKey = "cities"
    
    func saveCities(cities: [WeatherList.WeatherListItem]) {
            let citiesData = cities.map { city in
                var imageData: Data?
                var imageURLString = ""
                
                switch city.imageContainer {
                case .imageURL(let url):
                    imageURLString = url.absoluteString
                case .image(let image, let url):
                    imageURLString = url.absoluteString
                    // Конвертируем UIImage в Data
                    imageData = image.pngData()
                }
                
                var cityDict = [
                    "id": city.id,
                    "name": city.name,
                    "currentTemp": city.currentTemp,
                    "maxTemp": city.maxTemp,
                    "minTemp": city.minTemp,
                    "precipitation": city.precipitation,
                    "imageURL": imageURLString,
                    "isFavorites": city.isFavorites
                ]
                if let imageData {
                    cityDict["imageData"] = imageData
                }
                
                return cityDict
            }
            userDefaults.set(citiesData, forKey: self.citiesKey)
        }
        
        func getCities() -> [WeatherList.WeatherListItem] {
            guard let citiesData = userDefaults.array(forKey: citiesKey) as? [[String: Any]] else {
                return []
            }
            
            return citiesData.compactMap { dict in
                guard let id = dict["id"] as? Int,
                      let name = dict["name"] as? String,
                      let currentTemp = dict["currentTemp"] as? Double,
                      let maxTemp = dict["maxTemp"] as? Double,
                      let minTemp = dict["minTemp"] as? Double,
                      let precipitation = dict["precipitation"] as? String,
                      let isFavorites = dict["isFavorites"] as? Bool,
                      let imageURLString = dict["imageURL"] as? String,
                      let imageURL = URL(string: imageURLString) else {
                    return nil
                }
                
                let imageContainer: WeatherList.WeatherListItem.ImageContainer
                
                if let imageData = dict["imageData"] as? Data,
                   let image = UIImage(data: imageData) {
                    imageContainer = .image(image: image, url: imageURL)
                } else {
                    imageContainer = .imageURL(url: imageURL)
                }
                
                return WeatherList.WeatherListItem(
                    id: id,
                    name: name,
                    currentTemp: currentTemp,
                    minTemp: minTemp,
                    maxTemp: maxTemp,
                    precipitation: precipitation,
                    isFavorites: isFavorites,
                    imageContainer: imageContainer
                )
            }
        }
}
