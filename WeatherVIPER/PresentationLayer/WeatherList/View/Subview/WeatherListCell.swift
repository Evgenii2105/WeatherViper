//
//  WeatherListCell.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import UIKit

final class WeatherListCell: UITableViewCell {
    
    // MARK: Internal Properties
    
    static let cellIdentifier = "WeatherListCell"
    
    // MARK: Private Properties
    
    private let nameLabel: UILabel = {
       let nameLabel = UILabel()
        
        return nameLabel
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
    
    func configure() {
        
    }
}

// MARK: - Private Extension

private extension WeatherListCell {
    
    func setupUI() {
        
    }
    
    func setupConstraints() {
        
    }
}
