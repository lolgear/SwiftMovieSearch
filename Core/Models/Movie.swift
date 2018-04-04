//
//  Movie.swift
//  SwiftMovieSearch
//
//  Created by Lobanov Dmitry on 30.03.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
struct Movie {
    var imageUrl: URL?
    var title = ""
    var year = ""
    var id = ""
    var details = [String : AnyObject]()
}
