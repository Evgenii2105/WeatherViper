//
//  ViewController.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import UIKit

class WeatherListViewController: UIViewController {
    
    // MARK: Internal Properties
    
    var presenter: WeatherListPresenter?
    
    // MARK: Private Properties
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var cities: [WeatherListItem] = []
    
    private let cityTable: UITableView = {
        let cityTable = UITableView()
        cityTable.backgroundColor = .black
        return cityTable
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        setupUI()
        setupConstraints()
    }
}

// MARK: - Private extension WeatherListViewController

private extension WeatherListViewController {
    
    func setupUI() {
        view.backgroundColor = .white
        self.title = "Мои города"
        view.addSubview(cityTable)
    }
    
    func setupConstraints() {
        cityTable.addConstraints(constraints: [
            cityTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            cityTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cityTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cityTable.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search City"
        searchController.searchBar.tintColor = .lightGray
        
        
        self.navigationItem.searchController = searchController
        self.definesPresentationContext = false
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func createWeatherListTable() {
        cityTable.register(WeatherListCell.self, forCellReuseIdentifier: WeatherListCell.cellIdentifier)
        cityTable.dataSource = self
        cityTable.delegate = self
    }
}

// MARK: - UITableViewDelegate && UITableViewDataSource

extension WeatherListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WeatherListCell.cellIdentifier, for: indexPath) as? WeatherListCell else {
            return UITableViewCell()
        }
        cell.configure()
        return cell
    }
}

// MARK: - Extension Search Controller

extension WeatherListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        print("Debug", searchController.searchBar.text)
        presenter?.searchCity(searchController.searchBar.text ?? "")
    }
}

// MARK: - WeatherListView

extension WeatherListViewController: WeatherListView {
    
}
