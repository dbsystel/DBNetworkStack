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
//  RetryNetworkService.swift
//  DBNetworkStack
//
//  Created by Lukas Schmidt on 14.12.16.
//

import Foundation
import Dispatch

/**
 `RetryNetworkService` can request resource. When a request fails with a given condtion it can retry the request after a given time interval.
 The count of retry attemps can be configured as well.
 */
public final class RetryNetworkService: NetworkServiceProviding {
    private let networkService: NetworkServiceProviding
    private let numberOfRetries: Int
    private let idleTimeInterval: TimeInterval
    private let dispatchRetry: (_ deadline: DispatchTime, _ execute: @escaping () -> Void ) -> Void
    private let shouldRetry: (DBNetworkStackError) -> Bool
    
    /// Creates an instance of `RetryNetworkService`
    ///
    /// - Parameters:
    ///   - networkService: a networkservice
    ///   - numberOfRetries: the number of retrys before final error
    ///   - idleTimeInterval: time between error and retry
    ///   - shouldRetry: closure which evaluated if error should be retry
    ///   - dispatchRetry: closure where to dispatch the waiting
    public init(networkService: NetworkServiceProviding, numberOfRetries: Int,
                idleTimeInterval: TimeInterval, shouldRetry: @escaping (DBNetworkStackError) -> Bool,
                dispatchRetry: @escaping (_ deadline: DispatchTime, _ execute: @escaping () -> Void ) -> Void = { deadline, execute in
            DispatchQueue.global(qos: .utility).asyncAfter(deadline: deadline, execute: execute)
        }) {
        self.networkService = networkService
        self.numberOfRetries = numberOfRetries
        self.idleTimeInterval = idleTimeInterval
        self.shouldRetry = shouldRetry
        self.dispatchRetry = dispatchRetry
    }
    
    @discardableResult
    public func request<T: ResourceModeling>(queue: DispatchQueue, resource: T, onCompletion: @escaping (T.Model) -> Void,
                        onError: @escaping (DBNetworkStackError) -> Void) -> NetworkTaskRepresenting {
        let retryTask = RetryNetworkTask(maxmimumNumberOfRetries: numberOfRetries, idleTimeInterval: idleTimeInterval, shouldRetry: shouldRetry,
                                  onSuccess: onCompletion, onError: onError, retryAction: { completion, error in
                                    return self.networkService.request(queue: queue, resource, onCompletion: completion, onError: error)
        }, dispatchRetry: { [weak self] disptachTime, block in
            self?.dispatchRetry(disptachTime, block)
        })
        retryTask.originalTask = networkService.request(resource, onCompletion: onCompletion, onError: retryTask.createOnError())
        
        return retryTask
    }
    
}
