//
//  MovieViewController.swift
//  SwiftMovieSearch
//
//  Created by Lobanov Dmitry on 29.03.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import UIKit

protocol MovieViewModel {
    func countOfElements() -> Int
    func detail(at index: Int) -> MovieViewController.Model.Detail?
}

class MovieViewController: UITableViewController {
    typealias TableViewCell = TitleSubtitleTableViewCell
    class Model: NSObject {
        struct Detail {
            var left: String
            var right: String
        }
        var movie: Movie!
        var dataSourceArray: [Detail]!
        init(movie: Movie){
            self.movie = movie
            super.init()
            self.setup()
        }
        
        weak var service: ServiceMoviesGetMovieDetailsProtocol?
        weak var responder: UserActionResponseGetMovieDetailsProtocol?
    }
    
    var model: Model?
    var imageView: UIImageView! // it is our header view.
    weak var getMovieDetailsRequest: UserActionRequestGetMovieDetailsProtocol?
}

// MARK: HasModelProtocol
extension MovieViewController: HasModelProtocol {
    typealias ModelType = Model
    func updateForNewModel() {
        // only one delegate?
        // reload data if needed?
        // put delegates here.
        self.model?.responder = self
        self.getMovieDetailsRequest = self.model
        // retrieve image somehow.
        self.title = self.model?.movie.title
    }
}

// MARK: Setup
extension MovieViewController {
    func setupShare() {
        // put later in ViewControllersService?
        let action = ViewControllersService.NavigationAction.ShareMovie().configured(url: self.model?.imdbUrl).configured(controller: ViewControllersService.service()?.rootViewController)
        ViewControllersService.service()?.currentRightActions = [action]
        self.navigationItem.rightBarButtonItem = action.barButton()
    }
    
    func setupUI() {
        self.setupTableView()
        self.setupRefresh()
        self.setupImageView()
        
        self.setupExternalTableViewComponents()
        self.setupShare()
    }
    
    func setupExternalTableViewComponents() {

        if self.viewIfLoaded != nil {
            // we need image view controller here.
            let frame = CGRect(x: 0, y: 0, width: 320, height: 250)
            GoldenRatio.size(width: frame.width)
            self.imageView.frame = frame
            self.tableView.tableHeaderView = self.imageView
        }
        
        self.requestImage()
    }
    
    func setupImageView() {
        if self.imageView == nil {
            self.imageView = UIImageView()
            self.imageView.contentMode = .scaleAspectFit
            self.imageView.clipsToBounds = true
        }
    }
    
    func requestImage() {
        MediaDeliveryService.service()?.mediaManager.imageAtUrl(url: self.model?.movie.imageUrl, { (theUrl, image) in
            DispatchQueue.main.async {
                if image != nil && theUrl != nil {
                    self.imageView.image = image
                }
            }
        })
    }

    
    func setupTableView() {
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 1
        
        // ImageView here.
        self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
        self.tableView.estimatedSectionHeaderHeight = 1
        self.tableView.register(TableViewCell.nib(), forCellReuseIdentifier: TableViewCell.cellReuseIdentifier())
        
        self.tableView.allowsSelection = false
    }
}

// MARK: Refreshing
extension MovieViewController {
    func setupRefresh() {
        let refresh = UIRefreshControl(frame: CGRect.zero)
        refresh.addTarget(self, action: #selector(MovieViewController.handleRefresh(_:)), for: .valueChanged)
        self.refreshControl = refresh
    }
    @objc func handleRefresh(_ refresh: UIRefreshControl?) {
        self.getMovieDetailsRequest?.wantsToGetMovieDetails(movie: self.model?.movie)
    }
}

// MARK: Activity
extension MovieViewController {
    func startSpinning() {
        self.refreshControl?.beginRefreshing()
    }
    func stopSpinning() {
        self.refreshControl?.endRefreshing()
    }
}

// MARK: View Lifecycle
extension MovieViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.handleRefresh(nil)
    }
}

// MARK: Error Handling.
extension MovieViewController {
    func handleError(error: Error?) {
        ViewControllersService.service()?.showError(error: error)
    }
}

// MARK: UserActionResponseGetMovieDetailsProtocol
extension MovieViewController: UserActionResponseGetMovieDetailsProtocol {
    func willGetMovieDetails() {
        // start spinning
        self.startSpinning()
    }
    
    func didGetMovieDetails(result: Result<Bool, Error>) {
        DispatchQueue.main.async {
            switch result {
            case .success(let _):
                self.tableView.reloadData()
                self.setupShare()
            case .error(let error):
                self.handleError(error: error)
                break
            default: break
            }
            self.stopSpinning()
        }
    }
}

// MARK: UITableViewDataSource
extension MovieViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.model?.countOfElements() ?? 0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.cellReuseIdentifier(), for: indexPath)
        
        if let thisCell = cell as? TableViewCell {
            // setup cell easily.
            let detail = self.model?.detail(at: indexPath.row)
            thisCell.leftLabel.text = detail?.left
            thisCell.rightLabel.text = detail?.right
        }
        return cell
    }
}

// MARK: UITableViewDelegate
extension MovieViewController {
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        return view
    }
}
