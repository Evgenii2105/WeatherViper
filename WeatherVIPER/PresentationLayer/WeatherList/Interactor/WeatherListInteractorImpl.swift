//
//  WeatherListInteractorImpl.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import CoreLocation
import UIKit

final class WeatherListInteractorImpl: WeatherListInteractor {
    
    enum ListSection {
        case favourites
        case positive
        case negative
    }
    
    weak var presenter: WeatherListPresenterOutput?
    private let router: WeatherListRouter
    private let dataManager: DataManagerService = DataManagerServiceImpl()
    private var cityWeather: [WeatherListItem] = []
    private let alertFactory: AlertFactoryService
    private let citiesStorage: CityStorage
    
    init(
        alertFactory: AlertFactoryService,
        citiesStorage: CityStorage,
        router: WeatherListRouter,
    ) {
        self.alertFactory = alertFactory
        self.citiesStorage = citiesStorage
        self.router = router
        
        self.cityWeather = self.citiesStorage.getCities()
    }
    
    
    func search(city: String) {
        dataManager.getDecoderCoordinate(
            nameCity: city
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let coordinates):
                guard let firstCoordinates = coordinates.first else {
                    print("Нет координат для города: \(city)")
                    return
                }
                print("Координаты для \(city): \(firstCoordinates.lat), \(firstCoordinates.lon)")
                
                self.dataManager.getCurrentCity(
                    coordinate: CLLocationCoordinate2D(
                        latitude: firstCoordinates.lat,
                        longitude: firstCoordinates.lon
                    )
                ) { result in
                    switch result {
                    case .success(let weatherItems):
                        DispatchQueue.main.async {
                            if let newCity = weatherItems.first {
                                if !self.cityWeather.contains(where: { $0.id == newCity.id }) {
                                    self.cityWeather.append(newCity)
                                    self.citiesStorage.saveCities(cities: self.cityWeather)
                                    self.presenter?.didCityWeather(city: self.cityWeather)
                                }
                            }
                        }
                    case .failure(let error):
                        print("Ошибка \(error.localizedDescription)")
                    }
                }
            case .failure(let failure):
                print(failure.localizedDescription)
            }
        }
        print("Идет поиск")
    }
    
    func searchCities(for query: String) {
        dataManager.getDecoderCoordinate(
            nameCity: query
        ) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let coordinates):
                    let citiesNames = coordinates.map({ $0.name })
                    let countriesName = coordinates.map({ $0.country })
                    self?.presenter?.didUpdateSearchResults(citiesNames, countries: countriesName)
                case .failure(let error):
                    print("Ошибка \(error.localizedDescription)")
                    self?.presenter?.didUpdateSearchResults([], countries: [])
                }
            }
        }
    }
    
    func showMap() {
        router.showMap(listiner: self)
    }
    
    func setupDataSource() {
        presenter?.showLoadingIndicator()
        
        guard !cityWeather.isEmpty else {
            presenter?.didCityWeather(city: cityWeather)
            presenter?.hideLoadingIndicator()
            return
        }
        
        let group = DispatchGroup()
        var updatedItems: [WeatherListItem] = []
        
        for city in cityWeather {
            group.enter()
            dataManager.getDecoderCoordinate(
                nameCity: city.name
            ) { [weak self] result in
                guard let self else { group.leave(); return }
                switch result {
                case .success(let coordinates):
                    guard let first = coordinates.first else {
                        group.leave()
                        return
                    }
                    let coord = CLLocationCoordinate2D(latitude: first.lat, longitude: first.lon)
                    self.dataManager.getCurrentCity(coordinate: coord) { weatherResult in
                        switch weatherResult {
                        case .success(let items):
                            if let item = items.first {
                                updatedItems.append(item)
                            }
                        case .failure(let error):
                            print("Ошибка получения погоды: \(error.localizedDescription)")
                        }
                        group.leave()
                    }
                case .failure(let error):
                    print("Ошибка геокодирования: \(error.localizedDescription)")
                    group.leave()
                }
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            var seen = Set<Int>()
            let merged = updatedItems.filter { item in
                if seen.contains(item.id) { return false }
                seen.insert(item.id)
                return true
            }
            self.cityWeather = merged
            self.citiesStorage.saveCities(cities: self.cityWeather)
            self.presenter?.didCityWeather(city: self.cityWeather)
            self.presenter?.hideLoadingIndicator()
        }
    }
    
    func showDetailsCityWeather(city: WeatherListItem) {
        router.showDetailsCityWeather(city: city)
    }
    
    func remove(at index: Int) {
        self.cityWeather.remove(at: index)
        self.citiesStorage.saveCities(cities: self.cityWeather)
        presenter?.didCityWeather(city: self.cityWeather)
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
                case .failure:
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

