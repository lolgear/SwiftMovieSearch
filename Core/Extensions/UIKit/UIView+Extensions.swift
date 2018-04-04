//
//  UIView+Extensions.swift
//  SwiftExchanger
//
//  Created by Lobanov Dmitry on 10.10.2017.
//  Copyright © 2017 Lobanov Dmitry. All rights reserved.
//

import Foundation
import UIKit

// Immersion
extension UIView {
    func immerse(_ controller: UIViewController?, into view: UIView?) {
        guard let theController = controller, let theView = view else {
            return
        }
        
        theController.loadViewIfNeeded()
        guard let controllerView = theController.viewIfLoaded else {
            return
        }
        
        theView.addSubview(controllerView)
        
        guard let controllerSuperview = theController.viewIfLoaded?.superview else {
            return
        }
        
        //TODO: add constraints to edges.
        
        let vertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options:[], metrics: nil, views: ["view": controllerView])
        let horizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options:[], metrics: nil, views: ["view": controllerView])
        theView.addConstraints(vertical + horizontal)
    }
    
    func filled(by controller: UIViewController?) {
        self.immerse(controller, into: self)
    }
}
