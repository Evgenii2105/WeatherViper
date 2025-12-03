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
    
    typealias DataSource = UICollectionViewDiffableDataSource<WeatherListInteractorImpl.ListSection, WeatherListItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<WeatherListInteractorImpl.ListSection, WeatherListItem>
    
    // MARK: Private Properties
    
    private lazy var dataSource: DataSource = {
        let data = DataSource(
            collectionView: cityListCollection) { collectionView, indexPath, itemIdentifier in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: WeatherListCollectionCell.cellIdentifier,
                    for: indexPath
                ) as? WeatherListCollectionCell else {
                    return UICollectionViewCell()
                }
                cell.configure(city: itemIdentifier)
                return cell
            }
        return data
    }()
    
    private let searchController: UISearchController
    
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
            primaryAction: UIAction(
                handler: { [weak self] _ in
                    self?.presenter?.showMap()
                }
            )
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
    
    private lazy var cityListCollection: UICollectionView = {
        let collection = UICollectionView(
            frame: .zero,
            collectionViewLayout: createLayout()
        )
        
        collection.register(
            WeatherListCollectionCell.self,
            forCellWithReuseIdentifier: WeatherListCollectionCell.cellIdentifier
        )
        collection.backgroundColor = Colors.CitiesWeatherListBackground
        return collection
    }()
    
//    private let cityTable: UITableView = {
//        let cityTable = UITableView()
//        cityTable.backgroundColor = Colors.CitiesWeatherListBackground
//        return cityTable
//    }()
    
    init() {
        let resultController = SearchResultsViewController()
        self.searchController = UISearchController(searchResultsController: resultController)
        
        super.init(nibName: nil, bundle: nil)
        resultController.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function, "list")
        setupSearchController()
        setupUI()
        setupConstraints()
       // createWeatherListTable()
        presenter?.setupDataSource()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        cityListCollection.frame = view.bounds
    }
}

// MARK: - Private extension WeatherListViewController

private extension WeatherListViewController {
    
    func setupUI() {
        view.backgroundColor = Colors.CitiesWeatherListBackground
        self.title = "Мои города"
        navigationItem.rightBarButtonItem = addCitiesBarButton
        view.addSubview(cityListCollection)
        // view.addSubview(cityTable)
        view.addSubview(loadingStackView)
    }
    
    func setupConstraints() {
        loadingStackView.addConstraints(
            constraints: [
                loadingStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                loadingStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ]
        )
        
//        cityTable.addConstraints(
//            constraints: [
//                cityTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//                cityTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//                cityTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
//                cityTable.trailingAnchor.constraint(equalTo: view.trailingAnchor)
//            ]
//        )
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск города"
        searchController.searchBar.tintColor = .lightGray
        
        definesPresentationContext = true
        searchController.modalPresentationStyle = .fullScreen
        searchController.modalTransitionStyle = .coverVertical
        
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
//    func createWeatherListTable() {
//        cityTable.register(WeatherListCell.self, forCellReuseIdentifier: WeatherListCell.cellIdentifier)
//        cityTable.dataSource = self
//        cityTable.delegate = self
//        cityTable.separatorStyle = .singleLine
//    }
    
    func showLoading() {
        cityListCollection.isHidden = true
      //  cityTable.isHidden = true
        loadingStackView.isHidden = false
        loadingIndicator.startAnimating()
        loadingLabel.isHidden = false
    }
    
    func hideLoading() {
        cityListCollection.isHidden = false
       // cityTable.isHidden = false
        loadingStackView.isHidden = true
        loadingIndicator.stopAnimating()
        loadingLabel.isHidden = true
    }
    
    func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (_, _) -> NSCollectionLayoutSection? in
          
        }
        return layout
    }
    
    func applySnapShot(cities: [WeatherListItem]) {
//        var snapShot = Snapshot()
//        snapShot.appendSections([.favourites(cities), .negative(cities),  .positive(cities)])
//        snapShot.appendItems(cities)
//        dataSource.apply(snapShot, animatingDifferences: true)
    }
}

// MARK: - Extension Search Controller

extension WeatherListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let resultsController = searchController.searchResultsController as? SearchResultsViewController else { return }
        
        guard let cityName = searchController.searchBar.text else { return }
        
        resultsController.updateSearchResults(with: cityName)
    }
}

extension WeatherListViewController: SearchResultsViewControllerDelegate {
    
    func didRequestSearch(for query: String) {
        presenter?.searchCities(for: query)
    }
    
    func didSelectCity(_ city: String) {
        searchController.isActive = false
        presenter?.search(city: city)
    }
}

// MARK: - WeatherListView

extension WeatherListViewController: WeatherListView {
    
    func didUpdateSearchResults(
        _ cities: [String],
        countries: [String]
    ) {
        print("Получены результаты поиска: \(cities)")
        guard let resultsController = searchController.searchResultsController as? SearchResultsViewController else { return }
        resultsController.updateWithBackendResults(cities: cities, countries: countries)
    }
    
    func hideLoadingIndicator() {
        hideLoading()
    }
    
    func showLoadingIndicator() {
        showLoading()
    }
    
    func didCityWeather(city: [WeatherListItem]) {
        self.cities = city
        hideLoading()
        applySnapShot(cities: city)
       // cityTable.reloadData()
    }
}

