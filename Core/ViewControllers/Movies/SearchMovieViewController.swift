//
//  SearchMovieViewController.swift
//  SwiftMovieSearch
//
//  Created by Lobanov Dmitry on 30.03.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import UIKit

class SearchMovieCompanion: NSObject {
    class Model: NSObject {
        var text: String?
        // Pagination here?.
        // not, not here.
        // even not in model.
        // pagination exists only in DataProvider.
        // as title.
        // delegate "want user action :/"
        
        // notify service about it.
        weak var delegate: UserActionResponseSearchProtocol?
        weak var service: ServiceMoviesSearchProtocol?
    }
    
    var model: Model?
    lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.definesPresentationContext = true
        controller.hidesNavigationBarDuringPresentation = false
        controller.dimsBackgroundDuringPresentation = false
        return controller
    }()
    
    override init() {}
}

// MARK: HasModelProtocol
extension SearchMovieCompanion: HasModelProtocol {
    func updateForNewModel() {
        // nothing here.
        self.searchController.searchBar.delegate = self.model
    }
    typealias ModelType = Model
}

// MARK: Configuration
extension SearchMovieCompanion.Model {
    func configured(service: ServiceMoviesSearchProtocol?) -> Self {
        self.service = service
        return self
    }
}

extension SearchMovieCompanion.Model: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.text = ""
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {        
        // ho-ho, new feature :3
        // 1. they are equal.
        
        if let searchText = searchBar.text, self.text != searchText {
            self.text = searchText
            self.delegate?.willSearch(text: searchText)
            self.service?.wantsToSearch(text: searchText, onResponse: { (result) in
                switch result {
                case .success(let result):
                    self.delegate?.didSearch(text: searchText, result: .success(!result.1.isEmpty))
                    return
                case .error(let error):
                    self.delegate?.didSearch(text: searchText, result: .error(error))
                    return
                }
            })
        }
        else {
            LoggingService.logDebug("Search: previous: \(String(describing: self.text)) \(self.text == searchBar.text ? "==" : "!=") current: \(String(describing: searchBar.text))")
        }
    }
}
