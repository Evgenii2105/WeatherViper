//
//  Clouds.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import Foundation

struct Clouds: Decodable {
    let all: Double
    
    enum CodingKeys: String, CodingKey {
        case all = "all"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.all = try container.decode(Double.self, forKey: .all)
    }
}
