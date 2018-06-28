//
//  NetworkService.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 24.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import NetworkWorm
import Foundation

protocol NetworkReachabilityObservingProtocol: class {
    func didChangeState(state: Bool)
}

class NetworkService: BaseService {
    var client: APIClient!
    weak var reachabilityObserving: NetworkReachabilityObservingProtocol?
    fileprivate func clientConfiguration() -> Configuration {
        return Configuration.api(apiAccessKey: ApplicationSettingsStorage.loaded().networkAPIKey)
    }
}

extension NetworkService {
    override var health: Bool {
        return client.reachabilityManager?.reachable ?? false
    }
}

extension NetworkService {
    override func setup() {
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
        client = APIClient(configuration: clientConfiguration())
        client.reachabilityManager?.startMonitoring()
        client.reachabilityManager?.startObserving(observing: { (status) in
            LoggingService.logDebug("status: \(status)")
            self.reachabilityObserving?.didChangeState(state: status)
        })
    }
    
    override func tearDown() {
        self.client.cleanup()
    }
}

// MARK: Reaction on settings did updated.
extension NetworkService {
    func updateClient() {
        let configuration = clientConfiguration()
        LoggingService.logVerbose("\(self) \(#function) reload configuration: \(configuration)")
        client.update(configuration: configuration)
    }
}

// MARK: API Requests.
// Could be adopted to protocols if needed.
// downloadResource is from protocol from media manager.
// and performSearch is from protocol from data provider.
extension NetworkService {
    func performSearch(searchText: String, page: Int, onResponse: @escaping(Response) -> ()) {
        let command = MetadataSearchCommand(searchText: searchText, page: page)
        self.client.executeCommand(command: command, onResponse: onResponse)
    }
    
    func downloadResourceAtUrl(url: URL?, onResponse: @escaping URLSessionWrapper.TaskCompletion) -> NetworkWorm.CancellationToken? {
        return self.client.downloadAtUrl(url: url, onResponse: onResponse)
    }
    
    func findMovie(id: String, onResponse: @escaping (Response) -> ()) {
        let command = DetailsComand(identifier: id)
        self.client.executeCommand(command: command, onResponse: onResponse)
    }
}
