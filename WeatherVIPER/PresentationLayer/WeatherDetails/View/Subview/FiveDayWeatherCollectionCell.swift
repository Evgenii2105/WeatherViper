//
//  ThreeDayWeatherCollectionCell.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 14.08.2025.
//

import UIKit

final class FiveDayWeatherCollectionCell: UICollectionViewCell {
    
    static let identifier = "ThreeDayWeatherCollectionCell"
    
    private let timeLabel: UILabel = {
        let timeLabel = UILabel()
        timeLabel.textColor = .black
        timeLabel.numberOfLines = 0
        timeLabel.textAlignment = .left
        timeLabel.adjustsFontSizeToFitWidth = true
        return timeLabel
    }()
    
    private let iconWeatherImage: UIImageView = {
        let iconWeatherImage = UIImageView()
        iconWeatherImage.contentMode = .scaleAspectFill
        iconWeatherImage.clipsToBounds = false
        return iconWeatherImage
    }()
    
    private let tempLabel: UILabel = {
        let minTempLabel = UILabel()
        minTempLabel.textColor = .black
        minTempLabel.textAlignment = .right
        minTempLabel.adjustsFontSizeToFitWidth = false
        minTempLabel.adjustsFontForContentSizeCategory = false
        return minTempLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(fiveDaysWeather: WeatherFiveDaysItem) {
        timeLabel.text = fiveDaysWeather.date
        tempLabel.text = "\(fiveDaysWeather.temp)°"
        
        guard let weatherImageUrl = fiveDaysWeather.icon else {
            iconWeatherImage.image = UIImage(systemName: "photo.badge.exclamationmark")
            return
        }
        
        NetworkImpl.downloadImage(
            from: weatherImageUrl
        ) { [weak self] image in
            guard let self else { return }
            DispatchQueue.main.async {
                if let downloadedImage = image {
                    self.iconWeatherImage.image = downloadedImage
                } else {
                    self.iconWeatherImage.image = UIImage(systemName: "photo.badge.exclamationmark")
                }
            }
        }
    }
}

// MARK: - Private extension

private extension FiveDayWeatherCollectionCell {
    
    func setupUI() {
        contentView.layer.cornerRadius = 22
        contentView.backgroundColor = .lightGray
        contentView.addSubview(timeLabel)
        contentView.addSubview(iconWeatherImage)
        contentView.addSubview(tempLabel)
    }
    
    func setupConstraints() {
        
        timeLabel.addConstraints(constraints: [
            timeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            timeLabel.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 1/3)
        ])
        
        iconWeatherImage.addConstraints(constraints: [
            iconWeatherImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconWeatherImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconWeatherImage.leadingAnchor.constraint(equalTo: timeLabel.trailingAnchor, constant: 16),
            iconWeatherImage.trailingAnchor.constraint(equalTo: tempLabel.leadingAnchor, constant: -16),
            iconWeatherImage.heightAnchor.constraint(equalToConstant: 40),
            iconWeatherImage.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.6/3)
        ])
        
        tempLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        tempLabel.addConstraints(constraints: [
            tempLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            tempLabel.leadingAnchor.constraint(equalTo: iconWeatherImage.trailingAnchor, constant: 16),
            tempLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            tempLabel.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 1/3)
        ])
    }
}
