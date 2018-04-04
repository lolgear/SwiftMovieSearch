//
//  NetworkSessionWrapper.swift
//  NetworkWorm
//
//  Created by Lobanov Dmitry on 02.04.2018.
//  Copyright © 2018 Home. All rights reserved.
//

import Foundation

public protocol CancellationToken {
    func resume()
    func suspend()
    func cancel()
}

extension URLSessionTask: CancellationToken {}

public class NetworkOperation: Operation {
    //    var urlSessionWrapper: NetworkURLSessionWrapper?
    var dataTask: URLSessionDataTask?
    //    var url: URL
    /*
     open func start()
     
     open func main()
     
     
     open var isCancelled: Bool { get }
     
     open func cancel()
     
     */
    
    var theExecuting = false
    var theFinished = false
    
    public override var isExecuting: Bool { return self.theExecuting }
    public override var isFinished: Bool { return self.theFinished }
    public override var isAsynchronous: Bool { return true }
    //    public override var isCancelled: Bool { return self.theExecuting == false }
    //    public override func start() {
    //
    //    }
    public override func cancel() {
        self.dataTask?.cancel()
        self.theExecuting = false
        self.theFinished = true
    }
    
    public override func main() {
        self.theExecuting = true
        self.theFinished = false
        
        //        self.dataTask = self.urlSessionWrapper?.urlSession.dataTask(with: self.url, completionHandler: { (data, urlResponse, error) in
        //
        //            self.theFinished = true
        //            self.theExecuting = false
        //        })
        
        self.dataTask?.resume()
    }
    
    init?(dataTask: URLSessionDataTask) {
        self.dataTask = dataTask
    }
    //    init?(url: URL?) {
    //        guard let theURL = url else { return nil }
    //        self.url = theURL
    //    }
}

extension NetworkOperation: URLSessionDownloadDelegate {
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // tell that you are ready and also set something.
        guard downloadTask.taskIdentifier == self.dataTask?.taskIdentifier else {
            return
        }
        self.theFinished = true
        self.theExecuting = false
    }
}

// add create task methods by types
public class URLSessionWrapper: NSObject {
    public enum TaskType {
        case task, data, upload, download, stream
        init(task: URLSessionTask) {
            switch task {
            case is URLSessionDataTask:
                self = .data
            case is URLSessionUploadTask:
                self = .upload
            case is URLSessionDownloadTask:
                self = .download
            case is URLSessionStreamTask:
                self = .stream
            default:
                self = .task
            }
        }
    }
    
    var urlSession = URLSession(configuration: URLSessionConfiguration.default)
    
    init(configuration: URLSessionConfiguration = URLSessionConfiguration.default) {
        self.urlSession = URLSession(configuration: configuration)
    }
    
    var tasksLimits = [TaskType.download : 3]
    //    var tasksIdentifiers: Set<Int> = []
    var tasks: [TaskType: [URLSessionTask]] = [
        TaskType.download: [],
        TaskType.data: []
    ]
}

// MARK: Create task by type.
// Define type which takes two items and one third
public enum Triplet<A, B, C> {
    case success(A, B)
    case error(A, C)
}

extension URLSessionWrapper {
    public typealias TaskCompletion = (Triplet<URL?, Data?, Error?>) -> Void
    public func createTask(type: TaskType,  request: URLRequest, completion: TaskCompletion?) -> URLSessionTask? {
        switch type {
        case .data:
            return self.urlSession.dataTask(with: request, completionHandler: { (data, response, error) in
                // put into completion correctly.
                if let theError = error {
                    completion?(.error(response?.url, theError))
                }
                else {
                    completion?(.success(response?.url, data))
                }
            })
        case .download:
            return self.urlSession.downloadTask(with: request, completionHandler: { (fileURL, response, error) in
                if let theError = error {
                    completion?(.error(response?.url, theError))
                    
                }
                else if let theFileUrl = fileURL {
                    let data = try? Data(contentsOf: theFileUrl)
                    // decoded error?
                    completion?(.success(response?.url, data))
                }
            })
        default:
            return nil
        }
    }
}

// MARK: Add task
extension URLSessionWrapper {
    public func addTask(task: URLSessionTask) {
        let type = TaskType(task: task)
        
        // put into tasks
        self.tasks[type]?.append(task)
        //        self.tasksIdentifiers.insert(task.taskIdentifier)
        // if limit - do not start it.
        task.resume()
//        if let limit = self.tasksLimits[type], let count = self.tasks[type]?.count,
//            count > limit {
//            // do nothing
//            print("here!")
//        }
//        else {
//            task.resume()
//        }
    }
}

// MARK: Lifecycle
extension URLSessionWrapper {
    public func suspendTasks(tasks: [URLSessionTask]) {
        for task in tasks {
            task.suspend()
        }
    }
    public func resumeTasks(tasks: [URLSessionTask]) {
        for task in tasks {
            task.suspend()
        }
    }
    public func cancelTasks(tasks: [URLSessionTask]) {
        for task in tasks {
            task.cancel()
        }
    }
    public func cancelAllTasks() {
        self.cancelTasks(tasks: self.tasks[.download]!)
    }
}

// MARK: URLSessionDataDelegate
//extension URLSessionWrapper: URLSessionDataDelegate {
//
//    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//
//        // remove from identifiers
//
//        let type = TaskType(task: task)
//
//        // remove tasks. we don't need completed or canceling.
//        // WAIT! we need only suspend items.
//        // so, we should compare to running items.
//        self.tasks[type] = self.tasks[type]?.filter{ $0.state == .running || $0.state == .suspended }
//
//        if let limit = self.tasksLimits[type], let count = self.tasks[type]?.count, count < limit {
//            // we should start enough tasks.
//            // shit here.
//        }
//    }
//}

// MARK: URLSessionDownloadDataDelegate
//extension NetworkURLSessionWrapper: URLSessionDownloadDelegate {
//    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
//        // tell what you have do.
//        // identify what you download.
//    }
//}
