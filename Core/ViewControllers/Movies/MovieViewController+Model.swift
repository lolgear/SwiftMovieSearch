//
//  MovieViewController+Model.swift
//  SwiftMovieSearch
//
//  Created by Lobanov Dmitry on 29.03.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import UIKit

// MARK: Convenience Getters
extension MovieViewController.Model {
    var imdbUrl: URL? {
        return URL(string: self.dataSourceArray.filter{$0.left == "imdbUrl"}.map{$0.right}.first ?? "")
    }
}
// MARK: Setup
extension MovieViewController.Model {
    func arrayFrom(dictionary: [String : AnyObject]) -> [Detail] {
        return dictionary.map { (pair) in
            return Detail(left: pair.key, right: (pair.value as? CustomStringConvertible)?.description ?? "")
        }
    }
    
    func sanitize(details: [String : AnyObject]) -> [String : AnyObject] {
        var theDetails = details
        if let ratings = details["Ratings"] as? [[String: String]] {
            //[{
            // Source: ""
            // Value: ""
            //}]
            theDetails["Ratings"] = ratings.compactMap { item in
                guard let key = item["Source"], let value = item["Value"] else {
                    return nil
                }
                return [key, value].joined(separator: " ")
                }.joined(separator: "\n") as AnyObject
        }
        
        if let imbdId = details["imdbID"] as? String {
            theDetails["imdbUrl"] = ("http://www.imdb.com/title/" + imbdId) as AnyObject
        }
        
        return theDetails
    }
    
    func setup(details: [String : AnyObject]) {
        let details = self.sanitize(details: details)
        self.dataSourceArray = self.arrayFrom(dictionary: details)
    }
    
    func setup() {
        self.setup(details: self.movie.details)
    }
    func configured(service: ServiceMoviesGetMovieDetailsProtocol?) -> Self {
        self.service = service
        return self
    }
}

// MARK: MovieViewModel
extension MovieViewController.Model: MovieViewModel {
    func countOfElements() -> Int {
        return self.dataSourceArray.count
    }
    
    func detail(at index: Int) -> MovieViewController.Model.Detail? {
        return self.dataSourceArray[index]
    }
}

// MARK: UserActionRequestGetMovieDetailsProtocol
extension MovieViewController.Model: UserActionRequestGetMovieDetailsProtocol {
    func wantsToGetMovieDetails(movie: Movie?) {
        guard self.countOfElements() == 0 else {
            self.responder?.didGetMovieDetails(result: .success(!self.movie.details.isEmpty))
            return
        }
        
        self.responder?.willGetMovieDetails()
        self.service?.wantsToGetMovieDetails(id: self.movie.id, onResponse: { (result) in
            switch result {
            case .success(let value):
                // TODO: put in cache if needed?
                self.setup(details: value.details)
                self.responder?.didGetMovieDetails(result: .success(!value.details.isEmpty))
            case .error(let error):
                self.responder?.didGetMovieDetails(result: .error(error))
            }
        })
    }
}
