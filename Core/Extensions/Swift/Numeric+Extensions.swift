//
//  Numeric+Extensions.swift
//  NetworkWorm
//
//  Created by Lobanov Dmitry on 03.04.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import UIKit

struct GoldenRatio {
    static let golderRatio = (1 + sqrt(5)) / 2
    static func size(width: CGFloat) -> CGSize {
        var size = CGSize.zero
        size.width = width
        size.height = width * CGFloat(self.golderRatio)
        return size
    }
}
