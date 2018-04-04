//
//  DateFormatter.swift
//  SwiftExchanger
//
//  Created by Lobanov Dmitry on 15.10.2017.
//  Copyright © 2017 Lobanov Dmitry. All rights reserved.
//

import Foundation
class CustomDateFormatter {
    class func string(value: Double) -> String? {
        let date = Date(timeIntervalSince1970: value)
        return string(value: date)
    }
    class func string(value: Date) -> String? {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: value)
    }
    class func date(value: String) -> Date? {
        return nil
    }
}
