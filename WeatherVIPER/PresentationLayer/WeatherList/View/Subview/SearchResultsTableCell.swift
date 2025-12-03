//
//  SearchResultsTableCell.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 14.11.2025.
//

import UIKit

final class SearchResultsTableCell: UITableViewCell {
    
    static let cellIdentifier = "SearchResultsTableCell"
    
    private let nameCityLabel: UILabel = {
        let nameCity = UILabel()
        nameCity.textColor = .black
        nameCity.translatesAutoresizingMaskIntoConstraints = false
        return nameCity
    }()
    
    private let countryLabel: UILabel = {
       let countryLabel = UILabel()
        countryLabel.textColor = .black
        countryLabel.text = "\(12.3)"
        countryLabel.translatesAutoresizingMaskIntoConstraints = false
        return countryLabel
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(city: String, country: String) {
        nameCityLabel.text = city
        countryLabel.text = country
    }
}

private extension SearchResultsTableCell {
    
    func setupUI() {
        contentView.addSubview(nameCityLabel)
        contentView.addSubview(countryLabel)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            nameCityLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameCityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            countryLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            countryLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
}
