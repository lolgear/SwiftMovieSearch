//
//  DataProvider.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 24.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
import NetworkWorm

typealias MoviesResult = Result<([Movie], IndexSet), Error>
typealias MoviesResultClosure = (MoviesResult) -> ()

typealias MovieResult = Result<MoviesDataProvider.MovieResponse, Error>
typealias MovieResultClosure = (MovieResult) -> ()

protocol ServiceMoviesSearchProtocol: class {
    func wantsToSearch(text: String, onResponse: @escaping MoviesResultClosure)
}

protocol ServiceMoviesGetMoreDataProtocol: class {
    func wantsToGetMoreData(onResponse: @escaping MoviesResultClosure)
}

protocol ServiceMoviesGetMovieDetailsProtocol: class {
    func wantsToGetMovieDetails(id: String, onResponse: @escaping MovieResultClosure)
}

class MoviesDataProvider {
    enum Errors {
        static let domain = "org.opensource.swift_search_movie.data_provider.movies"
        case invalidEmptyResult
        case errorIsNil
        case assertionFailure(String)
        case invalidEmptySearchText
        case noMoreDataAvaiable
        var code: Int {
            switch self {
            case .invalidEmptyResult: return -100
            case .errorIsNil: return -101
            case .assertionFailure(_): return -102
            case .invalidEmptySearchText: return -103
            case .noMoreDataAvaiable: return -104
            }
        }
        var message: String {
            switch self {
            case .invalidEmptyResult: return "Invalid empty result!"
            case .errorIsNil: return "Error is nil! Somehow..."
            case .assertionFailure(let value): return "Assertion failure! Description: \(String(describing: value))"
            case .invalidEmptySearchText: return "Invalid empty search text!"
            case .noMoreDataAvaiable: return "No more data available!"
            }
        }
        var error: Error {
            return NSError(domain: type(of: self).domain, code: self.code, userInfo: [NSLocalizedDescriptionKey : self.message])
        }
    }
    
    class SearchRequest {
        var text: String = ""
    }
    
    var searchRequest = SearchRequest()
    var list = PagedList<Movie>()
}

// MARK: HasMoviesDataSource
extension MoviesDataProvider: HasMoviesDataSource {}

// MARK: PerformSearch
extension MoviesDataProvider {
    struct MoviesReponse {
        static func serialize(movie: SearchMoviesResponse.Movie) -> Movie {
            return Movie(imageUrl: movie.poster, title: movie.title, year: movie.year, id: movie.id, details: [:])
        }
        var results: [Movie]
        var totalCount: Int
    }
    
    func performSearch(searchText: String = "", page: Int, onResponse: @escaping (Result<MoviesReponse, Error>) -> ()) {
        NetworkService.service()?.performSearch(searchText: self.searchRequest.text, page: page, onResponse: { (response) in
            switch response {
            case let result as ErrorResponse:
                let error = result.descriptiveError ?? Errors.errorIsNil.error
                LoggingService.logDebug("got error \(String(describing: error))")
                onResponse(.error(error))
                return
            case let result as SearchMoviesResponse:
                let results = result.results
                let totalCount = result.totalCount
                let response = MoviesReponse(results: results.map { MoviesReponse.serialize(movie: $0) }, totalCount: totalCount)
                LoggingService.logDebug("got results \(String(describing: response))")
                onResponse(.success(response))
                return
            default:
                return
            }
        })
    }
}

// MARK: Find Movie
extension MoviesDataProvider {
    struct MovieResponse {
        var details: [String : AnyObject]
    }
    
    func indexOfMovie(id: String, list:[Movie]) -> Int? {
        return self.list.list.index { (movie) -> Bool in
            movie.id == id
        }
    }

    func updateMovie(id: String, movieResult: (Movie) -> Movie) {
        guard let index = self.indexOfMovie(id: id, list: self.list.list) else {
            return
        }

        if self.list.list.endIndex > index {
            let movie = self.list.list[index]
            self.list.list[index] = movieResult(movie)
        }
    }
    func movie(id: String) -> Movie? {
        guard let index = self.indexOfMovie(id: id, list: self.list.list) else {
            return nil
        }
        return self.list.list[index]
    }
    
    func findMovie(id: String, onResponse: @escaping (Result<MovieResponse, Error>) -> ()) {
        if let movie = self.movie(id: id), !movie.details.isEmpty {
            LoggingService.logDebug("Movie: '\(movie.title)' (imDB: \(movie.id)) cached!")
            let response = MovieResponse(details: movie.details)
            onResponse(.success(response))
        }
        else {
        NetworkService.service()?.findMovie(id: id, onResponse: { (response) in
            switch response {
            case let result as ErrorResponse:
                let error = result.descriptiveError ?? Errors.errorIsNil.error
                LoggingService.logDebug("got error \(String(describing: error))")
                onResponse(.error(error))
            case let result as MovieDetailsResponse:
                let details = result.details.details
                let response = MovieResponse(details: details)
                // cache movie also.
                self.updateMovie(id: id, movieResult: { (movie) -> Movie in
                    var theMovie = movie
                    theMovie.details = details
                    return theMovie
                })
                onResponse(.success(response))
            default: return
            }
        })
    }
    }
}

// MARK: MoviesResponse
extension MoviesDataProvider.MoviesReponse: CustomDebugStringConvertible {
    var debugDescription: String {
        return ["results": self.results, "totalCount": self.totalCount].debugDescription
    }
}

// MARK: MovieResponse
extension MoviesDataProvider.MovieResponse: CustomDebugStringConvertible {
    var debugDescription: String {
        return ["details": self.details].debugDescription
    }
}

// MARK: ServiceMoviesSearchProtocol
extension MoviesDataProvider: ServiceMoviesSearchProtocol {
    func wantsToSearch(text: String, onResponse: @escaping MoviesResultClosure) {
        self.searchRequest.text = text

        guard !self.searchRequest.text.isEmpty else {
            onResponse(.error(Errors.invalidEmptySearchText.error))
            return
        }
        
        // cancel operations.
        // and perform search.
        // reset results on completion.
        // page is always zero, cause we have new search.
        self.performSearch(page: self.list.currentPage) { (result) in
            switch result {
            case .success(let value):
                let values = value.results
                self.list.reset()
                self.list.update(totalCount: value.totalCount)
                let range = self.list.append(incoming: values)
                let indexSet = IndexSet(integersIn: range)
                let val = (values, indexSet)
                onResponse(.success(val))
            case .error(let error):
                onResponse(.error(error))
            }
        }
    }
}

// MARK: ServiceMoviesGetMoreDataProtocol
extension MoviesDataProvider: ServiceMoviesGetMoreDataProtocol {
    func wantsToGetMoreData(onResponse: @escaping MoviesResultClosure) {
        guard !self.searchRequest.text.isEmpty else {
            onResponse(.error(Errors.invalidEmptySearchText.error))
            return
        }
        if self.list.hasMore {
            self.performSearch(page: self.list.currentPage) { (result) in
                switch result {
                case .success(let value):
                    let values = value.results
                    let range = self.list.append(incoming: values)
                    let indexSet = IndexSet(integersIn: range)
                    let val = (values, indexSet)
                    onResponse(.success(val))
                    return
                case .error(let error):
                    onResponse(.error(error))
                    return
                }
            }
        }
        else {
            onResponse(.error(Errors.noMoreDataAvaiable.error))
        }
    }
}

// MARK: ServiceMoviesGetMovieDetailsProtocol
extension MoviesDataProvider: ServiceMoviesGetMovieDetailsProtocol {
    func wantsToGetMovieDetails(id: String, onResponse: @escaping MovieResultClosure) {
        self.findMovie(id: id, onResponse: onResponse)
    }
}

// MARK: Create
extension MoviesDataProvider {
    class func create() -> Self {
        return self.init()
    }
}
