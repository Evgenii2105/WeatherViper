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
    private var cityWeather: [WeatherList.WeatherListItem] = []
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
                                    self.sendUpdatedDataToPresenter()
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
       // print("Идет поиск")
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
        print(cityWeather.count)
        presenter?.showLoadingIndicator()
        guard !cityWeather.isEmpty else {
            self.sendUpdatedDataToPresenter()
            presenter?.hideLoadingIndicator()
            return
        }
        
        let group = DispatchGroup()
        var updatedItems: [WeatherList.WeatherListItem] = []
        
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
                    self.dataManager.getCurrentCity(
                        coordinate: coord
                    ) { weatherResult in
                        switch weatherResult {
                        case .success(let items):
                            if let item = items.first {
                                let updatedItem = WeatherList.WeatherListItem(
                                    id: item.id,
                                    name: item.name,
                                    currentTemp: item.currentTemp,
                                    minTemp: item.minTemp,
                                    maxTemp: item.maxTemp,
                                    precipitation: item.precipitation,
                                    weatherImage: item.weatherImage,
                                    isFavorites: city.isFavorites
                                )
                                updatedItems.append(updatedItem)
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
            self.sendUpdatedDataToPresenter()
            self.presenter?.hideLoadingIndicator()
        }
    }
    
    func showDetailsCityWeather(city: WeatherList.WeatherListItem) {
        router.showDetailsCityWeather(city: city)
    }
    
    func remove(at index: Int) {
        self.cityWeather.removeAll(where: { $0.id == index })
        self.citiesStorage.saveCities(cities: self.cityWeather)
        self.sendUpdatedDataToPresenter()
    }
    
    func changeFlag(isFavorite: Bool, cityId: Int) {
        if let index = cityWeather.firstIndex(where: { $0.id == cityId }) {
            let city = cityWeather[index]
            
            let updateCity = WeatherList.WeatherListItem(
                id: city.id,
                name: city.name,
                currentTemp: city.currentTemp,
                minTemp: city.minTemp,
                maxTemp: city.maxTemp,
                precipitation: city.precipitation,
                weatherImage: city.weatherImage,
                isFavorites: isFavorite
            )
            cityWeather[index] = updateCity
            citiesStorage.saveCities(cities: cityWeather)
            sendUpdatedDataToPresenter()
        }
    }
}

// MARK: - WeatherListInteractorImpl

private extension WeatherListInteractorImpl {
    
    func sendUpdatedDataToPresenter() {
        var sections: [(type: WeatherList.Section, items: [WeatherList.WeatherListItem])] = []
        
        if let currentCity = cityWeather.first(where: { $0.name == "Краснодар" }) {
            sections.append((.current, [currentCity]))
        }
        
        let favourites = cityWeather.filter({ $0.isFavorites })
        if !favourites.isEmpty {
            sections.append((.favourites, favourites))
        }
        
        let positive = cityWeather.filter{
            $0.currentTemp > 0 &&
            !$0.isFavorites &&
            $0.name != "Краснодар"
        }
        if !positive.isEmpty {
            sections.append((.positive, positive))
        }
        
        let negative = cityWeather.filter{
            $0.currentTemp <= 0 &&
            !$0.isFavorites &&
            $0.name != "Краснодар"
        }
        if !negative.isEmpty {
            sections.append((.negative, negative))
        }
        presenter?.didSectionsCityWeather(sections: sections)
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
                    for newCity in weatherCity {
                        if !self.cityWeather.contains(where: { $0.id == newCity.id }) {
                            self.cityWeather.append(newCity)
                        }
                    }
                    self.citiesStorage.saveCities(cities: self.cityWeather)
                    self.sendUpdatedDataToPresenter()
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
