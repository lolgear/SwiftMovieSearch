//
//  MediaDeliveryService.swift
//  SwiftMovieSearch
//
//  Created by Lobanov Dmitry on 01.04.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
class MediaDeliveryService: BaseService {
    lazy var mediaManager = MediaManager()
}

extension MediaDeliveryService {
    override func tearDown() {
        self.mediaManager.cancellAll()
    }
}
