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
            
            func hash(into hasher: inout Hasher) {
                switch self {
                case .imageURL(let url):
                    // hasher.combine(0)
                    hasher.combine(url)
                case .image(let image, let url):
                    // hasher.combine(1)
                    hasher.combine(url)
                }
            }
            
            static func ==(lhs: ImageContainer, rhs: ImageContainer) -> Bool {
                switch (lhs, rhs) {
                case (.imageURL(let lhsUrl), .imageURL(url: let rhsUrl)):
                    return lhsUrl == rhsUrl
                case (.image(_, let lhsUrl), .image(image: _, let rhsUrl)):
                    return lhsUrl == rhsUrl
                default:
                    return false
                }
            }
        }
        
        let ids: String = UUID().uuidString
        let id: Int
        let name: String
        let currentTemp: Double
        let minTemp: Double
        let maxTemp: Double
        let precipitation: String
        let isFavorites: Bool
        var imageContainer: ImageContainer
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(ids)
            hasher.combine(id)
            hasher.combine(name)
            hasher.combine(currentTemp)
            hasher.combine(minTemp)
            hasher.combine(maxTemp)
            hasher.combine(precipitation)
            hasher.combine(isFavorites)
            hasher.combine(imageContainer)
            print(hasher.finalize())
        }
        
        static func ==(lhs: WeatherListItem, rhs: WeatherListItem) -> Bool {
            return lhs.ids == rhs.ids &&
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
                if let imageUrl = self.weather.first?.iconURL {
                    return .imageURL(url: imageUrl)
                } else {
                    let image = UIImage(systemName: "photo") ?? UIImage()
                    let url = URL(string: "")!
                    return .image(image: image, url: url)
                }
            }(),
        )
    }
}
