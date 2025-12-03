//
//  DataManager.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 13.08.2025.
//

import CoreLocation

protocol DataManagerService: AnyObject {
    func getCurrentCity(
        coordinate: CLLocationCoordinate2D,
        weatherCityResult: @escaping (
            Result<[WeatherListItem], NetworkError>
        ) -> Void
    )
    func getDecoderCoordinate(
        nameCity: String,
        cityResult: @escaping (
            Result<[DecoderCoord], NetworkError>
        ) -> Void
    )
    func getWeatherFiveDays(
        coordinate: CLLocationCoordinate2D,
        fiveWeatherResult: @escaping (
            Result<MainFiveWeatherResponse, NetworkError>
        ) -> Void
    )
}

final class DataManagerServiceImpl: DataManagerService {
    
    private let client = NetworkImpl()
    
    func getCurrentCity(
        coordinate: CLLocationCoordinate2D,
        weatherCityResult: @escaping (
            Result<[WeatherListItem], NetworkError>
        ) -> Void
    ) {
        client.request(
            endPoint: .currentWeather(
                lat: coordinate.latitude,
                lon: coordinate.longitude,
                units: .mertic
            )
        ) { (result: Result<WeatherResponse, NetworkError>) in
            switch result {
            case .success(let wetherResponse):
                weatherCityResult(.success([wetherResponse.mapToItem()]))
            case .failure(let error):
                weatherCityResult(.failure(NetworkError.decodingFailed(error)))
            }
        }
    }
    
    func getDecoderCoordinate(
        nameCity: String,
        cityResult: @escaping (
            Result<[DecoderCoord], NetworkError>
        ) -> Void
    ) {
        print("в дата манагере \(nameCity)")
        client.request(
            endPoint: .geocoding(
                cityName: nameCity
            )
        ) { (result: Result<[DecoderCoord], NetworkError>) in
            switch result {
            case .success(let coordinate):
                cityResult(.success(coordinate))
            case .failure(let failure):
                cityResult(.failure(.decodingFailed(failure)))
            }
        }
    }
    
    func getWeatherFiveDays(
        coordinate: CLLocationCoordinate2D,
        fiveWeatherResult: @escaping (
            Result<MainFiveWeatherResponse, NetworkError>
        ) -> Void
    ) {
        client.request(
            endPoint: .fiveDayWeather(
                lat: coordinate.latitude,
                lon: coordinate.longitude,
                units: .mertic
            )
        ) { (result: Result<MainFiveWeatherResponse, NetworkError>) in
            switch result {
            case .success(let weatherResponse):
                fiveWeatherResult(.success(weatherResponse))
            case .failure(let error):
                fiveWeatherResult(.failure(.requestFailed(error.localizedDescription)))
            }
        }
    }
}
