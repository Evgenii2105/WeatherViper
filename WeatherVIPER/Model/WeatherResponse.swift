//
//  WeatherResponse.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import Foundation

struct WeatherResponse: Decodable {
    let lon: Double
    let lat: Double
    let weather: [Weather]
    let base: String
    let main: Main
    let wind: Wind
    let clouds: Clouds
    let sys: Sys
    let timeZone: Int
    let id: Int
    let name: String
    let cod: Int
    
    enum CodingKeys: String, CodingKey {
        case lon = "lon"
        case lat = "lat"
        case weather = "weather"
        case base = "base"
        case main = "main"
        case wind = "wind"
        case clouds = "clouds"
        case sys = "sys"
        case timeZone = "timeZone"
        case id = "id"
        case name = "name"
        case cod = "cod"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.lon = try container.decode(Double.self, forKey: .lon)
        self.lat = try container.decode(Double.self, forKey: .lat)
        self.weather = try container.decode([Weather].self, forKey: .weather)
        self.base = try container.decode(String.self, forKey: .base)
        self.main = try container.decode(Main.self, forKey: .main)
        self.wind = try container.decode(Wind.self, forKey: .wind)
        self.clouds = try container.decode(Clouds.self, forKey: .clouds)
        self.sys = try container.decode(Sys.self, forKey: .sys)
        self.timeZone = try container.decode(Int.self, forKey: .timeZone)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.cod = try container.decode(Int.self, forKey: .cod)
    }
}
