//
//  ViewControllersService.swift
//  SwiftExchanger
//
//  Created by Lobanov Dmitry on 15.10.2017.
//  Copyright © 2017 Lobanov Dmitry. All rights reserved.
//

import Foundation
import UIKit
@objc protocol ViewControllersServiceNavigationActionProtocol {
    func shouldShow(controller: UIViewController?, for action:ViewControllersService.NavigationAction)
}
class ViewControllersService: BaseService {
    class NavigationAction: NSObject {
        weak var delegate: ViewControllersServiceNavigationActionProtocol?
        func configured(by delegate: ViewControllersServiceNavigationActionProtocol?) -> Self {
            self.delegate = delegate
            return self
        }
        @objc func action(button: UIBarButtonItem?) {
            // add if needed.
            // we just want to
        }
        func title() -> String? {
            return ""
        }
        func barButton() -> UIBarButtonItem {
            return UIBarButtonItem(title: self.title(), style: .plain, target: self, action: #selector(NavigationAction.action) )
        }
        class ResetCash: NavigationAction {
            override func action(button: UIBarButtonItem?) {
//                guard let database = DatabaseService.service() else {
//                    return
//                }
//                database.resetCash()
            }
            override func title() -> String? {
                return "Reset Cash"
            }
        }
        class ShowTransactions: NavigationAction {
            override func action(button: UIBarButtonItem?) {
//                self.delegate?.shouldShow(controller: TransactionsViewController.defaultController(), for: self)
            }
            override func title() -> String? {
                return "Transactions"
            }
        }
        class ResetExchanges: NavigationAction {
            override func action(button: UIBarButtonItem?) {
//                guard let database = DatabaseService.service() else {
//                    return
//                }
//                database.deleteAllExchanges()
            }
            override func title() -> String? {
                return "ResetAll"
            }
        }
        
        class ShareMovie: NavigationAction {
            var url: URL?
            var controller: UIViewController?
            func configured(url: URL?) -> Self {
                self.url = url
                return self
            }
            
            func configured(controller: UIViewController?) -> Self {
                self.controller = controller
                return self
            }
            
            override func barButton() -> UIBarButtonItem {
                return UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(NavigationAction.action))
            }
            
            override func action(button: UIBarButtonItem?) {
                let controller = UIActivityViewController(activityItems: [self.url].compactMap {$0}, applicationActivities: nil)
                self.controller?.present(controller, animated: true, completion: nil)
            }
        }
        // bind to itself
        enum NavigationActionType {
            case resetCash
            case showTransactions
            case resetExchanges
            case shareMovie
            func action() -> NavigationAction {
                switch self {
                case .resetCash: return ResetCash()
                case .showTransactions: return ShowTransactions()
                case .resetExchanges: return ResetExchanges()
                case .shareMovie: return ShareMovie()
                }
            }
        }
    }
    
    var rootViewController: UIViewController?
    var leftActions: [NavigationAction]?
    var rightActions: [NavigationAction]?
    
    // add later correct actions hanlding via push / pop
    var currentLeftActions: [NavigationAction]?
    var currentRightActions: [NavigationAction]?
}

//MARK: Controller preparation
extension ViewControllersService {
    func blessedController(controller: UIViewController? = nil) -> UIViewController? {
        guard let viewController = controller ?? self.rootViewController else {
            return nil
        }
//        let c = ErrorHanldingViewController(viewController: viewController)
        
        let controller = UINavigationController(rootViewController: viewController)
        let result = ErrorHanldingViewController(viewController: controller)
//        controller.navigationItem.leftBarButtonItems = self.leftActions?.map {$0.barButton()}
//        controller.navigationItem.rightBarButtonItems = self.rightActions?.map {$0.barButton()}
//        controller.viewControllers.first?.navigationItem.leftBarButtonItems = controller.navigationItem.leftBarButtonItems
//        controller.viewControllers.first?.navigationItem.rightBarButtonItems = controller.navigationItem.rightBarButtonItems
        self.rootViewController = result
        return result
    }
}

//MARK: ServicesInfoProtocol
extension ViewControllersService {
    override var health: Bool {
        return rootViewController != nil
    }
}

//MARK: ServicesSetupProtocol
extension ViewControllersService {
    override func setup() {
        // setup all necessary items and after that we are ready for rootViewController
        self.leftActions = [NavigationAction.NavigationActionType.resetCash.action()]
        self.rightActions = [NavigationAction.NavigationActionType.showTransactions.action().configured(by: self)]
        self.currentRightActions = [NavigationAction.NavigationActionType.resetExchanges.action()]
        UINavigationBar.appearance().isTranslucent = false
//        UIView.appearance().translatesAutoresizingMaskIntoConstraints = false
//        UITableView.appearance().translatesAutoresizingMaskIntoConstraints = false
    }
}

//MARK: ActionHandling
extension ViewControllersService: ViewControllersServiceNavigationActionProtocol {
    func shouldShow(controller: UIViewController?, for action: ViewControllersService.NavigationAction) {
        guard let theController = controller else {
            return
        }
        // before push setup controller by actions.
        setupController(controller: theController)
        self.rootViewController?.navigationController?.pushViewController(theController, animated: true)
    }
    func setupController(controller: UIViewController) {
        switch controller {
//        case let item as TransactionsViewController:
//            item.navigationItem.rightBarButtonItems = self.currentRightActions?.map {$0.barButton()}
//            item.navigationItem.leftBarButtonItems = self.currentLeftActions?.map {$0.barButton()}
        default: break
        }
    }
}

//extension UIViewController {
//    func showMesssage(message: String?) {
//        let controller = NotificationViewController()
//        let model = NotificationViewController.Model()
//        model.message = message
//        controller.configured(model: model)
////        controller.loadViewIfNeeded()
//        self.present(controller, animated: true, completion: {
//            // here!
//            LoggingService.logDebug("here!")
//        })
//    }
////
//    func showError(error: Error?) {
//        let controller = NotificationViewController()
//        let model = NotificationViewController.Model()
//        model.message = error?.localizedDescription
//        model.presentation.style = .error
//        controller.configured(model: model)
////        controller.loadViewIfNeeded()
//        self.present(controller, animated: true, completion: nil)
//    }
//}

//MARK: NetworkReachabilityObservingProtocol
extension ViewControllersService: NetworkReachabilityObservingProtocol {
    func didChangeState(state: Bool) {
        // should show error.
        // configure message - Connecting or Connected.
//        self.showMessage(message: "Connecting")
        
        let message = state ? "Connected" : "Connecting"
        let model = NotificationViewController.Model()
        model.message = message
        model.discardable = state
        self.showPresentModel(model: model)
    }
}

//MARK: ErrorHandlingProtocol
extension ViewControllersService: UserActionResponseShowErrorProtocol {
    func showError(error: Error?) {
        let model = NotificationViewController.Model()
        model.message = error?.localizedDescription
        model.presentation.style = .error
        self.showPresentModel(model: model)
    }
    
    func showMessage(message: String?) {
        let model = NotificationViewController.Model()
        model.message = message
        model.presentation.style = .general
        model.discardable = false
        self.showPresentModel(model: model)
    }
    
    func showPresentModel(model: NotificationViewController.Model) {
        if let errorHandlingController = self.rootViewController as? ErrorHanldingViewController {
            let controller = errorHandlingController.notification
            if controller.model?.discardable == false && model.presentation.style == .error {
                return
            }
            _ = controller.configured(model: model)
            errorHandlingController.expandView(for: 1.5, dismissable: model.discardable)
        }
    }
}


class ErrorHanldingViewController: UIViewController {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    var barView: UIView!
    var viewController: UIViewController!
    private var barViewConstraint: NSLayoutConstraint!
    var notification = NotificationViewController()
    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init(nibName: nil, bundle: nil)
    }
}

// View
extension ErrorHanldingViewController {

    func setupBarView() {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.barView = view
    }
    
    func expandView(for duration: TimeInterval, dismissable: Bool = true) {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.barView.alpha = 1
        }, completion: {
            result in
            if dismissable {
                DispatchQueue.main.async {
                    self.collapseView(animated: true, delayed: duration)
                }
            }
        })
    }
    
    func collapseView(animated: Bool = false, delayed: TimeInterval = 3) {
        if animated {
            UIView.animate(withDuration: 0.5, delay: delayed, options: [.curveEaseInOut], animations: {
                self.barView.alpha = 0
            }, completion: nil)
        }
        else {
            self.barView.alpha = 0
        }
    }
    
}

// Constraints
extension ErrorHanldingViewController {
    func addConstraints() {
        self.view.addSubview(self.barView)

        if let superview = self.barView.superview {
            let vertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]", options: [], metrics: nil, views: ["view": self.barView])
            let horizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view": self.barView])
            let heightConstraint = NSLayoutConstraint(item: self.barView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 0.0, constant: 64)
            
//            let widthConstraint = NSLayoutConstraint(item: self.barView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 0.0, constant: 32)
            
            // only one constraint
            let constraints = vertical + horizontal + [heightConstraint]
            superview.addConstraints(constraints)
            self.barViewConstraint = vertical.first
        }
    }
}
//MARK: Setup
extension ErrorHanldingViewController {
    func setupUI() {
        self.setupBarView()
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints()
        self.view.immerse(self.viewController, into: self.view)
        self.barView.immerse(self.notification, into: self.barView)
        self.view.bringSubview(toFront: self.barView)
        self.collapseView()
    }
}

//MARK: View Lifecycle
extension ErrorHanldingViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
}
