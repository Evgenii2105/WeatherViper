//
//  WeatherSections.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 03.12.2025.
//

import UIKit

enum WeatherList {
    
    enum Section: Hashable, CaseIterable {
        case current
        case favourites
        case positive
        case negative
    }
    
    struct WeatherListItem: Hashable {
        
        enum ImageContainer: Equatable, Hashable {
            case imageURL(url: URL)
            case image(image: UIImage, url: URL)
            
            var url: URL {
                switch self {
                case let .imageURL(url),
                    let .image(_, url):
                    return url
                }
            }
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case let .imageURL(url),
                    let .image(_, url):
                    hasher.combine(url)
                }
            }
            
            static func ==(lhs: ImageContainer, rhs: ImageContainer) -> Bool {
                switch (lhs, rhs) {
                case let (.imageURL(lhsUrl), .imageURL(rhsUrl)),
                    let (.image(_, lhsUrl), .image(image: _, rhsUrl)):
                    return lhsUrl == rhsUrl
                default:
                    return false
                }
            }
        }
        
        let id: Int
        let name: String
        let currentTemp: Double
        let minTemp: Double
        let maxTemp: Double
        let precipitation: String
        let isFavorites: Bool
        var imageContainer: ImageContainer
        
        func hash(into hasher: inout Hasher) {
            // hasher.combine(ids)
            hasher.combine(id)
            hasher.combine(name)
            hasher.combine(currentTemp)
            hasher.combine(minTemp)
            hasher.combine(maxTemp)
            hasher.combine(precipitation)
            hasher.combine(isFavorites)
            hasher.combine(imageContainer)
            // print(hasher.finalize())
        }
        
        static func ==(lhs: WeatherListItem, rhs: WeatherListItem) -> Bool {
            // lhs.ids == rhs.ids &&
            lhs.id == rhs.id &&
            lhs.name == rhs.name &&
            lhs.currentTemp == rhs.currentTemp &&
            lhs.minTemp == rhs.minTemp &&
            lhs.maxTemp == rhs.maxTemp &&
            lhs.precipitation == rhs.precipitation &&
            lhs.isFavorites == rhs.isFavorites &&
            lhs.imageContainer == rhs.imageContainer
           
        }
    }
    
    struct SectionData {
        let section: Section
        let items: [WeatherListItem]
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
            isFavorites: false,
            imageContainer: {
                guard let imageUrl = self.weather.first?.iconURL else {
                    assertionFailure("Отсутствуют данные о погоде")
                    // Какой-нибудь плейсхолдерный урл, но лучше добавить отдельный кейс
                    return .imageURL(url: URL(string: "https://openweathermap.org/img/wn/04n@4x.png")!)
                }
                return .imageURL(url: imageUrl)
            }()
        )
    }
}
