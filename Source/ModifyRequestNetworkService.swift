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
//  ModifyRequestNetworkService.swift
//  DBNetworkStack
//
//  Created by Lukas Schmidt on 16.12.16.
//

import Foundation
import Dispatch

/// `ModifyRequestNetworkService` can be composed with a networkService to modify all outgoing requests.
/// One could add auth tokens or API keys for specifics URLs.
public final class ModifyRequestNetworkService: NetworkService {
    
    private let requestModifications: Array<(URLRequestConvertible) -> URLRequestConvertible>
    private let networkService: NetworkService
    
    /// Creates an insatcne of `ModifyRequestNetworkService`.
    ///
    /// - Parameters:
    ///   - networkService: a networkservice.
    ///   - requestModifications: array of modifications to modify requests.
    public init(networkService: NetworkService, requestModifications: Array<(URLRequestConvertible) -> URLRequestConvertible>) {
        self.networkService = networkService
        self.requestModifications = requestModifications
    }
    
    @discardableResult
    public func request<Result>(queue: DispatchQueue, resource: Resource<Result>, onCompletionWithResponse: @escaping (Result, HTTPURLResponse) -> Void,
                        onError: @escaping (NetworkError) -> Void) -> NetworkTask {
        let request = requestModifications.reduce(resource.request, { request, modify in
            return modify(request)
        })
        let newResource = Resource(request: request, parse: resource.parse)
        return networkService.request(queue: queue, resource: newResource, onCompletionWithResponse: onCompletionWithResponse, onError: onError)
    }
}

public extension URLRequestConvertible {
    
    /// Creates a new `URLRequestConvertible` with HTTPHeaderFields added into the new request.
    /// Keep in mind that this overrides header fields which are already contained.
    ///
    /// - Parameter HTTPHeaderFields: the header fileds to add to the request
    /// - Returns: a new `URLRequestConvertible`
    func added(HTTPHeaderFields: [String: String]) -> URLRequestConvertible {
        var request = asURLRequest()
        let headerFiels = (request.allHTTPHeaderFields ?? [:]).merged(with: HTTPHeaderFields)
        request.allHTTPHeaderFields = headerFiels
        
        return request
    }
    
    /// Creates a new `URLRequestConvertible` with query items appended to the new request.
    ///
    /// - Parameter queryItems: the query items to append to the request
    /// - Parameter overrideExisting: if true existing items with the same name will be overridden
    /// - Returns: a new `URLRequestConvertible`
    func appending(queryItems: [URLQueryItem], overrideExisting: Bool = true) -> URLRequestConvertible {
        var request = asURLRequest()
        guard let url = request.url else {
            return self
        }
        request.url = url.appending(queryItems: queryItems)
        return request
    }
    
    /// Creates a new `URLRequestConvertible` with query parameters appended to the new request.
    ///
    /// - Parameter queryParameters: the parameters to append to the request
    /// - Parameter overrideExisting: if true existing items with the same name will be overridden
    /// - Returns: a new `URLRequestConvertible`
    func appending(queryParameters: [String: String], overrideExisting: Bool = true) -> URLRequestConvertible {
        return appending(queryItems: queryParameters.asURLQueryItems() )
    }
    
    /// Creates a new `URLRequestConvertible` with all existing query items replaced with new ones.
    ///
    /// - Parameter queryItems: the queryItems to add to the request
    /// - Returns: a new `URLRequestConvertible`
    func replacingAllQueryItems(with queryItems: [URLQueryItem]) -> URLRequestConvertible {
        var request = asURLRequest()
        guard let url = request.url else {
            return self
        }
        request.url = url.replacingAllQueryItems(with: queryItems)
        return request
    }
    
    /// Creates a new `URLRequestConvertible` with all existing query items replaced with new ones.
    ///
    /// - Parameter parameters: the parameters to add to the request
    /// - Returns: a new `URLRequestConvertible`
    func replacingAllQueryItems(with parameters: [String: String]) -> URLRequestConvertible {
        return replacingAllQueryItems(with: parameters.asURLQueryItems() )
    }
}

extension Dictionary {
    /// Creates a new `Dictionary` with all key and their values merged. Keep in mind that this overrides all keys/values which are already contained.
    ///
    /// - Parameter HTTPHeaderFields: the header fileds to add to the request
    /// - Returns: a new `NetworkRequestRepresening`
    func merged(with dictionary: Dictionary<Key, Value>) -> Dictionary<Key, Value> {
        var copySelf = self
        for (key, value) in dictionary {
            copySelf[key] = value
        }
        
        return copySelf
    }
}
