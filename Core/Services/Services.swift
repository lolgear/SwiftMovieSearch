//
//  Services.swift
//  SwiftTrader
//
//  Created by Lobanov Dmitry on 24.02.17.
//  Copyright © 2017 OpenSourceIO. All rights reserved.
//

import Foundation
import UIKit

protocol ServicesInfoProtocol {
    var health: Bool {get}
    static var name: String {get}
}

protocol ServicesSetupProtocol {
    func setup()
    func tearDown()
}

protocol ServicesOnceProtocol {
    func runAtFirstTime()
}

class BaseService: NSObject {
    private class func accessService<T: BaseService>() -> T? {
        return ServicesManager.manager.service(name: self.name) as? T
    }
    class func service() -> Self? {
        return accessService()
    }
}

extension BaseService: ServicesInfoProtocol {
    @objc var health: Bool {
        return false
    }
    static var name: String {
        return self.description()
    }
}

extension BaseService: ServicesSetupProtocol {
    @objc func setup() {}
    @objc func tearDown() {}
}

extension BaseService: ServicesOnceProtocol {
    @objc func runAtFirstTime() {}
}

extension BaseService: UIApplicationDelegate {
    
}

// MARK: Services Manager.
class ServicesManager: NSObject {
    //MARK: Shared
    //In case of AppDelegate mainThread only availabililty
    
    static let shared: ServicesManager = ServicesManager()
    var services: [BaseService] = []
    static var manager: ServicesManager {
        return shared /*(UIApplication.shared.delegate as! AppDelegate).servicesManager*/
    }
    override init() {
        services = [LoggingService(), KeyboardService(), NetworkService(), /*DatabaseService(),*/ DataProviderService(), ViewControllersService(), MediaDeliveryService()]
    }
    func service(name: String) -> BaseService? {
        let service = services.filter {type(of: $0).name == name}.first
        if service == nil {
            // tell something about it?
            // for example, print?
        }
        return service
    }
    func setup() {
        for service in services as [ServicesSetupProtocol] {
            service.setup()
        }
    }
    func tearDown() {
        for service in services as [ServicesSetupProtocol] {
            service.tearDown()
        }
    }
    
    func runAtFirstTime() {
        storageSettings()
        let settings = ApplicationSettingsStorage.loaded()
        if !settings.alreadyConfiguredAfterRunAtFirstTime {
            for service in services as [ServicesOnceProtocol] {
                service.runAtFirstTime()
            }
            settings.alreadyConfiguredAfterRunAtFirstTime = true
        }
    }
    
    func interServiceSetup() {
        NetworkService.service()?.reachabilityObserving = ViewControllersService.service()
    }
}

//MARK: Settings.
//It is the best place to change them.
//We need production settings.
extension ServicesManager {
    //HINT: the best place to change default settings to something else.
    func storageSettings() {
        ApplicationSettingsStorage.DefaultSettings = ApplicationSettingsStorage.ProductionSettings
    }
}

//MARK: Accessors
extension ServicesManager {
//    var databaseService: DatabaseService? {
//        return service(name: DatabaseService.name) as? DatabaseService
//    }
//    var dataProviderService: DataProviderService? {
//        return service(name: DataProviderService.name) as? DataProviderService
//    }
    var networkService: NetworkService? {
        return service(name: NetworkService.name) as? NetworkService
    }
    var loggingService: LoggingService? {
        return service(name: LoggingService.name) as? LoggingService
    }
}

extension ServicesManager: UIApplicationDelegate {
    func servicesUIDelegates() -> [UIApplicationDelegate] {
        return services as [UIApplicationDelegate]
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        tearDown()
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        setup()
        
        runAtFirstTime()
        interServiceSetup()
        // wrap controller into navigation.
        let dataProvider = DataProviderService.service()?.dataProvider
        
        let model = MoviesViewController.Model().configured(dataSource: dataProvider).configured(moreDataService: dataProvider).configured(movieDeails: dataProvider)
        
        let searchMovieModel = SearchMovieCompanion.Model().configured(service: dataProvider)
        let searchMovieCompanion = SearchMovieCompanion().configured(model: searchMovieModel)
        
        let moviesViewController = MoviesViewController().configured(search: searchMovieCompanion).configured(model: model)
        
        let viewController = moviesViewController
        ViewControllersService.service()?.rootViewController = viewController
        
        let controller = ViewControllersService.service()?.blessedController()
        guard controller != nil else {
            return false
        }
        
        application.keyWindow?.rootViewController = controller
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        for service in servicesUIDelegates() {
            service.applicationDidBecomeActive?(application)
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        for service in servicesUIDelegates() {
            service.applicationWillResignActive?(application)
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        for service in servicesUIDelegates() {
            service.applicationDidEnterBackground?(application)
        }
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        for service in servicesUIDelegates() {
            service.applicationWillEnterForeground?(application)
        }
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        for service in servicesUIDelegates() {
            service.application?(application, performFetchWithCompletionHandler: completionHandler)
        }
    }
    
}
