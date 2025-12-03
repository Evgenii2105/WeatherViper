
//
//  WeatherDetailsInteractorImpl.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import UIKit
import CoreLocation

enum MainData {
    case main
    
    struct Item: Hashable {
        let name: String
        let temp: Int
    }
}

final class WeatherDetailsInteractorImpl: WeatherDetailsInteractor {
    
    weak var presenter: WeatherDetailsPresenterOutput?
    private let router: WeatherDetailsRouter
    private let city: WeatherListItem
    private let dataManager: DataManagerService
    // private var citiesWeather: [MainData.Item] = []
    
    init(
        dataManager: DataManagerService,
        city: WeatherListItem,
        router: WeatherDetailsRouter
    ) {
        self.city = city
        self.router = router
        self.dataManager = dataManager
    }
    
    func setupDataSource(state layout: WeatherDetailsViewController.StateLayout) {
        self.presenter?.didGetWeather(city: self.city)
        dataManager.getDecoderCoordinate(
            nameCity: city.name
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let coordinates):
                guard let firstCoordinates = coordinates.first else {
                    print("массив координат пустой")
                    return
                }
                print("Успешно получили координаты для города: \(firstCoordinates.name)")
                self.getWeatherFiveDays(
                    coordinates: firstCoordinates,
                    state: layout
                )
            case .failure(let error):
                print("ошибка получения координат для города: \(self.city.name), ошибка: \(error.localizedDescription)")
            }
        }
    }
    
    private func getWeatherFiveDays(
        coordinates: DecoderCoord,
        state: WeatherDetailsViewController.StateLayout
    ) {
        dataManager.getWeatherFiveDays(
            coordinate: CLLocationCoordinate2D(
                latitude: coordinates.lat,
                longitude: coordinates.lon
            )
        ) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let weatherFiveDaysItem):
                let items = weatherFiveDaysItem.mapToItemFiveDays()
                DispatchQueue.main.async {
                    switch state {
                    case .firstOpening:
                        self.presenter?.didGetWeatherFiveDays(weather: items)
                    case .secondOpening:
                        self.presenter?.didGetWeatherMakeLayout(items)
                    }
                }
//                print("успешный запрос на получения погоды на 5 дней для \(weatherFiveDaysItem.list)")
            case .failure(let error):
                print("ошибка запроса на 5 дней: \(error.localizedDescription)")
            }
        }
    }
}
