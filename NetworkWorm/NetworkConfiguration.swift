//
//  NetworkConfiguration.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 23.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
public struct Configuration {
    public var serverAddress = ""
    public var apiAccessKey = ""
    fileprivate static var apiServerAddress = "https://www.omdbapi.com/"
    
    public init(serverAddress: String, apiAccessKey: String) {
        self.serverAddress = serverAddress
        self.apiAccessKey = apiAccessKey
    }
    public static func api(apiAccessKey: String) -> Configuration {
        return self.init(serverAddress: apiServerAddress, apiAccessKey: apiAccessKey)
    }
}
