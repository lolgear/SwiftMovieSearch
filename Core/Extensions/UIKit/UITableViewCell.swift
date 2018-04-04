//
//  UITableViewCell.swift
//  SwiftExchanger
//
//  Created by Lobanov Dmitry on 15.10.2017.
//  Copyright © 2017 Lobanov Dmitry. All rights reserved.
//

import Foundation
import UIKit
protocol UITableViewRegisterable: class {
    static func cellReuseIdentifier() -> String
    static func nib() -> UINib
}

extension UITableViewCell: UITableViewRegisterable {
    static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }
    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
}
