//
//  MoviesViewController.swift
//  SwiftMovieSearch
//
//  Created by Lobanov Dmitry on 30.03.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import UIKit

protocol HasMoviesDataSource: class {
    var list: PagedList<Movie> { get }
}

extension HasMoviesDataSource {
    func at(index: Int) -> Movie? {
        return self.list.list[index]
    }
}

protocol MoviesViewModel: class {
    func countOfElements() -> Int
    func movie(at index: Int) -> Movie?
    func movieDetails(at index: Int) -> MovieViewController.Model?
}

enum MoviesViewModelUpdatesType {
    case insert
    case delete
    case update
}

protocol MoviesViewModelUpdates: class {
    func willUpdate(model: Self)
    func updateItems(mode: Self, indexSet: IndexSet, type: MoviesViewModelUpdatesType)
    func didUpdate(model: Self)
}

class MoviesViewController: BaseTableViewController {
    class Model: NSObject {
        weak var dataSource: HasMoviesDataSource?
        weak var getMoreDataService: ServiceMoviesGetMoreDataProtocol?
        weak var getMoreDataActionResponder: UserActionResponseGetMoreDataProtocol?
        
        // for Movie.Model
        weak var getMovieDetailsService: ServiceMoviesGetMovieDetailsProtocol?
    }
    
    var model: Model?
    var searchCompanion: SearchMovieCompanion?
    // model? but do we want another reference to it?
    weak var getMoreDataRequest: UserActionRequestGetMoreDataProtocol?
    var notification = NotificationViewController()
    
}

// MARK: HasModelProtocol
extension MoviesViewController: HasModelProtocol {
    typealias ModelType = Model
    func updateForNewModel() {
        self.model?.getMoreDataActionResponder = self
        self.getMoreDataRequest = self.model
    }
}

// MARK: Configuration
extension MoviesViewController {
    func configured(search: SearchMovieCompanion) -> MoviesViewController {
        self.searchCompanion = search
        self.searchCompanion?.model?.delegate = self
        return self
    }
    
    override func setupController() {
        super.setupController()
        self.title = "Search movies"
    }
    
    override func setupUI() {
        super.setupUI()
        self.setupExternalTableViewComponents()
    }
    
    override func setupDataSources() {
        self.tableViewDelegate = self
        self.tableViewDataSource = self
        super.setupDataSources()
    }
    
    func setupExternalTableViewComponents() {
        if self.viewIfLoaded != nil {
            self.tableView.tableHeaderView = self.searchCompanion?.searchController.searchBar
            let activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            self.tableView.tableFooterView = activity
        }
    }
    
    override func setupTableView() {
        super.setupTableView()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 92
        self.tableView.sectionHeaderHeight = 0
        self.tableView.register(MoviePreviewTableViewCell.nib(), forCellReuseIdentifier: MoviePreviewTableViewCell.cellReuseIdentifier())
    }
}

// MARK: View Lifecycle
extension MoviesViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.setupUI()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.setupExternalTableViewComponents()
//    }
    
    func cleanupBeforeLeave() {
        self.searchCompanion?.searchController.dismiss(animated: true, completion: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.searchCompanion?.searchController.dismiss(animated: true, completion: {
        })
    }
}

// MARK: Controller routing
extension MoviesViewController {
    func navigateToController(viewController: UIViewController) {
        if self.searchCompanion?.searchController.isActive == true {
            self.searchCompanion?.searchController.dismiss(animated: true, completion: {
                self.navigationController?.pushViewController(viewController, animated: true)
            })
        }
        else {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

// MARK: Spinning.
extension MoviesViewController {
    func activityIndicator() -> UIActivityIndicatorView? {
        return (self.tableView.tableFooterView as? UIActivityIndicatorView)
    }
    func startSpinning() {
        self.activityIndicator()?.startAnimating()
    }
    func stopSpinning() {
        self.activityIndicator()?.stopAnimating()
    }
}

// MARK: Error Handling.
extension MoviesViewController {
    func handleError(error: Error?) {
        ViewControllersService.service()?.showError(error: error)
    }
}

// MARK: UserActionResponseSearchProtocol
extension MoviesViewController: UserActionResponseSearchProtocol {
    func willSearch(text: String) {
        // start refresh?
    }
    
    func didSearch(text: String, result: Result<Bool, Error>) {
        DispatchQueue.main.async {
            switch result {
            case .success(let _):
                self.tableView.reloadData()
            case .error(let error):
                self.handleError(error: error)
            }
        }
    }
}

// MARK: UserActionGetMoreDataProtocol
extension MoviesViewController: UserActionResponseGetMoreDataProtocol {
    func didGetMoreData(result: Result<(IndexSet), Error>) {
        DispatchQueue.main.async {
            switch result {
            case .success(let success):
                if !success.isEmpty {
                    let indexSet = success
                    let indexPaths = indexSet.map {IndexPath(row: $0, section: 0)}
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: indexPaths, with: .automatic)
                    self.tableView.endUpdates()
                }
            case .error(let error):
                self.handleError(error: error)
                // show error
            }
            self.stopSpinning()
        }
    }
    
    func willGetMoreData() {
        // start spinning.
        DispatchQueue.main.async {
            self.startSpinning()
        }
    }

    func didGetMoreData(result: Result<Bool, Error>) {
        DispatchQueue.main.async {
            switch result {
            case .success(let success):
                // stop spinning
                if success {
                    self.tableView.reloadData()
                }
            case .error(let error):
                // stop spinning
                self.handleError(error: error)
                // show error
            }
            self.stopSpinning()
        }
    }
}

// MARK:
extension MoviesViewController: MoviesViewModelUpdates {
    func willUpdate(model: MoviesViewController) {
        self.tableView.beginUpdates()
    }
    
    func updateItems(mode: MoviesViewController, indexSet: IndexSet, type: MoviesViewModelUpdatesType) {
        let indexPaths = indexSet.map {IndexPath(row: $0, section: 0)}
        switch type {
        case .delete:
            self.tableView.deleteRows(at: indexPaths, with: .automatic)
        case .insert:
            self.tableView.insertRows(at: indexPaths, with: .automatic)
        case .update:
            self.tableView.reloadRows(at: indexPaths, with: .automatic)
        }
    }
    
    func didUpdate(model: MoviesViewController) {
        self.tableView.endUpdates()
    }
}

// MARK: UITableViewDataSource
extension MoviesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.model?.countOfElements() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        LoggingService.logDebug("cell at: \(String(describing: indexPath))")
        let cell = tableView.dequeueReusableCell(withIdentifier: MoviePreviewTableViewCell.cellReuseIdentifier(), for: indexPath)
        if let theCell = cell as? MoviePreviewTableViewCell {
            let item = self.model?.movie(at: indexPath.row)
            LoggingService.logDebug("title: \(item?.title) and imageUrl:\(item?.imageUrl)")
            // which item?
            // it should be what?
            let model = MoviePreviewTableViewCell.Model().configured(movie: item)
            _ = theCell.configured(model: model)
            _ = theCell.model?.configured(mediaManager: MediaDeliveryService.service()?.mediaManager).configured(url: item?.imageUrl)
        }
        return cell
    }
}

// MARK: UITableViewDelegate
extension MoviesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // tell that we want to see movie at index path.
//        let error =
//        NSError(domain: "123", code: 100, userInfo: [NSLocalizedDescriptionKey: "Something went wrong"])
//        self.handleError(error: error)
//        return
        if let movie = self.model?.movie(at: indexPath.row) {
            let model = MovieViewController.Model(movie: movie).configured(service: self.model?.getMovieDetailsService)
            let viewController = MovieViewController(style: .grouped).configured(model: model)
            self.navigateToController(viewController: viewController)
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let shouldStartRefresh = scrollView.contentOffset.y + scrollView.frame.size.height == scrollView.contentSize.height
        if (shouldStartRefresh) {
            // start refresh.
            self.getMoreDataRequest?.wantsToGetMoreData(result: { (result) in
                // we don't need it, other methods will be called.
                // or maybe we want it? not sure...
            })
        }
    }
}
