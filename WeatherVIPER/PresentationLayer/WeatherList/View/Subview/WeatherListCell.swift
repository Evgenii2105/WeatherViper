//
//  WeatherListCell.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import UIKit

final class WeatherListCell: UITableViewCell {
    
    // MARK: Constants
    
    private enum Constants {
        static let twelvePadding: CGFloat = 12
        static let eightPadding: CGFloat = 8
    }
    
    // MARK: Internal Properties
    
    static let cellIdentifier = "WeatherListCell"
    private static let cache = NSCache<NSURL, UIImage>()
    
    // MARK: Private Properties
    
    private let currentWeatherImage: UIImageView = {
       let currentWeatherImage = UIImageView()
        currentWeatherImage.contentMode = .scaleAspectFill
        currentWeatherImage.clipsToBounds = false
        currentWeatherImage.tintColor = .green
        return currentWeatherImage
    }()
    
    private let nameLabel: UILabel = {
       let nameLabel = UILabel()
        nameLabel.font = .systemFont(ofSize: 18, weight: .bold)
        nameLabel.textColor = .black
        nameLabel.lineBreakMode = .byTruncatingMiddle
        nameLabel.numberOfLines = 0
        nameLabel.textAlignment = .left
        return nameLabel
    }()
    
    private let currentTemp: UILabel = {
       let currentTemp = UILabel()
        currentTemp.textColor = .black
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
        minTemp.textColor = .lightGray
        minTemp.numberOfLines = 1
        minTemp.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        minTemp.textAlignment = .right
        return minTemp
    }()
    
    private let maxTemp: UILabel = {
       let maxTemp = UILabel()
        maxTemp.numberOfLines = 1
        maxTemp.textColor = .lightGray
        maxTemp.textAlignment = .right
        maxTemp.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return maxTemp
    }()
    
    private let precipitationLabel: UILabel = {
       let precipitationLabel = UILabel()
        precipitationLabel.textColor = .lightGray
        precipitationLabel.numberOfLines = 2
        precipitationLabel.textAlignment = .left
        precipitationLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return precipitationLabel
    }()
    
    // MARK: Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Actions
    
    func configure(city: WeatherListItem) {
        nameLabel.text = city.name
        
        if city.currentTemp > 0 {
            currentTemp.text = "+\(city.currentTemp)°"
        } else {
            currentTemp.text = "-\(city.currentTemp)°"
        }
        
        maxTemp.text = "H: \(city.maxTemp)°"
        minTemp.text = "L: \(city.minTemp)°"
        precipitationLabel.text = city.precipitation
        
        guard let weatherImageUrl = city.weatherImage else {
            currentWeatherImage.image = nil
            return
        }
        
        if let image = Self.cache.object(forKey: city.weatherImage! as NSURL) {
            currentWeatherImage.image = image
        } else {
            currentWeatherImage.image = UIImage(systemName: "photo.badge.exclamationmark")
            NetworkImpl.downloadImage(from: weatherImageUrl) { [weak self] image in
                guard let self else { return }
                
                DispatchQueue.main.async {
                    if let downloadedImage = image {
                        self.currentWeatherImage.image = downloadedImage
                    }
                }
            }
        }
    }
}

// MARK: - Private Extension

private extension WeatherListCell {
    
    func setupUI() {
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
            currentWeatherImage.heightAnchor.constraint(equalToConstant: 100),
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
