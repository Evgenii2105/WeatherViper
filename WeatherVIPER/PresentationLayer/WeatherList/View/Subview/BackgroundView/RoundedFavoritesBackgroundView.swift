//
//  RoundedFavoritesBackgroundView.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 18.12.2025.
//

import UIKit

final class RoundedFavoritesBackgroundView: UICollectionReusableView {
    
    private let insertView: UIView = {
       let view = UIView()
        view.backgroundColor = .orange
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(insertView)
        
        insertView.addConstraints(constraints: [
            insertView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            insertView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            insertView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            trailingAnchor.constraint(equalTo: insertView.trailingAnchor, constant: 8)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
