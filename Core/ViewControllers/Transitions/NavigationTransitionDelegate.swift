//
//  NavigationTransitionDelegate.swift
//  SwiftMovieSearch
//
//  Created by Dmitry Lobanov on 12.06.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import UIKit

class CustomNavigationTransitioningDelegate: NSObject {
    
}

extension CustomNavigationTransitioningDelegate: UIViewControllerTransitioningDelegate {
    
}

class CustomNavigationControllerDelegate: NSObject {
    var animatedTransitioning = CustomNavigationTransitioning()
}

extension CustomNavigationControllerDelegate: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // prepare views here.
        let transitioning = CustomNavigationTransitioning().configuredBy(presenting: operation == .push)
        return transitioning//self.animatedTransitioning
    }
}
