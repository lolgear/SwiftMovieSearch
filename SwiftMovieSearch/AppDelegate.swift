//
//  AppDelegate.swift
//  SwiftMovieSearch
//
//  Created by Lobanov Dmitry on 26.03.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import UIKit
import NetworkWorm

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    var servicesManager = ServicesManager.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.makeKeyAndVisible()
//        let network = NetworkService()
//        network.setup()
//        network.client.executeCommand(command: MetadataSearchCommand(searchText: "result", page: 0)) { (response) in
//            // wait!
//            switch response {
//            case let result as ErrorResponse:
//                print(result.descriptiveError ?? "Unknown error")
//            case let result as SearchMoviesResponse:
//                print(result.results)
//            default:
//                print("general result?")
//            }
//        }
//        sleep(100)
//        NetworkService().client.executeCommand(command: <#T##Command#>, onResponse: <#T##(Response) -> ()#>)
        _ = servicesManager.application(application, didFinishLaunchingWithOptions: launchOptions)
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        servicesManager.applicationWillResignActive(application)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        servicesManager.applicationDidEnterBackground(application)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        servicesManager.applicationWillEnterForeground(application)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        servicesManager.applicationDidBecomeActive(application)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        servicesManager.applicationWillTerminate(application)
    }

    // for background
//    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        servicesManager.application(application, performFetchWithCompletionHandler: completionHandler)
//    }
}

