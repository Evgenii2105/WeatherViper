//
//  WeatherDetailsViewController.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 12.08.2025.
//

import UIKit

final class WeatherDetailsViewController: UIViewController {
    
    enum Section {
        case section
    }
    
    enum StateCollection {
        case horizontal
        case vertical
        case oneToTwo
    }
    
    enum StateLayout {
        case firstOpening
        case secondOpening
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, WeatherFiveDaysItem>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, WeatherFiveDaysItem>
    
    static let badgeElementKind = "badge-element-kind"
    
    var presenter: WeatherDetailsPresenter?
    var state: StateCollection = .oneToTwo
    var stateLayout: StateLayout = .firstOpening
    
    private lazy var dataSource: DataSource = {
        let data = DataSource(collectionView: fiveDayWeatherCollection) { collectionView, indexPath, itemIdentifier in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FiveDayWeatherCollectionCell.identifier,
                for: indexPath
            ) as? FiveDayWeatherCollectionCell else {
                return UICollectionViewCell()
            }
            cell.configure(fiveDaysWeather: itemIdentifier)
            return cell
        }
        data.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard kind == WeatherDetailsViewController.badgeElementKind,
                  let view = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: BadgeSupplementaryView.reuseIdentifier,
                    for: indexPath
                  ) as? BadgeSupplementaryView,
                  let item = self?.dataSource.itemIdentifier(for: indexPath) else {
                return nil
            }
            view.configure(city: item)
            return view
        }
        return data
    }()
    
    private let currentWeatherContainer: UIView = {
        let container = UIView()
        container.backgroundColor = Colors.CitiesWeatherListBackground
        return container
    }()
    
    private let currentCity: UILabel = {
        let currentCity = UILabel()
        currentCity.font = .systemFont(ofSize: 22, weight: .bold)
        currentCity.textColor = .black
        currentCity.numberOfLines = 1
        currentCity.adjustsFontSizeToFitWidth = true
        return currentCity
    }()
    
    private let currentTemp: UILabel = {
        let currentTemp = UILabel()
        currentTemp.font = .systemFont(ofSize: 26, weight: .bold)
        currentTemp.textColor = .black
        return currentTemp
    }()
    
    private let precipitationLabel: UILabel = {
        let precipitationLabel = UILabel()
        precipitationLabel.font = .systemFont(ofSize: 18, weight: .light)
        precipitationLabel.numberOfLines = 1
        precipitationLabel.textColor = .black
        return precipitationLabel
    }()
    
    private let changeTempContainer: UIView = {
        let changeTempContainer = UIView()
        changeTempContainer.backgroundColor = Colors.CitiesWeatherListBackground
        return changeTempContainer
    }()
    
    private let maxTempLabel: UILabel = {
        let maxTempLabel = UILabel()
        maxTempLabel.font = .systemFont(ofSize: 16, weight: .light)
        maxTempLabel.textColor = .black
        return maxTempLabel
    }()
    
    private let minTempLabel: UILabel = {
        let minTempLabel = UILabel()
        minTempLabel.font = .systemFont(ofSize: 16, weight: .light)
        minTempLabel.textColor = .black
        return minTempLabel
    }()
    
    private lazy var  fiveDayWeatherCollection: UICollectionView = {
        let fiveDayWeatherCollection = UICollectionView(
            frame: .zero,
            collectionViewLayout: createLayout(state: self.state)
        )
        fiveDayWeatherCollection.register(
            FiveDayWeatherCollectionCell.self,
            forCellWithReuseIdentifier: FiveDayWeatherCollectionCell.identifier
        )
        fiveDayWeatherCollection.register(
            BadgeSupplementaryView.self,
            forSupplementaryViewOfKind: Self.badgeElementKind,
            withReuseIdentifier: BadgeSupplementaryView.reuseIdentifier
        )
        fiveDayWeatherCollection.backgroundColor = Colors.CitiesWeatherListBackground
        return fiveDayWeatherCollection
    }()
    
    private lazy var changeViewCollection: UIBarButtonItem = {
        let menu = UIMenu(
            children: [
                UIAction(
                    title: "Список",
                    image: UIImage(
                        systemName: "rectangle.and.pencil.and.ellipsis"
                    ),
                    handler: { [weak self] _ in
                        guard let self else { return }
                        self.changeOnListCollection()
                    }
                ),
                UIAction(
                    title: "Коллекци",
                    image: UIImage(
                        systemName: "folder.circle"
                    ),
                    handler: { [weak self] _ in
                        self?.changeCollectionButtonTouchUpInside()
                    }
                ),
                UIAction(
                    title: "1:2",
                    image: UIImage(systemName: "align.vertical.center"),
                    handler: { [weak self] _ in
                        self?.changeOneToTwoButtonTouchUpInside()
                    }
                )
            ]
        )
        let visualChangeCollection = UIBarButtonItem(
            image: UIImage(systemName: "pencil.circle"),
            menu: menu
        )
        return visualChangeCollection
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        presenter?.setupDataSource(state: stateLayout)
    }
}

// MARK: - WeatherDetailsView

extension WeatherDetailsViewController: WeatherDetailsView {
    
    func updateUI(with dataProvider: @escaping () -> [WeatherFiveDaysItem]) {
        let newLayout = makeLayout(with: dataProvider)
        fiveDayWeatherCollection.setCollectionViewLayout(newLayout, animated: true)
        applySnapShot(weather: dataProvider())
    }
    
    func didGetWeather(city: WeatherListItem) {
        configure(city: city)
    }
    
    func didGetWeatherFiveDays(weather: [WeatherFiveDaysItem]) {
        applySnapShot(weather: weather)
    }
}

// MARK: - Private Extension

private extension WeatherDetailsViewController {
    
    func setupUI() {
        view.backgroundColor = Colors.CitiesWeatherListBackground
        view.addSubview(currentWeatherContainer)
        currentWeatherContainer.addSubview(currentCity)
        currentWeatherContainer.addSubview(currentTemp)
        currentWeatherContainer.addSubview(precipitationLabel)
        currentWeatherContainer.addSubview(changeTempContainer)
        changeTempContainer.addSubview(maxTempLabel)
        changeTempContainer.addSubview(minTempLabel)
        view.addSubview(fiveDayWeatherCollection)
        navigationItem.rightBarButtonItem = changeViewCollection
    }
    
    func setupConstraints() {
        currentWeatherContainer.addConstraints(constraints: [
            currentWeatherContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            currentWeatherContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentWeatherContainer.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        currentCity.addConstraints(constraints: [
            currentCity.topAnchor.constraint(equalTo: currentWeatherContainer.topAnchor),
            currentCity.centerXAnchor.constraint(equalTo: currentWeatherContainer.centerXAnchor)
        ])
        
        currentTemp.addConstraints(constraints: [
            currentTemp.topAnchor.constraint(equalTo: currentCity.bottomAnchor, constant: 8),
            currentTemp.centerXAnchor.constraint(equalTo: currentWeatherContainer.centerXAnchor)
        ])
        
        precipitationLabel.addConstraints(constraints: [
            precipitationLabel.topAnchor.constraint(equalTo: currentTemp.bottomAnchor, constant: 8),
            precipitationLabel.centerXAnchor.constraint(equalTo: currentWeatherContainer.centerXAnchor)
        ])
        
        changeTempContainer.addConstraints(constraints: [
            changeTempContainer.topAnchor.constraint(equalTo: precipitationLabel.bottomAnchor, constant: 8),
            changeTempContainer.centerXAnchor.constraint(equalTo: currentWeatherContainer.centerXAnchor),
            changeTempContainer.bottomAnchor.constraint(equalTo: currentWeatherContainer.bottomAnchor)
        ])
        
        minTempLabel.addConstraints(constraints: [
            minTempLabel.topAnchor.constraint(equalTo: changeTempContainer.topAnchor),
            minTempLabel.leadingAnchor.constraint(equalTo: changeTempContainer.leadingAnchor, constant: 8),
            minTempLabel.bottomAnchor.constraint(equalTo: changeTempContainer.bottomAnchor)
        ])
        
        maxTempLabel.addConstraints(constraints: [
            maxTempLabel.topAnchor.constraint(equalTo: changeTempContainer.topAnchor),
            maxTempLabel.trailingAnchor.constraint(equalTo: changeTempContainer.trailingAnchor, constant: -8),
            maxTempLabel.bottomAnchor.constraint(equalTo: changeTempContainer.bottomAnchor)
        ])
        
        fiveDayWeatherCollection.addConstraints(constraints: [
            fiveDayWeatherCollection.topAnchor.constraint(equalTo: changeTempContainer.bottomAnchor, constant: 8),
            fiveDayWeatherCollection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fiveDayWeatherCollection.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fiveDayWeatherCollection.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func createBadgeItem() -> NSCollectionLayoutSupplementaryItem {
        let topRightAnchor = NSCollectionLayoutAnchor(
            edges: [.top, .trailing],
            fractionalOffset: CGPoint(x: 0.2, y: -0.2)
        )
        let badgeSize = NSCollectionLayoutSize(
            widthDimension: .absolute(20),
            heightDimension: .absolute(20)
        )
        let badge = NSCollectionLayoutSupplementaryItem(
            layoutSize: badgeSize,
            elementKind: WeatherDetailsViewController.badgeElementKind,
            containerAnchor: topRightAnchor
        )
        return badge
    }
    
    func makeLayout(
        with dataProvider: @escaping () -> [WeatherFiveDaysItem]
    ) -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, environment in
            var items: [NSCollectionLayoutItem] = []
            
            dataProvider().forEach{
                let itemSize: NSCollectionLayoutSize
                if $0.temp > 0 {
                    itemSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(66)
                    )
                } else {
                    itemSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(44)
                    )
                }
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                items.append(item)
            }
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(CGFloat(44 * items.count))
            )
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: groupSize,
                subitems: items
            )
            group.interItemSpacing = .fixed(8)
            
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
    }
    
    func createLayout(state: StateCollection) -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            switch state {
            case .horizontal:
                
                let item = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(0.5)
                    )
                )
                
                item.contentInsets = NSDirectionalEdgeInsets(
                    top: 10,
                    leading: 10,
                    bottom: 10,
                    trailing: 10
                )
                
                let containerGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(0.5),
                        heightDimension: .fractionalHeight(1.0)
                    ),
                    repeatingSubitem: item,
                    count: 2
                )
                let section = NSCollectionLayoutSection(group: containerGroup)
                section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
                return section
                
            case .vertical:
                let item = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(0.5),
                        heightDimension: .fractionalHeight(1)
                    )
                )
                
                item.contentInsets = NSDirectionalEdgeInsets(
                    top: 10,
                    leading: 10,
                    bottom: 10,
                    trailing: 10
                )
                
                let containerGroup = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(0.5)
                    ),
                    repeatingSubitem: item,
                    count: 2
                )
                let section = NSCollectionLayoutSection(group: containerGroup)
                return section
                
            case .oneToTwo:
                let twoItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(0.5),
                        heightDimension: .fractionalHeight(1.0)
                    )
                )
                twoItem.contentInsets = NSDirectionalEdgeInsets(
                    top: 10,
                    leading: 10,
                    bottom: 10,
                    trailing: 10
                )
                
                let twoGroup = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(0.5)
                    ),
                    repeatingSubitem: twoItem,
                    count: 2
                )
                
                let oneItem = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(1.0)
                    )
                )
                oneItem.contentInsets = NSDirectionalEdgeInsets(
                    top: 10,
                    leading: 10,
                    bottom: 10,
                    trailing: 10
                )
                
                let oneGroup = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(0.5)
                    ),
                    subitems: [oneItem]
                )
                
                let containerGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(1.0)
                    ),
                    subitems: [twoGroup, oneGroup]
                )
                
                let section = NSCollectionLayoutSection(group: containerGroup)
                return section
            }
        }
        return layout
    }
    
    func applySnapShot(weather: [WeatherFiveDaysItem]) {
        var snapShot = Snapshot()
        snapShot.appendSections([.section])
        snapShot.appendItems(weather)
        dataSource.apply(snapShot, animatingDifferences: true)
    }
    
    func configure(city: WeatherListItem) {
        currentCity.text = city.name
        currentTemp.text = "\(city.currentTemp)°"
        precipitationLabel.text = city.precipitation
        maxTempLabel.text = "H:\(city.maxTemp)°"
        minTempLabel.text = "L:\(city.minTemp)°"
    }
    
    @objc
    func changeCollectionButtonTouchUpInside() {
        stateLayout = .secondOpening
        presenter?.setupDataSource(state: stateLayout)
    }
    
    @objc
    func changeOnListCollection() {
        state = .vertical
        
        let newLayout = createLayout(state: state)
        fiveDayWeatherCollection.setCollectionViewLayout(newLayout, animated: true)
    }
    
    @objc
    func changeOneToTwoButtonTouchUpInside() {
        state = .oneToTwo
        
        let newLayout = createLayout(state: state)
        fiveDayWeatherCollection.setCollectionViewLayout(newLayout, animated: true)
    }
}

// MARK: - BadgeSupplementaryView

private final class BadgeSupplementaryView: UICollectionReusableView {
    
    static let reuseIdentifier = "BadgeSupplementaryView"
    
    private let badgeView: UIView = {
        let badgeView = UIView()
        badgeView.isHidden = true
        badgeView.layer.cornerRadius = 10
        return badgeView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(badgeView)
        badgeView.addConstraints(constraints: [
            badgeView.heightAnchor.constraint(equalToConstant: 20),
            badgeView.widthAnchor.constraint(equalToConstant: 20),
            badgeView.centerXAnchor.constraint(equalTo: centerXAnchor),
            badgeView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(city: WeatherFiveDaysItem) {
        if city.temp > 4 {
            badgeView.isHidden = false
            badgeView.backgroundColor = .red
        } else {
            badgeView.isHidden = true
        }
    }
}

