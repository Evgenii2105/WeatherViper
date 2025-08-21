//
//  WeatherDetailsViewController.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import UIKit

final class WeatherDetailsViewController: UIViewController {
    
    var presenter: WeatherDetailsPresenter?
    
    private let currentWeatherContainer: UIView = {
        let container = UIView()
        container.backgroundColor = .white
        return container
    }()
    
    private let currentCity: UILabel = {
       let currentCity = UILabel()
        currentCity.font = .systemFont(ofSize: 22, weight: .bold)
        currentCity.textColor = .black
        currentCity.numberOfLines = 1
        currentCity.text = "Краснодар"
        currentCity.adjustsFontSizeToFitWidth = true
        return currentCity
    }()
    
    private let currentTemp: UILabel = {
       let currentTemp = UILabel()
        currentTemp.font = .systemFont(ofSize: 26, weight: .bold)
        currentTemp.textColor = .black
        currentTemp.text = "26"
        return currentTemp
    }()
    
    private let precipitationLabel: UILabel = {
       let precipitationLabel = UILabel()
        precipitationLabel.font = .systemFont(ofSize: 18, weight: .light)
        precipitationLabel.numberOfLines = 1
        precipitationLabel.textColor = .black
        precipitationLabel.text = "Солнечно"
        return precipitationLabel
    }()
    
    private let changeTempContainer: UIView = {
       let changeTempContainer = UIView()
        changeTempContainer.backgroundColor = .white
        return changeTempContainer
    }()
    
    private let maxTempLabel: UILabel = {
       let maxTempLabel = UILabel()
        maxTempLabel.font = .systemFont(ofSize: 16, weight: .light)
        maxTempLabel.textColor = .black
        maxTempLabel.text = "32"
        return maxTempLabel
    }()
    
    private let minTempLabel: UILabel = {
       let minTempLabel = UILabel()
        minTempLabel.font = .systemFont(ofSize: 16, weight: .light)
        minTempLabel.textColor = .black
        minTempLabel.text = "18"
        return minTempLabel
    }()
    
    private lazy var  threeDayWeatherCollection: UICollectionView = {
       let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 200, height: 200)
        layout.minimumLineSpacing = 8
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        presenter?.setupDataSource()
    }
}

// MARK: - WeatherDetailsView

extension WeatherDetailsViewController: WeatherDetailsView {
    
    func didGetWeather(city: WeatherListItem) {
        configure(city: city)
    }
}

// MARK: - Private Extension

private extension WeatherDetailsViewController {
    
    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(currentWeatherContainer)
        currentWeatherContainer.addSubview(currentCity)
        currentWeatherContainer.addSubview(currentTemp)
        currentWeatherContainer.addSubview(precipitationLabel)
        currentWeatherContainer.addSubview(changeTempContainer)
        changeTempContainer.addSubview(maxTempLabel)
        changeTempContainer.addSubview(minTempLabel)
    }
    
    func setupConstraints() {
        currentWeatherContainer.addConstraints(constraints: [
            currentWeatherContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            currentWeatherContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentWeatherContainer.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        currentCity.addConstraints(constraints: [
            currentCity.topAnchor.constraint(equalTo: currentWeatherContainer.topAnchor),
            currentCity.centerXAnchor.constraint(equalTo: currentWeatherContainer.centerXAnchor)
        ])
        
        currentTemp.addConstraints(constraints: [
            currentTemp.topAnchor.constraint(equalTo: currentCity.bottomAnchor, constant: 8),
            currentTemp.centerXAnchor.constraint(equalTo: currentWeatherContainer.centerXAnchor)
        ])
        
        precipitationLabel.addConstraints(constraints: [
            precipitationLabel.topAnchor.constraint(equalTo: currentTemp.bottomAnchor, constant: 8),
            precipitationLabel.centerXAnchor.constraint(equalTo: currentWeatherContainer.centerXAnchor)
        ])
        
        changeTempContainer.addConstraints(constraints: [
            changeTempContainer.topAnchor.constraint(equalTo: precipitationLabel.bottomAnchor, constant: 8),
            changeTempContainer.centerXAnchor.constraint(equalTo: currentWeatherContainer.centerXAnchor),
            changeTempContainer.bottomAnchor.constraint(equalTo: currentWeatherContainer.bottomAnchor)
        ])
        
        minTempLabel.addConstraints(constraints: [
            minTempLabel.topAnchor.constraint(equalTo: changeTempContainer.topAnchor),
            minTempLabel.leadingAnchor.constraint(equalTo: changeTempContainer.leadingAnchor, constant: 8),
            minTempLabel.bottomAnchor.constraint(equalTo: changeTempContainer.bottomAnchor)
        ])
        
        maxTempLabel.addConstraints(constraints: [
            maxTempLabel.topAnchor.constraint(equalTo: changeTempContainer.topAnchor),
            maxTempLabel.trailingAnchor.constraint(equalTo: changeTempContainer.trailingAnchor, constant: -8),
            maxTempLabel.bottomAnchor.constraint(equalTo: changeTempContainer.bottomAnchor)
        ])
    }
    
    func configure(city: WeatherListItem) {
        currentCity.text = city.name
        currentTemp.text = "\(city.currentTemp)°"
        precipitationLabel.text = city.precipitation
        maxTempLabel.text = "H:\(city.maxTemp)°"
        minTempLabel.text = "L:\(city.minTemp)°"
    }
}


