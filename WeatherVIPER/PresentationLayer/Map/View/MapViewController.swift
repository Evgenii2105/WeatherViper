//
//  MapViewController.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 20.08.2025.
//

import UIKit
import MapKit

final class MapViewController: UIViewController, MKMapViewDelegate {
    
    var presenter: MapPresenter?
    
    private let locationManager = CLLocationManager()
    private let mapView = MKMapView()
    
    private lazy var doneSearchCity: UIBarButtonItem = {
        return UIBarButtonItem(
            systemItem: .done,
            primaryAction: UIAction(handler: { [weak self] _ in
                self?.presenter?.dismissModule()
            })
        )
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
    }
}

extension MapViewController: MapView {
    
    func addPointAnnotation(_ annotation: MKAnnotation) {
        mapView.annotations.forEach({ mapView.removeAnnotation($0) })
        mapView.addAnnotation(annotation)
    }
}

private extension MapViewController {
    
    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(mapView)
        
        navigationItem.rightBarButtonItem = doneSearchCity
        
        mapView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(handleMapTap))
        )
    }
    
    func setupConstraints() {
        mapView.addConstraints(constraints: [
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc
    func handleMapTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let locationView = gestureRecognizer.location(in: mapView)
        let tappedCoordinate = mapView.convert(locationView, toCoordinateFrom: mapView)
        
        print(tappedCoordinate.latitude, tappedCoordinate.longitude)
        presenter?.handleMapTap(with: tappedCoordinate)
    }
}
