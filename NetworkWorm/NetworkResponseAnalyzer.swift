//
//  NetworkResponseAnalyzer.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 24.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation

protocol ResponseSerializer {
    associatedtype DesiredOutput
    func serialize(data: Data) throws -> DesiredOutput?
}

class ResponseAnalyzer {
    enum contextKeys: String {
        case reachable
    }
    
    class JSONSerializer: ResponseSerializer {
        typealias DesiredOutput = [String : AnyObject]
        func serialize(data: Data) throws -> DesiredOutput? {
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? DesiredOutput
        }
    }
    
    class XMLSerializer: ResponseSerializer {
        typealias DesiredOutput = [String : AnyObject]
        func serialize(data: Data) throws -> DesiredOutput? {
            return nil
        }
    }
    
    // response serializer
    var serializer = JSONSerializer()
    
    init() {}
}

//MARK: analyzing
extension ResponseAnalyzer {
    typealias DesiredOutput = JSONSerializer.DesiredOutput
    
    // analyze response
    func analyze(response: DesiredOutput, context: [String : AnyObject]?) -> Response? {
        return SuccessResponse(dictionary: response)?.blessed() ?? ErrorResponse(dictionary: response)
    }
    
    func analyze(response: Data?, context:[String : AnyObject]?, error: Error?) -> Response? {
        guard error == nil else {
            return ErrorResponse(error: error!)
        }
        
        guard let theResponse = response else {
            return ErrorResponse(error: ErrorFactory.createError(errorType: .responseIsEmpty)!)
        }
        
        guard let responseObject = try? serializer.serialize(data: theResponse) else {
            return ErrorResponse(error: ErrorFactory.createError(errorType: .couldNotParse(theResponse as AnyObject?))!)
        }
        return self.analyze(response: responseObject!, context: context)
    }
}
