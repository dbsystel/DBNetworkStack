//
//  Copyright (C) 2021 DB Systel GmbH.
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

extension NetworkService {

    /**
     Fetches a resource asynchronously from remote location. Execution of the requests starts immediately.
     Execution happens on no specific queue. It dependes on the network access which queue is used.
     Once execution is finished either the completion block or the error block gets called.
     You decide on which queue these blocks get executed.

     **Example**:
     ```swift
     let networkService: NetworkService = //
     let resource: ResourceWithError<String, CustomError> = //

     networkService.request(queue: .main, resource: resource, onCompletionWithResponse: { htmlText, response in
        print(htmlText, response)
     }, onError: { error in
        // Handle errors
     })
     ```

     - parameter queue: The `DispatchQueue` to execute the completion and error block on.
     - parameter resource: The resource you want to fetch.
     - parameter onCompletionWithResponse: Callback which gets called when fetching and transforming into model succeeds.
     - parameter onError: Callback which gets called with an custom error.

     - returns: a running network task
     */
    @discardableResult
    public func request<Result, E: Error>(
        queue: DispatchQueue,
        resource: ResourceWithError<Result, E>,
        onCompletionWithResponse: @escaping (Result, HTTPURLResponse) -> Void,
        onError: @escaping (E) -> Void
    ) -> NetworkTask {
        let resourceWithoutError = Resource(request: resource.request, parse: resource.parse)
        return request(queue: queue, resource: resourceWithoutError, onCompletionWithResponse: onCompletionWithResponse) { networkError in
            onError(resource.mapError(networkError))
        }
    }

    /**
     Fetches a resource asynchronously from remote location. Execution of the requests starts immediately.
     Execution happens on no specific queue. It dependes on the network access which queue is used.
     Once execution is finished either the completion block or the error block gets called.
     These blocks are called on the main queue.

     **Example**:
     ```swift
     let networkService: NetworkService = //
     let resource: ResourceWithError<String, CustomError> = //

     networkService.request(resource, onCompletion: { htmlText in
        print(htmlText)
     }, onError: { error in
        // Handle errors
     })
     ```

     - parameter resource: The resource you want to fetch.
     - parameter onComplition: Callback which gets called when fetching and transforming into model succeeds.
     - parameter onError: Callback which gets called with an custom error.

     - returns: a running network task
     */
    @discardableResult
    public func request<Result, E: Error>(
        _ resource: ResourceWithError<Result, E>,
        onCompletion: @escaping (Result) -> Void,
        onError: @escaping (E) -> Void
    ) -> NetworkTask {
        return request(
            queue: .main,
            resource: resource,
            onCompletionWithResponse: { model, _ in onCompletion(model) },
            onError: onError
        )
    }

    /**
     Fetches a resource asynchronously from remote location. Execution of the requests starts immediately.
     Execution happens on no specific queue. It dependes on the network access which queue is used.
     Once execution is finished either the completion block or the error block gets called.
     You decide on which queue these blocks get executed.

     **Example**:
     ```swift
     let networkService: NetworkService = //
     let resource: ResourceWithError<String, CustomError> = //

     networkService.request(queue: .main, resource: resource, onCompletionWithResponse: { htmlText, response in
        print(htmlText, response)
     }, onError: { error in
        // Handle errors
     })
     ```

     - parameter queue: The `DispatchQueue` to execute the completion and error block on.
     - parameter resource: The resource you want to fetch.
     - parameter onCompletionWithResponse: Callback which gets called when fetching and transforming into model succeeds.
     - parameter onError: Callback which gets called with an custom error.

     - returns: a running network task
     */
    @discardableResult
    func request<Result, E: Error>(
        queue: DispatchQueue = .main,
        resource: ResourceWithError<Result, E>,
        onCompletionWithResponse: @escaping (Swift.Result<(Result, HTTPURLResponse), E>) -> Void
    ) -> NetworkTask {
        return request(
            queue: queue,
            resource: resource,
            onCompletionWithResponse: { result, response in
                onCompletionWithResponse(.success((result, response)))
            }, onError: { error in
                onCompletionWithResponse(.failure(error))
            }
        )
    }

    /**
     Fetches a resource asynchronously from remote location. Execution of the requests starts immediately.
     Execution happens on no specific queue. It dependes on the network access which queue is used.
     Once execution is finished either the completion block or the error block gets called.
     These blocks are called on the main queue.

     **Example**:
     ```swift
     let networkService: NetworkService = //
     let resource: ResourceWithError<String, CustomError> = //

     networkService.request(resource, onCompletion: { htmlText in
        print(htmlText)
     }, onError: { error in
        // Handle errors
     })
     ```

     - parameter resource: The resource you want to fetch.
     - parameter onComplition: Callback which gets called when fetching and transforming into model succeeds.
     - parameter onError: Callback which gets called with an custom error.

     - returns: a running network task
     */
    @discardableResult
    public func request<Result, E: Error>(
        _ resource: ResourceWithError<Result, E>,
        onCompletion: @escaping (Swift.Result<Result, E>) -> Void
    ) -> NetworkTask {
        return request(
            queue: .main,
            resource: resource,
            onCompletionWithResponse: { model, _ in onCompletion(.success(model)) },
            onError: { onCompletion(.failure($0))}
        )
    }

    /**
     Fetches a resource asynchronously from remote location. Execution of the requests starts immediately.
     Execution happens on no specific queue. It dependes on the network access which queue is used.
     Once execution is finished either the completion block or the error block gets called.
     These blocks are called on the main queue.

     **Example**:
     ```swift
     let networkService: NetworkService = //
     let resource: Resource<String> = //

     networkService.request(resource, onCompletionWithResponse: { htmlText, httpResponse in
        print(htmlText, httpResponse)
     }, onError: { error in
        // Handle errors
     })
     ```

     - parameter resource: The resource you want to fetch.
     - parameter onCompletion: Callback which gets called when fetching and transforming into model succeeds.
     - parameter onError: Callback which gets called when fetching or transforming fails.

     - returns: a running network task
     */
    @discardableResult
    func request<Result, E: Error>(_ resource: ResourceWithError<Result, E>, onCompletionWithResponse: @escaping (Result, HTTPURLResponse) -> Void,
                 onError: @escaping (E) -> Void) -> NetworkTask {
        return request(queue: .main, resource: resource, onCompletionWithResponse: onCompletionWithResponse, onError: onError)
    }
}
