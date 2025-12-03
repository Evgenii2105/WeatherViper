//
//  NetworkImpl.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import UIKit

final class NetworkImpl {
    
    static func downloadImage(
        from url: URL,
        completion: @escaping (UIImage?) ->Void
    ) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let data = data,
                error == nil,
                let image = UIImage(data: data)
            else {
                completion(nil)
                return
            }
            completion(image)
        }.resume()
    }
    
    enum Constants {
        static let baseURL = "api.openweathermap.org"
        static let apiKey = "7bf308995030b3edd162f9c1e9948b0b" // "45a433c3e719a4d364e7009c8895843a"
      //  static let iconBaseURL = "openweathermap.org"
    }
    
    enum ApiMethod: String {
        case get = "GET"
    }
    
    enum Units: String {
        case mertic = "metric"
    }
    
    enum EndPoint {
        case currentWeather(
            lat: Double,
            lon: Double,
            units: Units = .mertic
        )
        case geocoding(cityName: String)
        case fiveDayWeather(
            lat: Double,
            lon: Double,
            units: Units = .mertic
        )
        
        var method: ApiMethod {
            return .get
        }
        var scheme: String { "https" }
        var host: String { Constants.baseURL }
        
        var path: String {
            switch self {
            case .currentWeather:
                return "/data/2.5/weather"
            case .geocoding:
                return "/geo/1.0/direct"
            case .fiveDayWeather:
                return "/data/2.5/forecast"
            }
        }
    }
    
    func request<T: Decodable>(
        endPoint: EndPoint,
        completion: @escaping (
            Result<T, NetworkError>
        ) -> Void
    ) {
        guard let urlRequest = createRequest(endPoint: endPoint) else {
            return completion(.failure(.invalidURL))
        }
        request(urlRequest: urlRequest, completion: completion)
    }
}

private extension NetworkImpl {
    
    func request<T: Decodable>(
        urlRequest: URLRequest,
        completion: @escaping (
            Result<T, NetworkError>
        ) -> Void
    ) {
        let task = URLSession.shared.dataTask(with: urlRequest) {
            data, _, error in
            guard let data else { return completion(.failure(.noData)) }
            
            let decoder = JSONDecoder()
            
            do {
                let decodedData = try decoder.decode(T.self, from: data)
                completion(.success(decodedData))
            }
            catch {
                completion(.failure(.decodingFailed(error)))
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
    
    func createRequest(endPoint: EndPoint) -> URLRequest? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = endPoint.host
        components.path = endPoint.path
        
        switch endPoint {
        case .currentWeather(
            let lat,
            let lon,
            let units
        ):
            components.queryItems = [
                URLQueryItem(name: "lat", value: "\(lat)"),
                URLQueryItem(name: "lon", value: "\(lon)"),
                URLQueryItem(name: "units", value: units.rawValue),
                URLQueryItem(name: "appid", value: Constants.apiKey),
                URLQueryItem(name: "lang", value: "ru")
            ]
        case .geocoding(let cityName):
            components.queryItems = [
                URLQueryItem(name: "q", value: cityName),
                URLQueryItem(name: "appid", value: Constants.apiKey),
                URLQueryItem(name: "limit", value: "\(1)")
            ]
            
        case .fiveDayWeather(
            lat: let lat,
            lon: let lon,
            units: let units
        ):
            components.queryItems = [
                URLQueryItem(name: "lat", value: "\(lat)"),
                URLQueryItem(name: "lon", value: "\(lon)"),
                URLQueryItem(name: "units", value: units.rawValue),
                URLQueryItem(name: "lang", value: "ru"),
                URLQueryItem(name: "appid", value: Constants.apiKey)
            ]
        }
        
        guard let url = components.url else { return nil }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endPoint.method.rawValue

        return URLRequest(url: url)
    }
}
