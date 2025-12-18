//
//  RoundedColdBackgroundView.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 19.12.2025.
//

import UIKit

final class RoundedColdBackgroundView: UICollectionReusableView {
    
    private var insetView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(insetView)
        
        insetView.addConstraints(constraints: [
            insetView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            trailingAnchor.constraint(equalTo: insetView.trailingAnchor, constant: 8),
            insetView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            insetView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
