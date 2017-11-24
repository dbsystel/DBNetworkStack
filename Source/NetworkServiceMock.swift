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
//  NetworkServiceMock.swift
//  DBNetworkStack
//
//  Created by Lukas Schmidt on 14.12.16.
//

import Foundation
import Dispatch

public class NetworkServiceMock: NetworkService {
    private var onErrorCallback: ((NetworkError) -> Void)?
    private var onSuccess: ((Data, HTTPURLResponse) -> Void)?
    private var onTypedSuccess: ((Any, HTTPURLResponse) -> Void)?
    
    public init() {}
    
    /// Count of all started requests
    public var requestCount: Int = 0
    /// Last executed request
    public var lastRequest: URLRequestConvertible?
    /// Set this to hava a custom networktask
    public var nextNetworkTask: NetworkTask?

    @discardableResult
    public func request<Result>(queue: DispatchQueue, resource: Resource<Result>, onCompletionWithResponse: @escaping (Result, HTTPURLResponse) -> Void,
                 onError: @escaping (NetworkError) -> Void) -> NetworkTask {

        lastRequest = resource.request
        requestCount += 1
        onSuccess = { data, response in
            guard let result = try? resource.parse(data) else {
                fatalError("Could not parse data into matching result type")
            }
            onCompletionWithResponse(result, response)
        }
        onTypedSuccess = { anyResult, response in
            guard let typedResult = anyResult as? Result else {
                fatalError("Extected type of \(Result.self) but got \(anyResult.self)")
            }
            onCompletionWithResponse(typedResult, response)
        }
        onErrorCallback = { error in
            onError(error)
        }
        
        return nextNetworkTask ?? NetworkTaskMock()
    }
    
    /// Will return an error to the current waiting request.
    ///
    /// - Parameters:
    ///   - error: the error which gets passed to the caller
    ///   - count: the count, how often the error accours. 1 by default
    public func returnError(with error: NetworkError, count: Int = 1) {
        for _ in 0..<count {
            onErrorCallback?(error)
        }
       releaseCapturedCallbacks()
    }
    
    /// Will return a successful request, by using the given data as a server response.
    ///
    /// - Parameters:
    ///   - data: the mock response from the server. `Data()` by default
    ///   - httpResponse: the mock `HTTPURLResponse` from the server. `HTTPURLResponse()` by default
    ///   - count: the count how often the response gets triggerd. 1 by default
    public func returnSuccess(with data: Data = Data(), httpResponse: HTTPURLResponse = HTTPURLResponse(), count: Int = 1) {
        for _ in 0..<count {
            onSuccess?(data, httpResponse)
        }
        releaseCapturedCallbacks()
    }
    
    /// Will return a successful request, by using the given type `T` as serialized result of a request.
    ///
    /// **Warning:** This will crash if type `T` does not match your expected ResponseType of your current request
    ///
    /// - Parameters:
    ///   - data: the mock response from the server. `Data()` by default
    ///   - httpResponse: the mock `HTTPURLResponse` from the server. `HTTPURLResponse()` by default
    ///   - count: the count how often the response gets triggerd. 1 by default
    public func returnSuccess<T>(with serializedResponse: T, httpResponse: HTTPURLResponse = HTTPURLResponse(), count: Int = 1) {
        for _ in 0..<count {
            onTypedSuccess?(serializedResponse, httpResponse)
        }
        releaseCapturedCallbacks()
    }
    
    private func releaseCapturedCallbacks() {
        onErrorCallback = nil
        onSuccess = nil
        onTypedSuccess = nil
    }
    
}
