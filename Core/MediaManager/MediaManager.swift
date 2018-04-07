//
//  MediaManager.swift
//  SwiftMovieSearch
//
//  Created by Lobanov Dmitry on 31.03.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation
import UIKit
import NetworkWorm

protocol Statusable: class {
    var isExecuting: Bool { get }
    var isFinished: Bool { get }
    func cancel()
}

protocol HasImageView: class {
    func imageViewAccessor() -> UIImageView?
}

class ImageContainer {
    weak var imageViewAccessor: HasImageView?
    weak var mediaManager: MediaManager?
    weak var statusable: Statusable?
    var url: URL?
    
    func cancel() {
        self.statusable?.cancel()
        self.imageViewAccessor = nil
        self.statusable = nil
        self.url = nil
    }
    func setUrl(url: URL?) {
        self.url = url
//        LoggingService.logDebug("start downloading url: \(url) by: \(self.mediaManager == nil)")
        self.statusable = self.mediaManager?.imageAtUrl(url: url, { (url, image) in
//            LoggingService.logDebug("self.url: \(self.url) and url: \(url)")
            if self.url == url {
                DispatchQueue.main.async {
                    self.imageViewAccessor?.imageViewAccessor()?.image = image
                }
            }
        })
    }
}

typealias ImageResultClosure = (UIImage?) -> ()

class DownloadImageOperation: Operation {
    typealias Completion = (Data?) -> ()
    // the same as operation.
    var onCompletion: (Completion)?
    var url: URL
    var token: CancellationToken?
//    weak var token: CancellationToken?
    //    var urlSessionWrapper: NetworkURLSessionWrapper?
    //    var url: URL
    /*
     open func start()
     
     open func main()
     
     
     open var isCancelled: Bool { get }
     
     open func cancel()
     
     */
    
    var theExecuting = false
    var theFinished = false
    
    public override var isExecuting: Bool {
        get {
            return self.theExecuting
        }
        set {
            willChangeValue(forKey: "isExecuting")
            self.theExecuting = newValue
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    public override var isFinished: Bool {
        get {
            return self.theExecuting
        }
        set {
            willChangeValue(forKey: "isFinished")
            self.theExecuting = newValue
            didChangeValue(forKey: "isFinished")
        }
    }
    
    public override var isAsynchronous: Bool { return true }
    //    public override var isCancelled: Bool { return self.theExecuting == false }
    //    public override func start() {
    //
    //    }
//    public override func start() {
//        self.theExecuting = true
//        self.theFinished = false
//        self.token?.resume()
//    }
    public override func start() {
        self.theExecuting = true
        self.theFinished = false
//        LoggingService.logDebug("start operation: \(self.url)")
        self.token = NetworkService.service()?.downloadResourceAtUrl(url: self.url, onResponse: { (triplet) in
            switch triplet {
            case .success(let _, let data):
                // put into image cache.
                self.finishing(with: data)
                return
            case .error(let _, let error):
//                LoggingService.logDebug("error while downloading image: \(error)")
                // if error - hide it?
                // or put in blacked list?
                self.finishing(with: nil)
                return
            }
        })
    }
    
    public override func cancel() {
        // nothing here.
        self.token?.cancel()
        self.token = nil
        self.theExecuting = false
        self.theFinished = true
    }
    
    func finishing(with data: Data?) {
        self.onCompletion?(data)
        self.token = nil
        self.theExecuting = false
        self.theFinished = true
        // also tell that you are ready.
        // so, we need a delegate? ( to self )?
    }
    
    init(url: URL, _ onCompletion: Completion?) {
        self.url = url
        self.onCompletion = onCompletion
    }
}

extension DownloadImageOperation: Statusable {}

class MediaManager {
    class MediaCache<Key, Value> where Key: AnyObject, Value: AnyObject {
        // use NSCache here.
        var cache = NSCache<Key, Value>()
        func object(key: Key) -> Value? {
            return self.cache.object(forKey: key)
        }
        
        func setObject(key: Key, value: Value) {
            self.cache.setObject(value, forKey: key)
        }
    }
    
    var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 3
        return queue
    }()
    var cache: MediaCache<NSURL, UIImage>? = MediaCache()
    var delegates: [AnyObject?]?
}

// MARK: DownloadAtUrl
extension MediaManager {
    private func downloadAtUrl(url: URL, _ onCompletion: @escaping ImageResultClosure) -> Statusable? {
        let operation = DownloadImageOperation(url: url) {
            (data) in
            // put into cache if possible.
            guard let theData = data, let image = UIImage(data: theData) else {
                onCompletion(nil)
                return
            }
            
            self.cache?.setObject(key: url as NSURL, value: image)
            onCompletion(image)
        }
        self.operationQueue.addOperation(operation)
        return operation
    }
}

// MARK: Public
extension MediaManager {
    // completion is a SHIT!
    // we can't now when we could download image in case of operation.
    // or we could?
    func imageAtUrl(url: URL?, _ onCompletion: @escaping (URL?, UIImage?) -> ()) -> Statusable? {
        LoggingService.logDebug("operations count: \(self.operationQueue.operations.count)")
        guard let theUrl = url else {
            onCompletion(nil, nil)
            return nil
        }
        // now try to find it in
        if let result = self.cache?.object(key: theUrl as NSURL) {
            onCompletion(theUrl, result)
            return nil
        }
        else {
            // try to download again.
            return self.downloadAtUrl(url: theUrl) {
                (image) in
                onCompletion(theUrl, image)
            }
        }
    }
}

// MARK: Cancel
extension MediaManager {
    func cancellAll() {
        self.operationQueue.cancelAllOperations()
        //TODO: and cancel all operations?
//        NetworkService.service()?.client?
//        NetworkService.service()?.client?
    }
    func cancel(url: URL) {
        self.operationQueue.operations.filter { ($0 as? DownloadImageOperation)?.url == url }.first?.cancel()
    }
}
