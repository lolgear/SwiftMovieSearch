//
//  DataProviderService.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 27.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
import UIKit

class DataProviderService: BaseService {
    lazy var dataProvider = MoviesDataProvider.create()
    override var health: Bool {
        return true
    }
    var timer: Timer?
    func startTimer() {}
    func stopTimer() {}
}

extension DataProviderService {
    override func tearDown() {
        stopTimer()
    }
}

extension DataProviderService {
    var updateTimeInterval: TimeInterval { return ApplicationSettingsStorage.loaded().updateTime }
    var backgroundFetchEnabled: Bool { return ApplicationSettingsStorage.loaded().backgroundFetch }
}

extension DataProviderService {

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard backgroundFetchEnabled else {
            return
        }
    }
    func applicationWillTerminate(_ application: UIApplication) {
        stopTimer()
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        startTimer()
    }
    func applicationWillResignActive(_ application: UIApplication) {
        stopTimer()
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        stopTimer()
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        startTimer()
    }
}

class DataProviderServiceWithTimer: DataProviderService {
    override func startTimer() {
        guard timer == nil else {
            LoggingService.logVerbose("timer already started!")
            return
        }
        
        LoggingService.logVerbose("timer started with interval(\(String(describing: DateComponentsFormatters.stringFromTimeInterval(interval: updateTimeInterval))))")
        timer = Timer.scheduledTimer(withTimeInterval: updateTimeInterval, repeats: true) {
            [unowned self]
            (timer) in
            LoggingService.logVerbose("timer fired!")
        }
    }
    override func stopTimer() {
        LoggingService.logVerbose("timer invalidated!")
        timer?.invalidate()
        timer = nil
    }
}

class DebugDataProviderService: DataProviderService {
    override func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        LoggingService.logVerbose("\(self) \(#function) perform background fetch!")
        
        guard backgroundFetchEnabled else {
            LoggingService.logVerbose("\(self) \(#function) background fetch disabled!")
            return
        }
        super.application(application, performFetchWithCompletionHandler: completionHandler)
    }
    override func applicationWillTerminate(_ application: UIApplication) {
        LoggingService.logVerbose("\(self) \(#function) stop timer!")
        super.applicationWillTerminate(application)
    }
    override func applicationDidBecomeActive(_ application: UIApplication) {
        LoggingService.logVerbose("\(self) \(#function) start timer!")
        super.applicationDidBecomeActive(application)
    }
    override func applicationWillResignActive(_ application: UIApplication) {
        LoggingService.logVerbose("\(self) \(#function) stop timer!")
        super.applicationWillResignActive(application)
    }
    override func applicationDidEnterBackground(_ application: UIApplication) {
        LoggingService.logVerbose("\(self) \(#function) stop timer!")
        super.applicationDidEnterBackground(application)
    }
    override func applicationWillEnterForeground(_ application: UIApplication) {
        LoggingService.logVerbose("\(self) \(#function) start timer!")
        super.applicationWillEnterForeground(application)
    }
}
