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
    
    typealias DataSource = UICollectionViewDiffableDataSource<WeatherList.Section, WeatherList.WeatherListItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<WeatherList.Section, WeatherList.WeatherListItem>
    
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
        
        data.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionHeader else { return nil }
            
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: SectionHeaderView.reuseIdentifier,
                for: indexPath
            ) as? SectionHeaderView
            
            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            header?.configure(title: section.title)
            
            return header
        }
        return data
    }()
    
    private let searchController: UISearchController
    
    private var cities: [WeatherList.WeatherListItem] = []
    
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
        
        collection.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier
        )
        collection.backgroundColor = Colors.CitiesWeatherListBackground
        return collection
    }()
    
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
        cityListCollection.dataSource = dataSource
        view.addSubview(cityListCollection)
        view.addSubview(loadingStackView)
    }
    
    func setupConstraints() {
        loadingStackView.addConstraints(
            constraints: [
                loadingStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                loadingStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ]
        )
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
    
    func showLoading() {
        cityListCollection.isHidden = true
        loadingStackView.isHidden = false
        loadingIndicator.startAnimating()
        loadingLabel.isHidden = false
    }
    
    func hideLoading() {
        cityListCollection.isHidden = false
        loadingStackView.isHidden = true
        loadingIndicator.stopAnimating()
        loadingLabel.isHidden = true
    }
    
    func createLayout() -> UICollectionViewLayout {
           let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
               let itemSize = NSCollectionLayoutSize(
                   widthDimension: .fractionalWidth(1.0),
                   heightDimension: .estimated(100)
               )
               let item = NSCollectionLayoutItem(layoutSize: itemSize)
               
               let groupSize = NSCollectionLayoutSize(
                   widthDimension: .fractionalWidth(1.0),
                   heightDimension: .estimated(100)
               )
               let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
               
               let section = NSCollectionLayoutSection(group: group)
               section.interGroupSpacing = 8
               section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16)
               
               let headerSize = NSCollectionLayoutSize(
                   widthDimension: .fractionalWidth(1.0),
                   heightDimension: .estimated(44)
               )
               let header = NSCollectionLayoutBoundarySupplementaryItem(
                   layoutSize: headerSize,
                   elementKind: UICollectionView.elementKindSectionHeader,
                   alignment: .top
               )
               section.boundarySupplementaryItems = [header]
               
               return section
           }
           return layout
       }
    
    func applySnapShot(sections: [(type: WeatherList.Section, items: [WeatherList.WeatherListItem])]) {
        var snapShot = Snapshot()
        for section in sections {
            print(section)
            snapShot.appendSections([section.type])
            snapShot.appendItems(section.items, toSection: section.type)
        }
        dataSource.apply(snapShot, animatingDifferences: true)
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
    
    func didSectionsCityWeather(
        sections: [(type: WeatherList.Section, items: [WeatherList.WeatherListItem])]
    ) {
        print(sections)
        hideLoading()
        applySnapShot(sections: sections)
    }
    
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
    
    func didCityWeather(city: [WeatherList.WeatherListItem]) {
       // self.cities = city
       // hideLoading()
        // applySnapShot(sections: <#T##[(WeatherList.Section, [WeatherList.WeatherListItem])]#>)
       // cityTable.reloadData()
    }
}

