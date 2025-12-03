//
//  WeatherFiveDays.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 17.11.2025.
//

import Foundation

struct MainFiveWeatherResponse: Decodable {
    let list: [WeatherFiveDaysResponse]
    
    enum CodingKeys: String, CodingKey {
        case list = "list"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.list = try container.decode([WeatherFiveDaysResponse].self, forKey: .list)
    }
}

struct WeatherFiveDaysResponse: Decodable {
    let main: MainFiveDays
    let weather: [FiveWeatherDescription]
    let wind: WindFiveDay
    let date: String
    
    enum CodingKeys: String, CodingKey {
        case main = "main"
        case weather = "weather"
        case wind = "wind"
        case date = "dt_txt"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.main = try container.decode(MainFiveDays.self, forKey: .main)
        self.weather = try container.decode([FiveWeatherDescription].self, forKey: .weather)
        self.wind = try container.decode(WindFiveDay.self, forKey: .wind)
        self.date = try container.decode(String.self, forKey: .date)
    }
}

struct MainFiveDays: Decodable {
    let temp: Double
//    let tempMin: Double
//    let tempMax: Double
    
    enum CodingKeys: String, CodingKey {
        case temp = "temp"
//        case tempMin = "temp_min"
//        case tempMax = "temp_max"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.temp = try container.decode(Double.self, forKey: .temp)
//        self.tempMin = try container.decode(Double.self, forKey: .tempMin)
//        self.tempMax = try container.decode(Double.self, forKey: .tempMax)
    }
}

struct FiveWeatherDescription: Decodable {
    let description: String
    let icon: String
    
    var iconURL: URL? {
        return URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")
    }
    
    enum CodingKeys: CodingKey {
        case description
        case icon
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.description = try container.decode(String.self, forKey: .description)
        self.icon = try container.decode(String.self, forKey: .icon)
    }
}

struct WindFiveDay: Decodable {
    let speed: Double
    
    enum CodingKeys: CodingKey {
        case speed
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.speed = try container.decode(Double.self, forKey: .speed)
    }
}
