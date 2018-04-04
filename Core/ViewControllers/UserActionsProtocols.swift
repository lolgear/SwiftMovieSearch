//
//  UserActionsProtocols.swift
//  SwiftMovieSearch
//
//  Created by Lobanov Dmitry on 30.03.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import UIKit

protocol UserActionRequestSearchProtocol: class {
    func wantsToSearch(text: String, result: @escaping ResultClosure)
}

protocol UserActionResponseSearchProtocol: class {
    func willSearch(text: String)
    func didSearch(text: String, result: Result<Bool, Error>)
}

protocol UserActionRequestGetMoreDataProtocol: class {
    func wantsToGetMoreData(result: @escaping ResultClosure)
}

protocol UserActionResponseGetMoreDataProtocol: class {
    func willGetMoreData()
    func didGetMoreData(result: Result<(IndexSet), Error>)
}

protocol UserActionRequestGetMovieDetailsProtocol: class {
    func wantsToGetMovieDetails(movie: Movie?)
}

protocol UserActionResponseGetMovieDetailsProtocol: class {
    func willGetMovieDetails()
    func didGetMovieDetails(result: Result<Bool, Error>)
}

protocol UserActionResponseShowErrorProtocol: class {
    func showError(error: Error?)
    func showMessage(message: String?)
}
