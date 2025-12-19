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
            collectionView: cityListCollection
        ) { collectionView, indexPath, itemIdentifier in
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
            let sections = data.snapshot().sectionIdentifiers
            let section = sections[indexPath.section]
            switch section {
            case .current:
                let currentHeader = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: CurrentHeaderView.reuseIdentifier,
                    for: indexPath
                ) as? CurrentHeaderView
                return currentHeader
            case .favourites:
                let headerFavorites = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: FavoritesHeaderView.reuseIdentifier,
                    for: indexPath
                )
                return headerFavorites
            case .positive:
                let headerHot = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: HotHeaderView.reuseIdentifier,
                    for: indexPath
                )
                return headerHot
            case .negative:
                let coldHeader = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: ColdHeaderView.reuseIdentifier,
                    for: indexPath
                )
                return coldHeader
            }
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
            collectionViewLayout: UICollectionViewLayout()
        )
        collection.register(
            WeatherListCollectionCell.self,
            forCellWithReuseIdentifier: WeatherListCollectionCell.cellIdentifier
        )
        
        collection.register(
            CurrentHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: CurrentHeaderView.reuseIdentifier
        )
        
        collection.register(
            FavoritesHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: FavoritesHeaderView.reuseIdentifier
        )
        
        collection.register(
            HotHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HotHeaderView.reuseIdentifier
        )
        
        collection.register(
            ColdHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ColdHeaderView.reuseIdentifier
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
    
    func makeLayout(
        with provider: @escaping () -> [WeatherList.SectionData]
    ) -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
            
            let sections = provider()
            let sectionData = sections[sectionIndex]
            var config = UICollectionLayoutListConfiguration(appearance: .plain)

            config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
                guard let self = self else { return nil }
                
                guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return nil }
                
                let deleteAction = UIContextualAction(
                    style: .destructive,
                    title: "Удалить"
                ) { action, sourceView, actionPerformed in
                    self.presenter?.remove(at: item.id)
                    actionPerformed(true)
                }
                
                deleteAction.backgroundColor = .red
                deleteAction.image = UIImage(systemName: "trash")
                
                let favoritesTitle = item.isFavorites ? "Убрать из избранного" : "В избранное"
                let favoritesAction = UIContextualAction(
                    style: .normal,
                    title: favoritesTitle,
                ) { action, sourceView, actionPerformed in
                    self.presenter?.changeFlag(isFavorite: !item.isFavorites, cityId: item.id)
                    actionPerformed(true)
                }
                
                favoritesAction.backgroundColor = .orange
                favoritesAction.image = UIImage(systemName: "star")
                return UISwipeActionsConfiguration(actions: [deleteAction, favoritesAction])
            }
            
            let section = NSCollectionLayoutSection.list(using: config, layoutEnvironment: environment)
            
            section.interGroupSpacing = 16
            section.contentInsets = NSDirectionalEdgeInsets(
                top: 8,
                leading: 8,
                bottom: 15,
                trailing: 8
            )
            
            let backgroundDecorationsCurrent = NSCollectionLayoutDecorationItem.background(
                elementKind: RoundedCurrentBackgroundView.reuseIdentifier
            )
            let backgroundDecorationsFavorites = NSCollectionLayoutDecorationItem.background(
                elementKind: RoundedFavoritesBackgroundView.reuseIdentifier
            )
            let backgroundDecorationsHot = NSCollectionLayoutDecorationItem.background(
                elementKind: RoundedHotBackgroundView.reuseIdentifier
            )
            let backgroundDecorationsCold = NSCollectionLayoutDecorationItem.background(
                elementKind: RoundedColdBackgroundView.reuseIdentifier
            )
            
            switch sectionData.section {
            case .current:
                section.decorationItems = [backgroundDecorationsCurrent]
            case .favourites:
                section.decorationItems = [backgroundDecorationsFavorites]
            case .positive:
                section.decorationItems = [backgroundDecorationsHot]
            case .negative:
                section.decorationItems = [backgroundDecorationsCold]
            }
            
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(44)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            header.pinToVisibleBounds = true
            section.boundarySupplementaryItems = [header]
            
            return section
        }
        
        layout.register(
            RoundedCurrentBackgroundView.self,
            forDecorationViewOfKind: RoundedCurrentBackgroundView.reuseIdentifier
        )
        layout.register(
            RoundedFavoritesBackgroundView.self,
            forDecorationViewOfKind: RoundedFavoritesBackgroundView.reuseIdentifier
        )
        layout.register(
            RoundedHotBackgroundView.self,
            forDecorationViewOfKind: RoundedHotBackgroundView.reuseIdentifier
        )
        layout.register(
            RoundedColdBackgroundView.self,
            forDecorationViewOfKind: RoundedColdBackgroundView.reuseIdentifier
        )
        return layout
    }
    
    
    func applySnapShot(sections: [WeatherList.SectionData]) {
        var snapShot = Snapshot()
        
        for sectionData in sections {
            if !sectionData.items.isEmpty {
                snapShot.appendSections([sectionData.section])
                snapShot.appendItems(sectionData.items, toSection: sectionData.section)
            }
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
    
    func updateUI(with dataProvider: @escaping () -> [WeatherList.SectionData]) {
        let newLayout = makeLayout(with: dataProvider)
        cityListCollection.setCollectionViewLayout(newLayout, animated: true)
        applySnapShot(sections: dataProvider())
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
