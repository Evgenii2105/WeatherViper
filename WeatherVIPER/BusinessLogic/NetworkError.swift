//
//  NetworkError.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed(String)
    case noData
    case decodingFailed(Error)
}
