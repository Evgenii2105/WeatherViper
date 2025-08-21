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
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .gray
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "Загрузка..."
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .gray
        label.isHidden = true
        return label
    }()
    
    private lazy var addCitiesBarButton: UIBarButtonItem = {
        return UIBarButtonItem(
            systemItem: .add,
            primaryAction: UIAction(handler: { [weak self] _ in
                self?.showMap()
            })
        )
    }()
    
    private lazy var loadingStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [loadingIndicator, loadingLabel])
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.isHidden = true
        return stack
    }()
    
    private let cityTable: UITableView = {
        let cityTable = UITableView()
        cityTable.backgroundColor = .white
        return cityTable
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        setupUI()
        setupConstraints()
        createWeatherListTable()
        presenter?.setupDataSource()
    }
}

// MARK: - Private extension WeatherListViewController

private extension WeatherListViewController {
    
    func setupUI() {
        view.backgroundColor = .white
        self.title = "Мои города"
        navigationItem.rightBarButtonItem = addCitiesBarButton
        view.addSubview(cityTable)
        view.addSubview(loadingStackView)
    }
    
    func setupConstraints() {
        loadingStackView.addConstraints(constraints: [
            loadingStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        cityTable.addConstraints(constraints: [
            cityTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
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
        cityTable.separatorStyle = .none
    }
    
    func showLoading() {
        cityTable.isHidden = true
        loadingStackView.isHidden = false
        loadingIndicator.startAnimating()
        loadingLabel.isHidden = false
    }
    
    func hideLoading() {
        cityTable.isHidden = false
        loadingStackView.isHidden = true
        loadingIndicator.stopAnimating()
        loadingLabel.isHidden = true
    }
    
    @objc
    func showMap() {
        presenter?.showMap()
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
        
        let city = cities[indexPath.row]
        cell.configure(city: city)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presenter?.showDetailsCityWeather(city: cities[indexPath.row])
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
    
    func hideLoadingIndicator() {
        hideLoading()
    }
    
    func showLoadingIndicator() {
        showLoading()
    }
    
    func didCityWeather(city: [WeatherListItem]) {
        self.cities = city
        hideLoading()
        cityTable.reloadData()
    }
}
