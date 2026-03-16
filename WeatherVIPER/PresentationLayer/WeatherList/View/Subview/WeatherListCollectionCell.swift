//
//  WeatherListCollectionCell.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 03.12.2025.
//

import UIKit

protocol PrefetchImageDelegate: AnyObject {
    func downloadedImageDelegate()
}

final class WeatherListCollectionCell: UICollectionViewCell {
    
    // MARK: Constants
    
    private enum Constants {
        static let twelvePadding: CGFloat = 12
        static let eightPadding: CGFloat = 8
    }
    
    // MARK: Internal Properties
    
    static let cellIdentifier = "WeatherListCollectionCell"
    private var cityId: Int?
    weak var delegate: PrefetchImageDelegate?
    
    // MARK: Private Properties
    
    private let currentWeatherImage: UIImageView = {
       let currentWeatherImage = UIImageView()
        currentWeatherImage.contentMode = .scaleAspectFit
        currentWeatherImage.clipsToBounds = false
        currentWeatherImage.tintColor = .green
        return currentWeatherImage
    }()
    
    private let nameLabel: UILabel = {
       let nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = .white
        nameLabel.lineBreakMode = .byTruncatingMiddle
        nameLabel.numberOfLines = 0
        nameLabel.textAlignment = .left
        return nameLabel
    }()
    
    private let currentTemp: UILabel = {
       let currentTemp = UILabel()
        currentTemp.textColor = .white
        currentTemp.font = .systemFont(ofSize: 18, weight: .bold)
        currentTemp.numberOfLines = 1
        currentTemp.textAlignment = .right
        return currentTemp
    }()
    
    private let changeTempContainer: UIView = {
        let changeTempContainer = UIView()
        changeTempContainer.backgroundColor = .systemBackground
        return changeTempContainer
    }()
    
    private let minTemp: UILabel = {
       let minTemp = UILabel()
        minTemp.textColor = .white
        minTemp.numberOfLines = 1
        minTemp.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        minTemp.textAlignment = .right
        return minTemp
    }()
    
    private let maxTemp: UILabel = {
       let maxTemp = UILabel()
        maxTemp.numberOfLines = 1
        maxTemp.textColor = .white
        maxTemp.textAlignment = .right
        maxTemp.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return maxTemp
    }()
    
    private let precipitationLabel: UILabel = {
       let precipitationLabel = UILabel()
        precipitationLabel.textColor = .white
        precipitationLabel.numberOfLines = 0
        precipitationLabel.textAlignment = .left
        precipitationLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return precipitationLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
        contentView.layer.cornerRadius = 22
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(city: WeatherList.WeatherListItem) {
        
        cityId = city.id
        
        nameLabel.text = city.name
        
        if city.currentTemp > 0 {
            currentTemp.text = "+\(city.currentTemp)°"
        } else {
            currentTemp.text = "\(city.currentTemp)°"
        }
        
        maxTemp.text = "H: \(city.maxTemp)°"
        minTemp.text = "L: \(city.minTemp)°"
        precipitationLabel.text = city.precipitation
        let weatherImage = city.imageContainer
        
        switch weatherImage {
        case .imageURL:
            currentWeatherImage.image = nil
        case .image(let image, _):
            currentWeatherImage.image = image
        }
    }
}

// MARK: - Private Extension

private extension WeatherListCollectionCell {
    
    func setupUI() {
        contentView.backgroundColor = Colors.CitiesWeatherListBackground
        contentView.addSubview(currentWeatherImage)
        contentView.addSubview(nameLabel)
        contentView.addSubview(currentTemp)
        contentView.addSubview(changeTempContainer)
        changeTempContainer.addSubview(maxTemp)
        changeTempContainer.addSubview(minTemp)
        contentView.addSubview(precipitationLabel)
    }
    
    func setupConstraints() {
        currentWeatherImage.addConstraints(constraints: [
            currentWeatherImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            currentWeatherImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            currentWeatherImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
           // currentWeatherImage.heightAnchor.constraint(equalToConstant: 100),
            currentWeatherImage.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        nameLabel.addConstraints(constraints: [
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.eightPadding),
            nameLabel.leadingAnchor.constraint(equalTo: currentWeatherImage.trailingAnchor, constant: Constants.eightPadding),
            nameLabel.bottomAnchor.constraint(equalTo: precipitationLabel.topAnchor, constant: -Constants.eightPadding),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: currentTemp.leadingAnchor, constant: 22)
        ])
        
        currentTemp.addConstraints(constraints: [
            currentTemp.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            currentTemp.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.eightPadding * 2)
        ])
        
        precipitationLabel.addConstraints(constraints: [
            precipitationLabel.leadingAnchor.constraint(equalTo: currentWeatherImage.trailingAnchor, constant: Constants.eightPadding),
            precipitationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.eightPadding),
            precipitationLabel.trailingAnchor.constraint(equalTo: changeTempContainer.leadingAnchor, constant: -8)
        ])
        
        changeTempContainer.addConstraints(constraints: [
            changeTempContainer.centerYAnchor.constraint(equalTo: precipitationLabel.centerYAnchor),
            changeTempContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.eightPadding * 2),
        ])
        
        maxTemp.addConstraints(constraints: [
            maxTemp.leadingAnchor.constraint(equalTo: changeTempContainer.leadingAnchor),
            maxTemp.centerYAnchor.constraint(equalTo: changeTempContainer.centerYAnchor)
        ])
        
        minTemp.addConstraints(constraints: [
            minTemp.leadingAnchor.constraint(equalTo: maxTemp.trailingAnchor, constant: 8),
            minTemp.trailingAnchor.constraint(equalTo: changeTempContainer.trailingAnchor),
            minTemp.centerYAnchor.constraint(equalTo: changeTempContainer.centerYAnchor)
        ])
    }
}

