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

struct NetworkServiceMockCallback {
    let onErrorCallback: (NetworkError) -> Void
    let onTypedSuccess: (Any, HTTPURLResponse) throws -> Void
    
    init<Result>(resource: Resource<Result>, onCompletionWithResponse: @escaping (Result, HTTPURLResponse) -> Void, onError: @escaping (NetworkError) -> Void) {
        onTypedSuccess = { anyResult, response in
            guard let typedResult = anyResult as? Result else {
                throw NetworkServiceMock.Error.typeMismatch
            }
            onCompletionWithResponse(typedResult, response)
        }
        onErrorCallback = { error in
            onError(error)
        }
    }
}

/**
 Mocks a `NetworkService`.
 You can configure expected results or errors to have a fully functional mock.
 
 **Example**:
 ```swift
 //Given
 let networkServiceMock = NetworkServiceMock()
 let resource: Resource<String> = //
 
 //When
 networkService.request(
    resource,
    onCompletion: { string in /*...*/ },
    onError: { error in /*...*/ }
 )
 networkService.returnSuccess(with: "Sucess")
 
 //Then
 //Test your expectations
 
 ```

 It is possible to start multiple requests at a time.
 All requests and responses (or errors) are processed
 in order they have been called. So, everything is serial.

 **Example**:
 ```swift
 //Given
 let networkServiceMock = NetworkServiceMock()
 let resource: Resource<String> = //
 
 //When
 networkService.request(
    resource,
    onCompletion: { string in /* Success */ },
    onError: { error in /*...*/ }
 )
 networkService.request(
    resource,
    onCompletion: { string in /*...*/ },
    onError: { error in /*. cancel error .*/ }
 )

 networkService.returnSuccess(with: "Sucess")
 networkService.returnError(with: .cancelled)

 //Then
 //Test your expectations
 
 ```
 
 - seealso: `NetworkService`
 */
public final class NetworkServiceMock: NetworkService {

    public enum Error: Swift.Error, CustomDebugStringConvertible {
        case missingRequest
        case typeMismatch

        public var debugDescription: String {
            switch self {
            case .missingRequest:
                return "Could not return because no request"
            case .typeMismatch:
                return "Return type does not match requested type"
            }
        }
    }
    
    /// Count of all started requests
    public var requestCount: Int {
        return lastRequests.count
    }
    
    /// Last executed request
    public var lastRequest: URLRequest? {
        return lastRequests.last
    }

    public var pendingRequestCount: Int {
        return callbacks.count
    }
    
    /// All executed requests.
    public private(set) var lastRequests: [URLRequest] = []
    
    /// Set this to hava a custom networktask returned by the mock
    public var nextNetworkTask: NetworkTask?
    
    private var callbacks: [NetworkServiceMockCallback] = []
    
    /// Creates an instace of `NetworkServiceMock`
    public init() {}
    
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
    public func request<Result>(queue: DispatchQueue, resource: Resource<Result>, onCompletionWithResponse: @escaping (Result, HTTPURLResponse) -> Void,
                                onError: @escaping (NetworkError) -> Void) -> NetworkTask {
        lastRequests.append(resource.request)
        callbacks.append(NetworkServiceMockCallback(
            resource: resource,
            onCompletionWithResponse: onCompletionWithResponse,
            onError: onError
        ))
        
        return nextNetworkTask ?? NetworkTaskMock()
    }
    
    /// Will return an error to the current waiting request.
    ///
    /// - Parameters:
    ///   - error: the error which gets passed to the caller
    /// 
    /// - Throws: An error of type `NetworkServiceMock.Error`
    public func returnError(with error: NetworkError) throws {
        guard !callbacks.isEmpty else {
            throw Error.missingRequest
        }
        callbacks.removeFirst().onErrorCallback(error)
    }
    
    /// Will return a successful request, by using the given type `T` as serialized result of a request.
    ///
    /// - Parameters:
    ///   - data: the mock response from the server. `Data()` by default
    ///   - httpResponse: the mock `HTTPURLResponse` from the server. `HTTPURLResponse()` by default
    ///
    /// - Throws: An error of type `NetworkServiceMock.Error`
    public func returnSuccess<T>(with serializedResponse: T, httpResponse: HTTPURLResponse = HTTPURLResponse()) throws {
        guard !callbacks.isEmpty else {
            throw Error.missingRequest
        }
        try callbacks.removeFirst().onTypedSuccess(serializedResponse, httpResponse)
    }

}
