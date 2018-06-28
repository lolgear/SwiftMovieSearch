//
//  PagedList.swift
//  SwiftMovieSearch
//
//  Created by Lobanov Dmitry on 30.03.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import CoreData

protocol PagedListUpdatesProtocol: class {
    func willUpdate<Element>(pagedList: PagedList<Element>)
    func updateElement<Element>(pagedList: PagedList<Element>, index: Int, type: PagedList<Element>.UpdateType)
    func didUpdate<Element>(pagedList: PagedList<Element>)
}

struct PagedList<Element> {
    static func startPage() -> Int {
        return 1
    }
    
    enum UpdateType {
        case append
        case update
        case reset
    }
    
    var list = [Element]()
    var currentPage = PagedList.startPage() // start page is 1? really? ok!
    var totalCount = 0
    var currentCount: Int { return list.count }
    var hasMore: Bool { return totalCount != currentCount }
    var nextPage: Int { return currentPage.advanced(by: 1) }
    
    weak var delegate: PagedListUpdatesProtocol?
    
    // update page?
}

// MARK: Update Total
extension PagedList {
    mutating func update(totalCount: Int) {
        self.totalCount = totalCount
    }
}

// MARK: Append
extension PagedList {
    mutating func append(incoming: [Element]) -> Range<Int> {
        guard incoming.count > 0 else { return 0..<0 }
        self.delegate?.willUpdate(pagedList: self)
        let previousEndIndex = self.list.endIndex
        self.list.append(contentsOf: incoming)
        let currentEndIndex = self.list.endIndex
        for index in previousEndIndex..<currentEndIndex {
            self.delegate?.updateElement(pagedList: self, index: index, type: .append)
        }
        self.currentPage = self.nextPage
        self.delegate?.didUpdate(pagedList: self)
                
        return previousEndIndex ..< currentEndIndex
    }
}

// MARK: Reset
extension PagedList {
    mutating func reset() {
        self.delegate?.willUpdate(pagedList: self)
        self.list = []
        self.currentPage = type(of: self).startPage()
        self.delegate?.didUpdate(pagedList: self)
    }
}
