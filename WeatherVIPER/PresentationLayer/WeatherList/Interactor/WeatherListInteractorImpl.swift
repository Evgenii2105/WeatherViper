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
    
    private static let cache = NSCache<NSURL, UIImage>()
    weak var presenter: WeatherListPresenterOutput?
    private let router: WeatherListRouter
    private let dataManager: DataManagerService = DataManagerServiceImpl()
    private var cachedCities: [WeatherList.WeatherListItem] = []
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
        
        self.cachedCities = self.citiesStorage.getCities()
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
                    case let .success(item):
                        DispatchQueue.main.async {
                            if !self.cachedCities.contains(where: { $0.id == item.id }) {
                                self.cachedCities.append(item)
                                self.citiesStorage.saveCities(cities: self.cachedCities)
                                self.sendUpdatedDataToPresenter()
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
        print(cachedCities.count)
        presenter?.showLoadingIndicator()
        guard !cachedCities.isEmpty else {
            self.sendUpdatedDataToPresenter()
            presenter?.hideLoadingIndicator()
            return
        }
        
        let group = DispatchGroup()
        var updatedItems: [WeatherList.WeatherListItem] = []
        
        for city in cachedCities {
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
                        case let .success(item):
                            let updatedItem = WeatherList.WeatherListItem(
                                id: item.id,
                                name: item.name,
                                currentTemp: item.currentTemp,
                                minTemp: item.minTemp,
                                maxTemp: item.maxTemp,
                                precipitation: item.precipitation,
                                isFavorites: city.isFavorites,
                                imageContainer: city.imageContainer
                            )
                            updatedItems.append(updatedItem)
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
            self.cachedCities = merged
            self.citiesStorage.saveCities(cities: self.cachedCities)
            self.cachedCities.forEach { city in
                guard case .imageURL = city.imageContainer else { return }
                self.downloadImage(for: city.id)
            }
            self.sendUpdatedDataToPresenter()
            self.presenter?.hideLoadingIndicator()
        }
    }
    
    func showDetailsCityWeather(city: WeatherList.WeatherListItem) {
        router.showDetailsCityWeather(city: city)
    }
    
    func remove(at index: Int) {
        self.cachedCities.removeAll(where: { $0.id == index })
        self.citiesStorage.saveCities(cities: self.cachedCities)
        self.sendUpdatedDataToPresenter()
    }
    
    func changeFlag(isFavorite: Bool, cityId: Int) {
        if let index = cachedCities.firstIndex(where: { $0.id == cityId }) {
            let city = cachedCities[index]
            
            let updateCity = WeatherList.WeatherListItem(
                id: city.id,
                name: city.name,
                currentTemp: city.currentTemp,
                minTemp: city.minTemp,
                maxTemp: city.maxTemp,
                precipitation: city.precipitation,
                //weatherImage: city.weatherImage,
                isFavorites: isFavorite,
                imageContainer: city.imageContainer,
               // image: city.image
            )
            cachedCities[index] = updateCity
            citiesStorage.saveCities(cities: cachedCities)
            sendUpdatedDataToPresenter()
        }
    }
    
    func downloadImage(for id: Int) {
        guard let index = cachedCities.firstIndex(where: { $0.id == id}),
              case let .imageURL(url) = cachedCities[index].imageContainer else {
            assertionFailure("Картинка уже загружена")
            return
        }
        
        dataManager.loadImage(
            from: url
        ) { [weak self] downloadedImage in
            guard let self else { return }
            guard let downloadedImage else {
                print("не получилось загрузить картинку из бека")
                return
            }
            Self.cache.setObject(downloadedImage, forKey: url as NSURL)
            self.updateImage(downloadedImage, at: index)
        }
    }
}

// MARK: - WeatherListInteractorImpl

private extension WeatherListInteractorImpl {
    
    func updateImage(_ image: UIImage, at index: Int) {
        var updatedCity = cachedCities[index]
        updatedCity.imageContainer = .image(image: image, url: updatedCity.imageContainer.url)
        
        cachedCities[index] = updatedCity
        citiesStorage.saveCities(cities: cachedCities)
        
        let sections = distributeCitiesIntoSections()
        DispatchQueue.main.async {
            self.presenter?.updateDataSource(with: sections)
        }
    }

    func sendUpdatedDataToPresenter() {
          let sections = distributeCitiesIntoSections()
          presenter?.updateUI(with: sections)
      }

     func distributeCitiesIntoSections() -> [WeatherList.SectionData] {
        var sections: [WeatherList.SectionData] = []
         
        if let currentCity = cachedCities.first(where: { $0.name == "Краснодар" }) {
            sections.append(
                .init(
                    section: .current,
                    items: [currentCity]
                )
            )
        }
        
        let favourites = cachedCities.filter({ $0.isFavorites })
        if !favourites.isEmpty {
            sections.append(
                .init(
                    section: .favourites,
                    items: favourites
                )
            )
        }
        
        let positive = cachedCities.filter{
            $0.currentTemp > 0 &&
            !$0.isFavorites &&
            $0.name != "Краснодар"
        }
        if !positive.isEmpty {
            sections.append(
                .init(
                    section: .positive,
                    items: positive
                )
            )
        }
        
        let negative = cachedCities.filter{
            $0.currentTemp <= 0 &&
            !$0.isFavorites &&
            $0.name != "Краснодар"
        }
        if !negative.isEmpty {
            sections.append(
                .init(
                    section: .negative,
                    items: negative
                )
            )
        }
        return sections
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
                case let .success(item):
                    if !self.cachedCities.contains(where: { $0.id == item.id }) {
                        self.cachedCities.append(item)
                    }
                    self.citiesStorage.saveCities(cities: self.cachedCities)
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

