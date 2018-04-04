//
//  NotificationViewController.swift
//  NetworkWorm
//
//  Created by Lobanov Dmitry on 02.04.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import UIKit

class NotificationViewController: UIViewController {
    // show message!
    class Model {
        var title: String?
        var message: String?
        var duration: TimeInterval = 2
        var discardable: Bool = true
        class Presentation {
            enum Style {
                case error
                case success
                case general
                var textColor: UIColor {
                    switch self {
                    case .error:
                        return UIColor.white
                    case .success:
                        return UIColor.white
                    case .general:
                        return UIColor.black
                    }
                }
                var backgroundColor: UIColor {
                    switch self {
                    case .error:
                        return UIColor.red
                    case .success:
                        return UIColor.green
                    case .general:
                        return UIColor.lightGray
                    }
                }
                var font: UIFont {
                    return UIFont.boldSystemFont(ofSize: 17)
                }
            }
            
            init(style: Style) {
                self.style = style
            }
            
            var style = Style.general
        }
        var presentation: Presentation = Presentation(style: .general)
    }
    
    var model: Model? = Model()
    var titleLabel: UILabel!
    var messageLabel: UILabel!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
}

// MARK: HasModelProtocol
extension NotificationViewController: HasModelProtocol {
    typealias ModelType = Model
    func updateForNewModel() {
        // now it is my model.
        // ok.
        self.setupExternal()
    }
}

// MARK: SetupUI
extension NotificationViewController {
    func setupUI() {
        self.titleLabel = UILabel(frame: CGRect.zero)
        self.messageLabel = UILabel(frame: CGRect.zero)
        
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.messageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.translatesAutoresizingMaskIntoConstraints = false
        // update colors here.
        self.setupExternal()        
        // we will use duration as timer.
    }
    
    func setupExternal() {
        guard self.viewIfLoaded != nil else {
            return
        }
        
        self.titleLabel?.text = self.model?.title
        self.messageLabel?.text = self.model?.message
        self.titleLabel.textColor = self.model?.presentation.style.textColor
        self.messageLabel.textColor = self.model?.presentation.style.textColor
        self.titleLabel.font = self.model?.presentation.style.font
        self.messageLabel.font = self.model?.presentation.style.font
                
        self.viewIfLoaded?.backgroundColor = self.model?.presentation.style.backgroundColor
    }
    
    func addConstraints() {
        // put title on left.
        // put message below.
        guard let view = self.viewIfLoaded else {
            return
        }
        
//        view.addSubview(self.titleLabel)
        view.addSubview(self.messageLabel)
        
        // titleLabel and message label
        // titleLabel - safe area.top
        // titleLabel - safe area.left
        // titleLabel - safe area.right (>=)
        // messageLabel - titleLabel.left
        // messageLabel - safe area.right (>=)
        // messageLabel - safe area.spacing (>=)
        // messageLabel - titleLabel.spacing

        if let superview = self.messageLabel.superview {
            let view = self.messageLabel
            let vertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=10)-[view]-(>=10)-|", options: [], metrics: nil, views: ["view": view])
            let horizontal = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=10)-[view]-(>=10)-|", options: [], metrics: nil, views: ["view": view])
            let centerX = NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: superview, attribute: .centerX, multiplier: 1, constant: 0)
            let centerY = NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: superview, attribute: .centerY, multiplier: 1, constant: 0)
            superview.addConstraints(vertical + horizontal + [centerX, centerY])
            
        }
//        if let superview = self.titleLabel.superview, let _ = self.messageLabel.superview {
//            let vertical = NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[title]-10-[message]-(>=10)-|", options: [], metrics: nil, views: ["title" : self.titleLabel, "message" : self.messageLabel])
//            let horizontalTitleLabel = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view]-(>=10)-|", options: [], metrics: nil, views: ["view" : self.titleLabel])
//            let horizontalMessageLabel = NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[view]-(>=10)-|", options: [], metrics: nil, views: ["view" : self.messageLabel])
//            superview.addConstraints(vertical + horizontalTitleLabel + horizontalMessageLabel)
//        }
    }
}

// MARK: View Lifecycle
extension NotificationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.addConstraints()
    }
//    override func willMove(toParentViewController parent: UIViewController?) {
//        // we should adjust offset here.
//        // it is our y point.
//        // also, lets find our preferred size here?
////        parent?.view.safeAreaLayoutGuide.topAnchor
//
//        var size = CGSize.zero
//        size.width = parent?.view.bounds.size.width ?? 0
//        size.height = 70
//        self.preferredContentSize = size
//    }
}
