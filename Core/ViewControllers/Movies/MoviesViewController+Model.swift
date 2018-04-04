//
//  MoviesViewController+Model.swift
//  SwiftMovieSearch
//
//  Created by Lobanov Dmitry on 30.03.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import UIKit

// MARK: Setup
extension MoviesViewController.Model {
    func configured(dataSource: HasMoviesDataSource?) -> Self {
        self.dataSource = dataSource
        return self
    }
    func configured(moreDataService: ServiceMoviesGetMoreDataProtocol?) -> Self {
        self.getMoreDataService = moreDataService
        return self
    }
    func configured(movieDeails: ServiceMoviesGetMovieDetailsProtocol?) -> Self {
        self.getMovieDetailsService = movieDeails
        return self
    }
}

// MARK: ServiceGetMoreDataProtocol
extension MoviesViewController.Model: UserActionRequestGetMoreDataProtocol {
    func wantsToGetMoreData(result: @escaping ResultClosure) {
        // Service wants to get more data?
        // request for more data.
        // asks service about it.
        self.getMoreDataActionResponder?.willGetMoreData()
        self.getMoreDataService?.wantsToGetMoreData(onResponse: { (result) in
            switch result {
            case .success(let value):
                // we should know how to get more data.
                self.getMoreDataActionResponder?.didGetMoreData(result: .success(value.1))
                return
            case .error(let error):
                self.getMoreDataActionResponder?.didGetMoreData(result: .error(error))
            }
        })
    }
}

// MARK: UITableViewDataSource
extension MoviesViewController.Model: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource?.list.currentCount ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "", for: indexPath)
    }
}

// MARK: MoviesViewModel
extension MoviesViewController.Model: MoviesViewModel {
    func countOfElements() -> Int {
        return self.dataSource?.list.currentCount ?? 0
    }
    
    func movie(at index: Int) -> Movie? {
        return self.dataSource?.at(index: index)
    }
    
    func movieDetails(at index: Int) -> MovieViewController.Model? {
        guard let movie = self.dataSource?.at(index: index) else {
            return nil
        }
        let model = MovieViewController.Model(movie: movie)
        return model
//            let viewController = MovieViewController(style: .grouped).configured(model: model)
//            result = viewController
    }
}
