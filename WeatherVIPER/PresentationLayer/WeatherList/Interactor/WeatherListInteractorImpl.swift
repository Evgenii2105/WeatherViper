//
//  WeatherListInteractorImpl.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import CoreLocation
import UIKit

final class WeatherListInteractorImpl: WeatherListInteractor {
    
    weak var presenter: WeatherListPresenterOutput?
    private let router: WeatherListRouter
    private let dataManager: DataManagerService = DataManagerServiceImpl()
    private var cityWeather: [WeatherListItem] = []
    private let alertFactory: AlertFactoryService
    
    private let coord: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 52.08320266733969, longitude: 4.300926601176115),
        CLLocationCoordinate2D(latitude: 50.84612536613957, longitude: 4.35519670008504),
        CLLocationCoordinate2D(latitude: 49.251254788276015, longitude: 4.043144174795821)
    ]
    
    init(alertFactory: AlertFactoryService, router: WeatherListRouter) {
        self.alertFactory = alertFactory
        self.router = router
    }
    
    func searchCity(_ text: String) {
        print("Идет поиск")
    }
    
    func showMap() {
        router.showMap(listiner: self)
    }
    
    // решить проблему множества вызовов
    // передача данных разом всех
    
    func setupDataSource() {
        presenter?.showLoadingIndicator()
        
        let group = DispatchGroup()
        var results: [Result<[WeatherListItem], NetworkError>] = []
        
        for coord in coord {
            group.enter()
            dataManager.getCurrentCity(
                coordinate: coord
            ) { result in
                DispatchQueue.main.async(flags: .barrier) {
                    results.append(result)
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            var allWeather: [WeatherListItem] = []
            var netWorkError: NetworkError?
            
            for result in results {
                switch result {
                case .success(let Items):
                    allWeather.append(contentsOf: Items)
                    self.cityWeather = allWeather
                case .failure(let error):
                    netWorkError = error
                    print(error)
                    let alert = self.alertFactory.showNetworkError(
                        message: "Ошибка") {
                            print("Отмена")
                        } repeatHadler: {
                            self.setupDataSource()
                        }
                    self.router.showError(alert: alert)
                }
            }
            self.presenter?.didCityWeather(city: cityWeather)
            self.presenter?.hideLoadingIndicator()
        }
    }
    
    func showDetailsCityWeather(city: WeatherListItem) {
        router.showDetailsCityWeather(city: city)
    }
}

// MARK: - MapListener

extension WeatherListInteractorImpl: MapListener {
    
    func didCoordinate(with coordinates: CLLocationCoordinate2D) {
        dataManager.getCurrentCity(
            coordinate: coordinates
        ) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success(let weatherCity):
                    self.cityWeather.append(contentsOf: weatherCity)
                    self.presenter?.didCityWeather(city: self.cityWeather)
                case .failure(let error):
                    let alert = self.alertFactory.showNetworkError(
                        message: "Ошибка") {
                            print("Отмена")
                        } repeatHadler: {
                            self.setupDataSource()
                        }
                    self.router.showError(alert: alert)
                    self.presenter?.hideLoadingIndicator()
                }
            }
        }
    }
}
