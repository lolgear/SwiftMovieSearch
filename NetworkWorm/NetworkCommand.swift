//
//  NetworkCommand.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 23.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
public enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

public class Command {
    
    public init() {}
    
    var shouldStopError: Error?
    
    var shouldStop: Bool {
        return shouldStopMessage != nil
    }
    
    var shouldStopMessage: String? {
        return shouldStopError?.localizedDescription
    }

    var configuration: Configuration? // assign somewhere before use.
    
    //MARK: Subclass
    var method: HTTPMethod = .get
    var path = ""
    var authorized = true
    func queryParameters() -> [String : AnyObject]? {
        return [:]
    }
}

// Endpoint : { /list }
// Params : {
//    "access_key" : "YOUR_ACCESS_KEY"
// }
public class APICommand: Command {
    override func queryParameters() -> [String : AnyObject]? {
        var result = super.queryParameters()
        guard configuration != nil else {
            shouldStopError = ErrorFactory.createError(errorType: .theInternal("Configuration did not set!" as AnyObject?))
            return result
        }
        result?["apikey"] = configuration?.apiAccessKey as AnyObject?
        return result
    }
}

// Endpoint : { / }
// Parameters: s ( search text )
// Example: http://www.omdbapi.com/?apikey=f60bbf23&s=result
public class MetadataSearchCommand: APICommand {
    var searchText: String
    var page: Int
    public init(searchText: String, page: Int) {
        self.searchText = searchText
        self.page = page
        super.init()
    }
    override func queryParameters() -> [String : AnyObject]? {
        if let parameters = super.queryParameters() {
            var theParameters = parameters
            theParameters["s"] = self.searchText as AnyObject
            theParameters["page"] = self.page as AnyObject
            return theParameters
        }
        return nil
    }
}

// Endpoint : { / }
// Parameters: i ( id )
// Example: http://www.omdbapi.com/?apikey=f60bbf23&i=tt3896198
public class DetailsComand: APICommand {
    var identifier: String
    public init(identifier: String) {
        self.identifier = identifier
    }
    override func queryParameters() -> [String : AnyObject]? {
        if let parameters = super.queryParameters() {
            var theParameters = parameters
            theParameters["i"] = self.identifier as AnyObject
            return theParameters
        }
        return nil
    }
}
