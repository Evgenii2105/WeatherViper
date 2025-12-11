//
//  MapViewController.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 20.08.2025.
//

import UIKit
import MapKit

final class MapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: Internal Properties
    
    var presenter: MapPresenter?
    
    // MARK: Private Properties
    
    private let locationManager = CLLocationManager()
    private let mapView = MKMapView()
    private let annotation = MKPointAnnotation()
    
    private var containerTopConstraint: NSLayoutConstraint?
    private var containerLeadingConstraint: NSLayoutConstraint?
    private var containerMenuTopConstraint: NSLayoutConstraint?
    private var containerMenuLeadingConstraint: NSLayoutConstraint?
    
    private lazy var currentWeatherInfoContainer: UIView = {
        let currentWeatherInfoContainer = UIView()
        currentWeatherInfoContainer.backgroundColor = .lightGray
        currentWeatherInfoContainer.isHidden = true
        currentWeatherInfoContainer.layer.cornerRadius = 16
        currentWeatherInfoContainer.alpha = 0.8
        return currentWeatherInfoContainer
    }()
    
    private let nameCity: UILabel = {
        let nameCity = UILabel()
        nameCity.textColor = .black
        nameCity.textAlignment = .left
        nameCity.numberOfLines = 0
        nameCity.adjustsFontSizeToFitWidth = true
        return nameCity
    }()
    
    private let currentTemperature: UILabel = {
        let currentTemperature = UILabel()
        currentTemperature.textColor = .black
        currentTemperature.textAlignment = .left
        currentTemperature.adjustsFontSizeToFitWidth = true
        return currentTemperature
    }()
    
    private let precipitationLabel: UILabel = {
        let precipitationLabel = UILabel()
        precipitationLabel.textColor = .black
        precipitationLabel.textAlignment = .left
        precipitationLabel.numberOfLines = 2
        precipitationLabel.adjustsFontSizeToFitWidth = true
        return precipitationLabel
    }()
    
    private let minMaxTemperatureContainer: UIView = {
        let view = UIView()
        return view
    }()
    
    private let minimumTemperatureLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private let maximumTemperatureLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var menuContainer: UIView = {
       let menu = UIView()
        menu.backgroundColor = .lightGray
        menu.alpha = 0.8
        menu.isHidden = true
        menu.layer.cornerRadius = 16
        return menu
    }()
    
    private let buttonStack: UIStackView = {
       let buttonStack = UIStackView()
        buttonStack.axis = .vertical
        buttonStack.alignment = .center
        return buttonStack
    }()
    
    private lazy var addCityButton: UIButton = {
       let button = UIButton()
        button.titleLabel?.numberOfLines = 0
        button.titleLabel?.textAlignment = .center
        button.addTarget(
            self,
            action: #selector(addedCity),
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
       let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.addTarget(
            self,
            action: #selector(cancelButtonTouchUpInside),
            for: .touchUpInside
        )
        return button
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupConstraintsWeatherInfoContainer()
    }
}

// MARK: - Map View

extension MapViewController: MapView {
    
    func didGetCurrentInfo(city: WeatherList.WeatherListItem) {
        currentWeatherInfoContainer.isHidden = false
        nameCity.text = city.name
        currentTemperature.text = "\(city.currentTemp)°"
        precipitationLabel.text = city.precipitation
        minimumTemperatureLabel.text = "L:\(city.minTemp)°"
        maximumTemperatureLabel.text = "H:\(city.maxTemp)°"
        
        addCityButton.setTitle("Add: \(city.name)", for: .normal)
    }
    
    func addPointAnnotation(_ annotation: MKAnnotation) {
        // mapView.annotations.forEach({ mapView.removeAnnotation($0) })
        //   annotation.coordinate =
        mapView.addAnnotation(annotation)
    }
}

// MARK: - Private Extension

private extension MapViewController {
    
    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(mapView)
 
        mapView.addSubview(currentWeatherInfoContainer)
        mapView.addSubview(menuContainer)
        menuContainer.addSubview(buttonStack)
        buttonStack.addArrangedSubview(addCityButton)
        buttonStack.addArrangedSubview(cancelButton)
        currentWeatherInfoContainer.addSubview(nameCity)
        currentWeatherInfoContainer.addSubview(currentTemperature)
        currentWeatherInfoContainer.addSubview(precipitationLabel)
        currentWeatherInfoContainer.addSubview(minMaxTemperatureContainer)
        minMaxTemperatureContainer.addSubview(minimumTemperatureLabel)
        minMaxTemperatureContainer.addSubview(maximumTemperatureLabel)
        
        mapView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleMapTap))
        )
    }
    
    func setupConstraints() {
        precipitationLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        mapView.addConstraints(constraints: [
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        nameCity.addConstraints(constraints: [
            nameCity.topAnchor.constraint(equalTo: currentWeatherInfoContainer.topAnchor, constant: 8),
            nameCity.leadingAnchor.constraint(equalTo: currentWeatherInfoContainer.leadingAnchor, constant: 8),
            nameCity.widthAnchor.constraint(equalTo: currentWeatherInfoContainer.widthAnchor, multiplier: 2/3),
            nameCity.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        currentTemperature.addConstraints(constraints: [
            currentTemperature.topAnchor.constraint(equalTo: currentWeatherInfoContainer.topAnchor, constant: 8),
            currentTemperature.trailingAnchor.constraint(equalTo: currentWeatherInfoContainer.trailingAnchor, constant: -8),
            currentTemperature.widthAnchor.constraint(equalToConstant: 50),
            currentTemperature.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        precipitationLabel.addConstraints(constraints: [
            precipitationLabel.leadingAnchor.constraint(equalTo: currentWeatherInfoContainer.leadingAnchor, constant: 8),
            precipitationLabel.bottomAnchor.constraint(equalTo: currentWeatherInfoContainer.bottomAnchor, constant: -8),
            precipitationLabel.widthAnchor.constraint(equalTo: currentWeatherInfoContainer.widthAnchor, multiplier: 1 / 2),
            precipitationLabel.heightAnchor.constraint(equalToConstant: 32),
            precipitationLabel.trailingAnchor.constraint(lessThanOrEqualTo: minMaxTemperatureContainer.leadingAnchor, constant: -8)
        ])
        
        minMaxTemperatureContainer.addConstraints(constraints: [
            minMaxTemperatureContainer.trailingAnchor.constraint(equalTo: currentWeatherInfoContainer.trailingAnchor, constant: -8),
            minMaxTemperatureContainer.bottomAnchor.constraint(equalTo: currentWeatherInfoContainer.bottomAnchor, constant: -8),
            minMaxTemperatureContainer.widthAnchor.constraint(equalToConstant: 100),
            minMaxTemperatureContainer.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        minimumTemperatureLabel.addConstraints(constraints: [
            minimumTemperatureLabel.topAnchor.constraint(equalTo: minMaxTemperatureContainer.topAnchor),
            minimumTemperatureLabel.bottomAnchor.constraint(equalTo: minMaxTemperatureContainer.bottomAnchor),
            minimumTemperatureLabel.trailingAnchor.constraint(equalTo: maximumTemperatureLabel.leadingAnchor, constant: -4),
            minimumTemperatureLabel.widthAnchor.constraint(equalTo: minMaxTemperatureContainer.widthAnchor, multiplier: 1 / 2)
        ])
        
        maximumTemperatureLabel.addConstraints(constraints: [
            maximumTemperatureLabel.topAnchor.constraint(equalTo: minMaxTemperatureContainer.topAnchor),
            maximumTemperatureLabel.leadingAnchor.constraint(equalTo: minimumTemperatureLabel.trailingAnchor, constant: -4),
            maximumTemperatureLabel.bottomAnchor.constraint(equalTo: minMaxTemperatureContainer.bottomAnchor),
            maximumTemperatureLabel.trailingAnchor.constraint(equalTo: minMaxTemperatureContainer.trailingAnchor),
            maximumTemperatureLabel.widthAnchor.constraint(equalTo: minMaxTemperatureContainer.widthAnchor, multiplier: 1 / 2)
        ])
    }
    
    func setupConstraintsWeatherInfoContainer() {
        containerTopConstraint = currentWeatherInfoContainer.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 50)
        containerLeadingConstraint = currentWeatherInfoContainer.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 50)
        
        currentWeatherInfoContainer.addConstraints(constraints: [
            containerTopConstraint!,
            containerLeadingConstraint!,
            currentWeatherInfoContainer.widthAnchor.constraint(equalToConstant: 250),
            currentWeatherInfoContainer.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        containerMenuTopConstraint = menuContainer.topAnchor.constraint(equalTo: mapView.topAnchor, constant: 300)
        containerMenuLeadingConstraint = menuContainer.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 50)
        
        
        menuContainer.addConstraints(constraints: [
            containerMenuTopConstraint!,
            containerMenuLeadingConstraint!,
            menuContainer.widthAnchor.constraint(equalToConstant: 200),
            menuContainer.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        buttonStack.addConstraints(constraints: [
            buttonStack.topAnchor.constraint(equalTo: menuContainer.topAnchor),
            buttonStack.leadingAnchor.constraint(equalTo: menuContainer.leadingAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: menuContainer.bottomAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: menuContainer.trailingAnchor)
        ])
    }
    
    @objc
    func handleMapTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let locationInMapView = gestureRecognizer.location(in: mapView)
        let tappedCoordinate = mapView.convert(locationInMapView, toCoordinateFrom: mapView)
        
        let containerWidth: CGFloat = 250
        let containerHeight: CGFloat = 100
        let screenBounds = mapView.bounds
        
        let isLeftSide = locationInMapView.x < screenBounds.width / 2
        let isTopSide = locationInMapView.y < screenBounds.height / 2
        
        var desiredX: CGFloat
        var desiredY: CGFloat
        
        if isLeftSide {
            desiredX = locationInMapView.x + 16
        } else {
            desiredX = locationInMapView.x - containerWidth - 16
        }
        
        if isTopSide {
            desiredY = locationInMapView.y + 16
        } else {
            desiredY = locationInMapView.y - containerHeight - 16
        }
        if desiredX + containerWidth > screenBounds.width {
            desiredX = screenBounds.width - containerWidth - 8
        }
        
        if desiredX < 0 {
            desiredX = 8
        }
        
        if desiredY + containerHeight > screenBounds.height {
            desiredY = screenBounds.height - containerHeight - 8
        }
        
        if desiredY < 0 {
            desiredY = 8
        }
        
        UIView.animate(withDuration: 0.3) {
            self.containerTopConstraint?.constant = desiredY
            self.containerLeadingConstraint?.constant = desiredX
            self.containerMenuTopConstraint?.constant = desiredY + containerWidth / 2.2
            self.containerMenuLeadingConstraint?.constant = desiredX
            
            self.view.layoutIfNeeded()
        }
        
        annotation.coordinate = tappedCoordinate
        mapView.addAnnotation(annotation)
        
        currentWeatherInfoContainer.isHidden = false
        menuContainer.isHidden = false
        
        presenter?.getCurrentInfoCity(tappedCoordinate)
    }
    
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .absolute(44),
                heightDimension: .absolute(80)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0))
            
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: [item]
            )
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
        return layout
    }
    
    @objc
    func addedCity() {
        presenter?.handleMapTap(with: annotation.coordinate)
        currentWeatherInfoContainer.isHidden = true
        menuContainer.isHidden = true
        mapView.removeAnnotation(annotation)
    }
    
    @objc
    func cancelButtonTouchUpInside() {
        menuContainer.isHidden = true
        currentWeatherInfoContainer.isHidden = true
        mapView.removeAnnotation(annotation)
    }
}
