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
 `BasicNetworkService` handles network request for resources by using a given `NetworkAccess`.
 
 **Example**:
 ```swift
 // Just use an URLSession for the networkAccess.
 let basicNetworkService: NetworkService = BasicNetworkService(networkAccess: URLSession(configuration: .default))
 ```
 
 - seealso: `NetworkService`
 */
public final class BasicNetworkService: NetworkService {
    private let networkAccess: NetworkAccess

    /**
     Creates an `BasicNetworkService` instance with a given network access to execute requests on.
     
     - parameter networkAccess: provides basic access to the network.
     */
    public init(networkAccess: NetworkAccess) {
        self.networkAccess = networkAccess
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
    @discardableResult
    public func requestResultWithResponse<Success>(for resource: Resource<Success, NetworkError>) async -> Result<(Success, HTTPURLResponse), NetworkError> {
        do {
            let (data, response) = try await networkAccess.load(request: resource.request)
            guard let response = response as? HTTPURLResponse else {
                return .failure(.unknownError)
            }
            if let responseError = NetworkError(response: response, data: data) {
                return .failure(responseError)
            }

            do {
                return .success((try resource.parse(data), response))
            } catch let error {
                return .failure(.serializationError(error: error, data: data))
            }
        } catch let error {
            if case URLError.cancelled = error {
                return .failure(.cancelled)
            }

            return .failure(.requestError(error: error))
        }

    }
    
}
