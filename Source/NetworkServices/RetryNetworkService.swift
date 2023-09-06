//
//  Copyright (C) 2017 DB Systel GmbH.
//  DB Systel GmbH; Jürgen-Ponto-Platz 1; D-60329 Frankfurt am Main; Germany; http://www.dbsystel.de/
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

import Foundation
import Dispatch

/**
 `RetryNetworkService` can request resource. When a request fails with a given condtion it can retry the request after a given time interval.
 The count of retry attemps can be configured as well.
 
 - seealso: `NetworkService`
 */
public final class RetryNetworkService: NetworkService {
    
    private let networkService: NetworkService
    private let numberOfRetries: Int
    private let idleTimeInterval: TimeInterval
    private let shouldRetry: (NetworkError) -> Bool
    
    /// Creates an instance of `RetryNetworkService`
    ///
    /// - Parameters:
    ///   - networkService: a networkservice
    ///   - numberOfRetries: the number of retrys before final error
    ///   - idleTimeInterval: time between error and retry
    ///   - shouldRetry: closure which evaluated if error should be retry
    public init(
        networkService: NetworkService,
        numberOfRetries: Int,
        idleTimeInterval: TimeInterval, shouldRetry: @escaping (NetworkError) -> Bool
    ) {
        self.networkService = networkService
        self.numberOfRetries = numberOfRetries
        self.idleTimeInterval = idleTimeInterval
        self.shouldRetry = shouldRetry
    }
    
    /**
     Fetches a resource asynchronously from remote location. Execution of the requests starts immediately.
     Execution happens on no specific queue. It dependes on the network access which queue is used.
     Once execution is finished either the completion block or the error block gets called.
     You decide on which queue these blocks get executed.
     
     **Example**:
     ```swift
     let networkService: NetworkService = //
     let resource: Resource<String> = //
     
     networkService.request(queue: .main, resource: resource, onCompletionWithResponse: { htmlText, response in
        print(htmlText, response)
     }, onError: { error in
        // Handle errors
     })
     ```
     
     - parameter queue: The `DispatchQueue` to execute the completion and error block on.
     - parameter resource: The resource you want to fetch.
     - parameter onCompletionWithResponse: Callback which gets called when fetching and transforming into model succeeds.
     - parameter onError: Callback which gets called when fetching or transforming fails.
     
     - returns: a running network task
     */
    public func requestResultWithResponse<Success>(for resource: Resource<Success>) async -> Result<(Success, HTTPURLResponse), NetworkError> {
        let result = await networkService.requestResultWithResponse(for: resource)
        switch result {
        case .success:
            return result
        case .failure(let failure):
            return await requestResultWithResponseOnError(error: failure, numberOfRetriesLeft: numberOfRetries, resource: resource)
        }
    }
    
    private func requestResultWithResponseOnError<Success>(
        error: NetworkError,
        numberOfRetriesLeft: Int,
        resource: Resource<Success>
    ) async -> Result<(Success, HTTPURLResponse), NetworkError> {
        if self.shouldRetry(error), numberOfRetriesLeft > 0 {
            let duration = UInt64(idleTimeInterval * 1_000_000_000)
            try? await Task.sleep(nanoseconds: duration)
            #warning("check for cancellation")
            
            let result = await networkService.requestResultWithResponse(for: resource)
            switch result {
            case .success:
                return result
            case .failure(let failure):
                return await requestResultWithResponseOnError(error: failure, numberOfRetriesLeft: numberOfRetriesLeft - 1, resource: resource)
            }
        } else {
            return .failure(error)
        }
    }
    
}
