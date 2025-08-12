//
//  NetworkImpl.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import UIKit

final class NetworkImpl {
    
    enum Constants {
        static let baseURL = "api.openweathermap.org"
        static let apiKey = "45a433c3e719a4d364e7009c8895843a"
    }
    
    enum ApiMethod: String {
        case get = "GET"
    }
    
    enum Units: String {
        case metrics = "metric"
    }
    
    enum EndPoint {
        case oneCall(lat: Double, lon: Double, units: Units = .metrics)
        
        var method: ApiMethod {
            return .get
        }
        var scheme: String { "https" }
        var host: String { Constants.baseURL }
        var path: String {
            switch self {
            case .oneCall:
                return "/data/3.0/onecall"
            }
        }
        
        var queryItems: [URLQueryItem] {
            switch self {
            case .oneCall(let lat, let lon, let units):
                var items = [
                    URLQueryItem(name: "lat", value: "\(lat)"),
                    URLQueryItem(name: "lon", value: "\(lon)"),
                    URLQueryItem(name: "units", value: units.rawValue),
                    URLQueryItem(name: "appid", value: Constants.apiKey)
                ]
              
                return items
            }
        }
    }
    
    func request<T: Decodable>(endPoint: EndPoint, completion: @escaping (Result<T, NetworkError>) -> Void) {
        guard let urlRequest = createRequest(endPoint: endPoint) else {
            return completion(.failure(.invalidURL))
        }
        request(urlRequest: urlRequest, completion: completion)
    }
}

private extension NetworkImpl {
    
    func request<T: Decodable>(urlRequest: URLRequest, completion: @escaping (Result<T, NetworkError>) -> Void) {
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
            }
        }
    }
    
    func createRequest(endPoint: EndPoint) -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = endPoint.scheme
        urlComponents.host = endPoint.host
        urlComponents.path = endPoint.path
        urlComponents.queryItems = endPoint.queryItems
        
        guard let url = urlComponents.url else { return nil }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endPoint.method.rawValue
        return urlRequest
    }
}
