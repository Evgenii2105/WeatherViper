//
//  Wind.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import Foundation

struct Wind: Decodable {
    
    let speed: Double
    let deg: Int
    let gust: Double
    
    enum CodingKeys: String, CodingKey {
        case speed = "speed"
        case deg = "deg"
        case gust = "gust"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.speed = try container.decode(Double.self, forKey: .speed)
        self.deg = try container.decode(Int.self, forKey: .deg)
        self.gust = try container.decode(Double.self, forKey: .gust)
    }
}
