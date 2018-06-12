//
//  NavigationTransition.swift
//  SwiftMovieSearch
//
//  Created by Dmitry Lobanov on 12.06.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import UIKit

class BasicNavigationTransitioning: NSObject {
    var duration: TimeInterval = 1.0
    var function = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
    var presenting = false
    // Subclass
    func prepareAnimations(transitionContext: UIViewControllerContextTransitioning, fromView: UIView, toView: UIView) {}
    func applyAnimations(transitionContext: UIViewControllerContextTransitioning, fromView: UIView, toView: UIView) {}
}

// Animations
extension BasicNavigationTransitioning {
    func applyAnimation(animation: CABasicAnimation, layer: CALayer) {
        if let keyPath = animation.keyPath {
            layer.setValue(animation.toValue, forKeyPath: keyPath)
            layer.add(animation, forKey: keyPath)
        }
    }
    
    func basicAnimation(keyPath: String) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: keyPath)
        return animation
    }
    
    func revertedAnimation(animation: CABasicAnimation) -> CABasicAnimation {
        let reverted = CABasicAnimation(keyPath: animation.keyPath)
        reverted.fromValue = animation.toValue
        reverted.toValue = animation.fromValue
        reverted.byValue = animation.byValue
        return reverted
    }
    
    func forwardedAnimation(animation: CABasicAnimation) -> CABasicAnimation {
        guard animation.isAdditive else { return animation }
        
        let forwared = CABasicAnimation(keyPath: animation.keyPath)
        forwared.fromValue = animation.toValue
        if let toValue = animation.toValue as? IntegerLiteralType, let fromValue = animation.fromValue as? IntegerLiteralType {
            let value = toValue - fromValue
            forwared.toValue = value
        }
        forwared.byValue = animation.byValue
        return forwared
    }
}

extension BasicNavigationTransitioning: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        guard let fromView = transitionContext.view(forKey: .from), let toView = transitionContext.view(forKey: .to) else {
            return
        }
        
        guard let fromViewController = transitionContext.viewController(forKey: .from) else {
            return
        }
        
        self.prepareAnimations(transitionContext: transitionContext, fromView: fromView, toView: toView)

        containerView.addSubview(toView)
        containerView.addSubview(fromView)
        
        let frame = transitionContext.initialFrame(for: fromViewController)
        fromView.frame = frame
        toView.frame = frame

        UIView.animate(withDuration: self.duration, animations: {
            self.applyAnimations(transitionContext: transitionContext, fromView: fromView, toView: toView)
        }) { ( result) in
            transitionContext.completeTransition(true)
        }
//        CATransaction.begin()
//        self.applyAnimations(transitionContext: transitionContext, fromView: fromView, toView: toView)
//        CATransaction.setCompletionBlock {
//            transitionContext.completeTransition(true)
//        }
//        CATransaction.commit()
    }
}

// Custom
class CustomNavigationTransitioning: BasicNavigationTransitioning {
    override func prepareAnimations(transitionContext: UIViewControllerContextTransitioning, fromView: UIView, toView: UIView) {
        let right = CGAffineTransform(translationX: transitionContext.containerView.bounds.size.width, y: 0)
        toView.transform = right
    }
    override func applyAnimations(transitionContext: UIViewControllerContextTransitioning, fromView: UIView, toView: UIView) {
        // animate anchorPoints.
        // anchorPoint is a center of the view.
        // we want to animate them by moving all of them to right.
        
//        let xInset = 1.0
//
//        // final point is a (0.5, 0.5)
//        // by default, views has this point as layer.anchorPoint
//
//        let centerPoint = CGPoint(x: 0.5, y: 0.5)
//
//        // source point for ToView
//        let originPoint = self.pointByAddingInset(anchorPoint: centerPoint, inset: -CGFloat(xInset))
//
//        // target point for fromView
//        let targetPoint = self.pointByAddingInset(anchorPoint: centerPoint, inset: CGFloat(xInset))
//        let appearingAnimation = CABasicAnimation(keyPath: "anchorPoint")
//        appearingAnimation.byValue = 0.1
//        appearingAnimation.fromValue = originPoint
//        appearingAnimation.toValue = centerPoint
//
//        let disappearingAnimation = self.revertedAnimation(animation: appearingAnimation)
//        disappearingAnimation.toValue = targetPoint
////
////        self.applyAnimation(animation: disappearingAnimation, layer: fromView.layer)
//        self.applyAnimation(animation: appearingAnimation, layer: toView.layer)

        let left = CGAffineTransform(translationX: -transitionContext.containerView.bounds.size.width, y: 0)
        
        fromView.transform = left
        toView.transform = CGAffineTransform.identity
    }
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // get reference to our fromView, toView and the container view that we should perform the transition in
        let container = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        
        guard let fromViewController = transitionContext.viewController(forKey: .from) else { return }
        let initialFrame = transitionContext.initialFrame(for: fromViewController)
        
        fromView.frame = initialFrame
        toView.frame = initialFrame
        
        // set up from 2D transforms that we'll use in the animation
        let offScreenRight = CGAffineTransform(translationX: container.frame.width, y: 0)
        let offScreenLeft = CGAffineTransform(translationX: -container.frame.width, y: 0)
        
        // start the toView to the right of the screen
        toView.transform = offScreenRight
        
        // add the both views to our view controller
        container.addSubview(fromView)
        container.addSubview(toView)
        
        // perform the animation!
        // for this example, just slid both fromView and toView to the left at the same time
        // meaning fromView is pushed off the screen and toView slides into view
        UIView.animate(withDuration: self.duration, animations: {
            fromView.transform = offScreenLeft
            toView.transform = CGAffineTransform.identity
        }) { (result) in
            transitionContext.completeTransition(true)
        }
    }
}

// AnchorPoint
extension CustomNavigationTransitioning {
    func pointByAddingInset(anchorPoint: CGPoint, inset: CGFloat) -> CGPoint {
        var newPoint = anchorPoint
        newPoint = CGPoint(x: newPoint.x + inset, y: newPoint.y)
        return newPoint
    }
}

//extension CustomNavigationTransitioning: UIViewControllerAnimatedTransitioning {
////    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
////        let containerView = transitionContext.containerView
////
////        guard let fromView = transitionContext.view(forKey: .from), let toView = transitionContext.view(forKey: .to) else {
////            return
////        }
////
////        containerView.addSubview(toView)
////        containerView.bringSubview(toFront: fromView)
////
////        // animate anchorPoints.
////        // anchorPoint is a center of the view.
////        // we want to animate them by moving all of them to right.
////
////        let xOffset = 1.0
////
////        // final point is a (0.5, 0.5)
////        // by default, views has this point as layer.anchorPoint
////
////
////    }
//}
