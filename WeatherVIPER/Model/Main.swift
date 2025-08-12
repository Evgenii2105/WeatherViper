//
//  Main.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

struct Main: Decodable {
    let temp: Double
    let feelsLike: Double
    let tempMIN: Double
    let tempMAX: Double
    let pressure: Int
    let humidity: Int
    
    enum CodingKeys: String, CodingKey {
        case temp = "temp"
        case feelsLike = "feels_like"
        case tempMIN = "temp_min"
        case tempMAX = "temp_max"
        case pressure = "pressure"
        case humidity = "humidity"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.temp = try container.decode(Double.self, forKey: .temp)
        self.feelsLike = try container.decode(Double.self, forKey: .feelsLike)
        self.tempMIN = try container.decode(Double.self, forKey: .tempMIN)
        self.tempMAX = try container.decode(Double.self, forKey: .tempMAX)
        self.pressure = try container.decode(Int.self, forKey: .pressure)
        self.humidity = try container.decode(Int.self, forKey: .humidity)
    }
}
