//
//  NetworkAPIClient.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 23.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation

public class APIClient {
    public init(configuration: Configuration?) {
        self.configuration = configuration
        self.reachabilityManager = ReachabilityManager(host: configuration?.serverAddress ?? "")
    }
    
    public func update(configuration: Configuration?) {
        self.configuration = configuration
        self.reachabilityManager = ReachabilityManager(host: configuration?.serverAddress ?? "")
    }
    
    public private(set) var configuration: Configuration?
    public private(set) var reachabilityManager: ReachabilityManager?
    lazy var analyzer = ResponseAnalyzer()
    lazy var session = URLSessionWrapper()
}

// MARK: URL manipulation.
extension APIClient {
    func URLComponents(strings: String ...) -> String {
        return strings.joined(separator: "/")
    }
    
    func fullURL(path: String) -> String {
        return URLComponents(strings: configuration?.serverAddress ?? "", path)
    }
}

// MARK: URLRequest manipulation.
extension APIClient {
    func createUrlRequest(method: HTTPMethod, url: URL, parameters: [String : AnyObject]?, requestSerializer: RequestSerializer = RequestSerializer.URLEncodedRequestSerializer()) -> URLRequest? {
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        
        guard let updatedRequest = try? requestSerializer.serialize(parameters: parameters, urlRequest: urlRequest) else {
            return nil
        }
        
        return updatedRequest
    }
}

// MARK: Execute command.
extension APIClient {
    func execute(urlRequest: URLRequest?, responseAnalizer: ResponseAnalyzer, onResponse: @escaping (Response) -> ()) {
        guard let request = urlRequest else {
            // maybe tell about error.
            onResponse(ErrorResponse(error: ErrorFactory.createError(errorType: .invalidRequest)!))
            return
        }
        
        guard let task = self.session.createTask(type: .data, request: request, completion: { (triplet) in
            
            // add correct mapping later.
            switch triplet {
            case .success(_, let data):
                onResponse(responseAnalizer.analyze(response: data, context: nil, error: nil) ?? ErrorResponse(error: ErrorFactory.createError(errorType: .unknown)!))
            case .error(_, let error):
                onResponse(responseAnalizer.analyze(response: nil, context: nil, error: error) ?? ErrorResponse(error: ErrorFactory.createError(errorType: .unknown)!))
            }
        }) else {
            // maybe tell about error.
            onResponse(ErrorResponse(error: ErrorFactory.createError(errorType: .invalidTask)!))
            return
        }
        
        session.addTask(task: task)
    }
    
    public func executeCommand(command: Command, onResponse: @escaping (Response) -> ()) {
        command.configuration = self.configuration
        let method = command.method
        let path = command.path
        let parameters = command.queryParameters()
        
        if let error = command.shouldStopError {
            onResponse(ErrorResponse(error: error))
            return
        }
        
        guard let url = URL(string: fullURL(path: path)) else {
            // error? malformed url string.
            return
        }
        
        let urlRequest = self.createUrlRequest(method: method, url: url, parameters: parameters)
        self.execute(urlRequest: urlRequest, responseAnalizer: self.analyzer, onResponse: onResponse)
    }
}

// MARK: Download item at URL.
extension APIClient {
    public func downloadAtUrl(url: URL?, onResponse: @escaping URLSessionWrapper.TaskCompletion) -> CancellationToken? {
        if let theUrl = url {
            guard let request = self.createUrlRequest(method: .get, url: theUrl, parameters: nil) else {
                let error = ErrorFactory.createError(errorType: .invalidRequest)
                onResponse(.error(nil, error))
                return nil
            }
            
            guard let task = self.session.createTask(type: .download, request: request, completion: { (triplet) in
                onResponse(triplet)
            }) else {
                let error = ErrorFactory.createError(errorType: .invalidTask)
                onResponse(.error(nil, error))
                return nil
            }
            self.session.addTask(task: task)
            return task
        }
        return nil
    }
}

// MARK: Tasks Management
extension APIClient {
    public func cancelAllTasks() {
        self.session.cancelAllTasks()
    }
}

// MARK: Cleanup
extension APIClient {
    public func cleanup() {
        self.cancelAllTasks()
        self.session.urlSession.invalidateAndCancel()
    }
}
