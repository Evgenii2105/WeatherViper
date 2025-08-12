//
//  Sys.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import Foundation

struct Sys: Decodable {
    
    let type: Int
    let id: Int
    let country: String
    
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case id = "id"
        case country = "country"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(Int.self, forKey: .type)
        self.id = try container.decode(Int.self, forKey: .id)
        self.country = try container.decode(String.self, forKey: .country)
    }
}
