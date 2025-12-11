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
                cell.layer.borderColor = UIColor.lightGray.cgColor
                cell.layer.borderWidth = 1
                cell.layer.cornerRadius = 22
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
           // let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            header?.configure(title: section.title)
            
            return header
        }
        return data
    }()
    
    private let searchController: UISearchController
    private var deletedIndexPath: IndexPath?
    
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
        
        collection.delegate = self
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

// MARK: - UICollectionViewDelegate

extension WeatherListViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
        presenter?.showDetailsCityWeather(city: item)
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
            var config = UICollectionLayoutListConfiguration(appearance: .plain)
           // config.showsSeparators = true
            config.backgroundColor = Colors.CitiesWeatherListBackground
            config.trailingSwipeActionsConfigurationProvider = { indexPath in
                guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
                let deleteAction = UIContextualAction(
                    style: .destructive,
                    title: "Deleted"
                ) { action, sourceView, actionPerformed in
                    guard let _ = self.dataSource.itemIdentifier(for: indexPath) else { return }
                    print("удалил: \(indexPath.item), \(item), item: \(indexPath.item)")
                    self.presenter?.remove(at: item.id)
                    actionPerformed(true)
                }
                deleteAction.backgroundColor = .red
                deleteAction.image = UIImage(systemName: "trash")
                
                let favoritesTitle = item.isFavorites ? "Remove from favorites" : "Add in favorites"
                let favoritesAction = UIContextualAction(
                    style: .normal,
                    title: favoritesTitle,
                ) { action, sourceView, actionPerformed in
                        guard let  indexPathItem = self.dataSource.itemIdentifier(for: indexPath) else { return }
                    self.presenter?.changeFlag(isFavorite: !item.isFavorites, cityId: indexPathItem.id)
                        actionPerformed(true)
                    }
                
                favoritesAction.backgroundColor = .orange
                favoritesAction.image = UIImage(systemName: "star")
                return UISwipeActionsConfiguration(actions: [deleteAction, favoritesAction])
            }
            
            let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
            
            section.interGroupSpacing = 16
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 8,
                leading: 8,
                bottom: 8,
                trailing: 8
            )
            
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
            snapShot.appendSections([section.type])
            snapShot.appendItems(section.items, toSection: section.type)
        }
        dataSource.apply(snapShot, animatingDifferences: true)
    }
}

// MARK: - Extension Search Controller

extension WeatherListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let resultsController = searchController.searchResultsController as? SearchResultsViewController,
                let cityName = searchController.searchBar.text else { return }
    
        resultsController.updateSearchResults(with: cityName)
    }
}

// MARK: - SearchResultsViewControllerDelegate

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
        hideLoading()
        applySnapShot(sections: sections)
    }
    
    func didUpdateSearchResults(
        _ cities: [String],
        countries: [String]
    ) {
        guard let resultsController = searchController.searchResultsController as? SearchResultsViewController else { return }
        resultsController.updateWithBackendResults(cities: cities, countries: countries)
    }
    
    func hideLoadingIndicator() {
        hideLoading()
    }
    
    func showLoadingIndicator() {
        showLoading()
    }
}
