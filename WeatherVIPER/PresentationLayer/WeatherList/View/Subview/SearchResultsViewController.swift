//
//  SearchResultsViewController.swift
//  WeatherVIPER
//
//  Created by Евгений Фомичев on 13.11.2025.
//

protocol SearchResultsViewControllerDelegate: AnyObject {
    func didSelectCity(_ city: String)
    func didRequestSearch(for query: String)
}

import UIKit

final class SearchResultsViewController: UIViewController {
    
    struct SearchResult {
        let city: String
        let country: String
    }
    
    weak var delegate: SearchResultsViewControllerDelegate?
    
    private let resultsTableView = UITableView()
    private var searchResult: [SearchResult] = []
    private let popularCities: [SearchResult] = [
        SearchResult(city: "Москва", country: "RU"),
        SearchResult(city: "Санкт-Петербург", country: "RU"),
        SearchResult(city: "Новосибирск", country: "RU"),
        SearchResult(city: "Екатеринбург", country: "RU"),
        SearchResult(city: "Казань", country: "RU"),
        SearchResult(city: "Нижний Новгород", country: "RU"),
        SearchResult(city: "Челябинск", country: "RU"),
        SearchResult(city: "Омск", country: "RU"),
        SearchResult(city: "Самара", country: "RU"),
        SearchResult(city: "Ростов-на-Дону", country: "RU"),
        SearchResult(city: "Уфа", country: "RU"),
        SearchResult(city: "Красноярск", country: "RU")
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        searchResult = popularCities
        resultsTableView.reloadData()
    }
    
    func updateSearchResults(with query: String?) {
        guard let query,
              !query.isEmpty else {
            searchResult = popularCities
            resultsTableView.reloadData()
            return
        }
        if query.isEmpty {
            searchResult = popularCities
            resultsTableView.reloadData()
        } else {
            delegate?.didRequestSearch(for: query)
        }
    }
    
    func updateWithBackendResults(cities: [String], countries: [String]) {
        searchResult = zip(cities, countries).map({ city, country in
            SearchResult(city: city, country: country)
        })
        resultsTableView.reloadData()
    }
    
}

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return searchResult.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultsTableCell.cellIdentifier, for: indexPath) as? SearchResultsTableCell else {
            return UITableViewCell()
        }
        let result = searchResult[indexPath.row]
        cell.configure(city: result.city, country: result.country)
        return cell
    }
    
    func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath
    ) {
        tableView.deselectRow(at: indexPath, animated: false)
        let selectedCity = searchResult[indexPath.row].city
        delegate?.didSelectCity(selectedCity)
        dismiss(animated: true)
    }
    
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath
    ) -> CGFloat {
        50
    }
}

private extension SearchResultsViewController {
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(resultsTableView)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(dismissSelf)
        )
    }
    
    func setupTableView() {
        resultsTableView.frame = view.bounds
        resultsTableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        resultsTableView.register(SearchResultsTableCell.self, forCellReuseIdentifier: SearchResultsTableCell.cellIdentifier)
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        resultsTableView.keyboardDismissMode = .onDrag
    }
    
    @objc
    func dismissSelf() {
        dismiss(animated: true)
    }
}
