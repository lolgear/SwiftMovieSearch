//
//  Result.swift
//  SwiftMovieSearch
//
//  Created by Lobanov Dmitry on 30.03.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation

public enum Result<Result, Error> {
    case success(Result)
    case error(Error)
}

typealias ResultClosure = (Result<Bool, Error>) -> ()
