//
//  Copyright (C) 2016 Lukas Schmidt.
//
//  Permission is hereby granted, free of charge, to any person obtaining a 
//  copy of this software and associated documentation files (the "Software"), 
//  to deal in the Software without restriction, including without limitation 
//  the rights to use, copy, modify, merge, publish, distribute, sublicense, 
//  and/or sell copies of the Software, and to permit persons to whom the 
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in 
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL 
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
//  DEALINGS IN THE SOFTWARE.
//
//
//  RetryNetworkTask.swift
//  DBNetworkStack
//
//  Created by Lukas Schmidt on 14.12.16.
//

import Foundation

/// A NetworkTaskRepresenting which can be used together with `RetryNetworkService` to keep a task alife to repeat the task after a given time
class RetryNetworkTask<T> : NetworkTaskRepresenting {
    private let maxmimumNumberOfRetries: Int
    private let idleTimeInterval: TimeInterval
    private let shouldRetry: (DBNetworkStackError) -> Bool
    var originalTask: NetworkTaskRepresenting?
    
    private var numberOfRetriesLeft: Int
    private let onSuccess: ((T) -> ())
    private let onError: ((DBNetworkStackError) -> ())
    private var isCaneled = false
    
    private let retryAction: (@escaping (T) -> (), @escaping (DBNetworkStackError) -> ()) -> NetworkTaskRepresenting
    private let dispatchRetry: (_ deadline: DispatchTime, _ execute: @escaping () -> () ) -> ()
    
    /// Creates an instance of `RetryNetworkTaks`
    ///
    /// - Parameters:
    ///   - maxmimumNumberOfRetries: the number of retries the task can be restarted
    ///   - idleTimeInterval: the thime interval between a failure and a retry
    ///   - shouldRetry: closure which gets evaluated if a error should trigger a retry
    ///   - onSuccess: closure which gets fired on success
    ///   - onError: closure which gets fired on error
    ///   - retryAction: closure which gets triggerd when retry starts
    ///   - dispatchRetry: location where to dispatch the retry action
    init(maxmimumNumberOfRetries: Int, idleTimeInterval: TimeInterval, shouldRetry: @escaping (DBNetworkStackError) -> Bool, onSuccess: @escaping (T) -> (),
         onError: @escaping (DBNetworkStackError) -> (),
         retryAction: @escaping (@escaping (T) -> (), @escaping (DBNetworkStackError) -> ()) -> NetworkTaskRepresenting,
         dispatchRetry: @escaping (_ deadline: DispatchTime, _ execute: @escaping () -> ()) ->() ) {
        
        self.maxmimumNumberOfRetries = maxmimumNumberOfRetries
        self.numberOfRetriesLeft = maxmimumNumberOfRetries
        self.idleTimeInterval = idleTimeInterval
        self.shouldRetry = shouldRetry
        
        self.retryAction = retryAction
        self.dispatchRetry = dispatchRetry
        
        self.onSuccess = onSuccess
        self.onError = onError
    }
    
    /**
     Creates a error closure which can be used as to call the original service with.
     
     - return: the onError closure for a network request.
     */
    ///
    func createOnError() -> (DBNetworkStackError) -> () {
        return { error in
            if self.shouldRetry(error), self.numberOfRetriesLeft > 0 {
                guard !self.isCaneled else {
                    return
                }
                self.numberOfRetriesLeft -= 1
                self.dispatchRetry(.now() + self.idleTimeInterval, {
                    self.originalTask = self.retryAction(self.onSuccess, self.createOnError())
                })
            } else {
                self.onError(error)
            }
        }
    }
    
    func resume() {
        originalTask?.resume()
    }
    
    func cancel() {
        isCaneled = true
        originalTask?.cancel()
    }
    
    func suspend() {
        originalTask?.suspend()
    }
    
    var progress: Progress {
        guard let task = originalTask else {
            fatalError("OrginalTask has to be set")
        }
        return task.progress
    }
    
}
