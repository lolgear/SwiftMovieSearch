//
//  NetworkResponse.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 23.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation

// Maybe declare as protocol?
public protocol ResponseProtocol {
    var data: Data? {get set}
    var url: URL? {get set}
}

public class DataResponse {
    
}

public class Response {
    public typealias DictionaryPayloadType = [String : AnyObject]
    var dictionary: DictionaryPayloadType = [:]
    public init?(dictionary: DictionaryPayloadType) {
        self.dictionary = dictionary
    }
}

public class SuccessResponse: Response {
    public override init?(dictionary: DictionaryPayloadType) {
        super.init(dictionary: dictionary)
        guard let response = dictionary["Response"] as? String, response == "True" else {
            return nil
        }
    }
    
    class func blessed(dictionary: DictionaryPayloadType) -> SuccessResponse? {
        // register and determine?
        if let result = SearchMoviesResponse(dictionary: dictionary) {
            return result
        }
        if let result = MovieDetailsResponse(dictionary: dictionary) {
            return result
        }
        return nil
    }
    
    func blessed() -> SuccessResponse? {
        return SuccessResponse.blessed(dictionary: self.dictionary)
    }
}

//{
//    "Search": [
//    {
//    "Title": "The Same Result",
//    "Year": "2006",
//    "imdbID": "tt0819631",
//    "Type": "movie",
//    "Poster": "N/A"
//    }
//    ],
//    "totalResults": "17",
//    "Response": "True"
//}
public class SearchMoviesResponse: SuccessResponse {
    public struct Movie {
        // items here.
        public var title: String
        public var year: String
        public var id: String
        public var type: String
        public var poster: URL?
        func sanitize(string: String?) -> String {
            if let theString = string {
                switch theString {
                case "N/A":
                    return ""
                default:
                    return theString
                }
            }
            return ""
        }
        init(dictionary: [String: String]) {
            self.title = dictionary["Title"] ?? ""
            self.year = dictionary["Year"] ?? ""
            self.id = dictionary["imdbID"] ?? ""
            self.type = dictionary["Type"] ?? ""
            
            let urlString = self.sanitize(string: dictionary["Poster"])
            self.poster = URL(string: urlString)
        }
    }
    public var totalCount = 0
    public var results = [Movie]()
    public override init?(dictionary: DictionaryPayloadType) {
        super.init(dictionary: dictionary)
        
        guard dictionary["Search"] != nil else {
            return nil
        }
        
        guard let items = dictionary["Search"] as? [[String: String]] else {
            return nil
        }
        
        self.results = items.map { Movie(dictionary: $0) }
        if let totalCount = dictionary["totalResults"] as? String {
            self.totalCount = Int(totalCount) ?? self.results.count
        }
    }
}

public class MovieDetailsResponse: SuccessResponse {
    // maybe we need one structure only and later fill Movie details?
    public struct Details {
        public var poster: URL?
        public var details: [String: AnyObject] = [:]
        // other details
        func sanitize(string: String?) -> String {
            if let theString = string {
                switch theString {
                case "N/A":
                    return ""
                default:
                    return theString
                }
            }
            return ""
        }
        init(dictionary: [String: AnyObject]) {
            var theDictionary = dictionary
//            let urlString = self.sanitize(string: dictionary["Poster"] as? String)
//            self.poster = URL(string: urlString)
            theDictionary.removeValue(forKey: "Poster")
            self.details = theDictionary
        }
    }
    
    public var details: Details!
    public override init?(dictionary: DictionaryPayloadType) {
        super.init(dictionary: dictionary)
        self.details = Details(dictionary: dictionary)
    }
}

//{
//    "Error": "Error Description"
//    "Response": "False"
//}
public class ErrorResponse : Response {
    var code: Int = 0
    var info = ""
    var error: Error?
    public var descriptiveError : Error? {
        return error ?? NSError(domain: ErrorFactory.Errors.domain, code: code, userInfo: [NSLocalizedDescriptionKey : info])
    }
    
    public init(error: Error) {
        super.init(dictionary: [:])!
        self.error = error
    }
    
    public override init?(dictionary: DictionaryPayloadType) {
        super.init(dictionary: dictionary)
        
        guard let response = dictionary["Response"] as? String, response == "False" else {
            return nil
        }
        
        guard let error = dictionary["Error"] as? String else {
            return nil
        }
        
        // now error is string.
        self.info = error
        self.code = -99
    }
}
