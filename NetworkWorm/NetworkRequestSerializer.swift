//
//  NetworkRequestSerializer.swift
//  NetworkWorm
//
//  Created by Lobanov Dmitry on 29.03.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
class RequestSerializer {
    func serialize(command: Command, urlRequest: URLRequest) throws -> URLRequest? {
        return nil
    }
    
    func serialize(parameters: [String : AnyObject]?, urlRequest: URLRequest) throws -> URLRequest? {
        return nil
    }
    
    func check(command: Command) throws {
        if let error = command.shouldStopError {
            throw error
        }
    }
    
    class URLEncodedRequestSerializer: RequestSerializer {
        func parametersToString(parameters: [String : AnyObject]) -> String {
            return parameters.map { return "\($0.key)=\($0.value)" }.joined(separator: "&")
        }
        
        override func serialize(parameters: [String : AnyObject]?, urlRequest: URLRequest) throws -> URLRequest? {
            guard let url = urlRequest.url, var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                return nil
            }
            
            if let theParameters = parameters {
                urlComponents.query = self.parametersToString(parameters: theParameters)
            }
            
            var theRequest = urlRequest
            theRequest.url = urlComponents.url
            return theRequest
        }
        
        override func serialize(command: Command, urlRequest: URLRequest) throws -> URLRequest? {
            try check(command: command)
            guard let url = urlRequest.url, var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                return nil
            }
            
            urlComponents.query = self.parametersToString(parameters: command.queryParameters()!)
            
            var theRequest = urlRequest
            theRequest.url = urlComponents.url
            return urlRequest
        }
    }
    
    class OnlyURLRequestSerializer: RequestSerializer {
        override func serialize(command: Command, urlRequest: URLRequest) throws -> URLRequest? {
            return urlRequest
        }
        override func serialize(parameters: [String : AnyObject]?, urlRequest: URLRequest) throws -> URLRequest? {
            return urlRequest
        }
    }
}
