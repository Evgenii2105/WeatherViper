//
//  DataManager.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 13.08.2025.
//

import CoreLocation

protocol DataManagerService: AnyObject {
    func getCurrentCity(coordinate: CLLocationCoordinate2D, weatherCityResult: @escaping (Result<[WeatherListItem], NetworkError>) -> Void)
    
}

final class DataManagerServiceImpl: DataManagerService {
    
    private let client = NetworkImpl()
    
    func getCurrentCity(coordinate: CLLocationCoordinate2D, weatherCityResult: @escaping (Result<[WeatherListItem], NetworkError>) -> Void) {
        client.request(endPoint: .currentWeather(lat: coordinate.latitude, lon: coordinate.longitude, units: .mertic)) { (result: Result<WeatherResponse, NetworkError>) in
            switch result {
            case .success(let wetherResponse):
                weatherCityResult(.success([wetherResponse.mapToItem()]))
            case .failure(let error):
                weatherCityResult(.failure(NetworkError.decodingFailed(error)))
            }
        }
    }
}
