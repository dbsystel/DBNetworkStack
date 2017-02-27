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

/// `ModifyRequestNetworkService` can be composed with a networkService to modify all outgoing requests.
/// One could add auth tokens or API keys for specifics URLs.
public final class ModifyRequestNetworkService: NetworkServiceProviding {
    
    private let requestModifications: Array<(URLRequestConvertible) -> URLRequestConvertible>
    private let networkService: NetworkServiceProviding
    
    /// Creates an insatcne of `ModifyRequestNetworkService`.
    ///
    /// - Parameters:
    ///   - networkService: a networkservice.
    ///   - requestModifications: array of modifications to modify requests.
    public init(networkService: NetworkServiceProviding, requestModifications: Array<(URLRequestConvertible) -> URLRequestConvertible>) {
        self.networkService = networkService
        self.requestModifications = requestModifications
    }
    
    public func request<T: ResourceModeling>(queue: DispatchQueue, resource: T, onCompletion: @escaping (T.Model) -> Void,
                        onError: @escaping (DBNetworkStackError) -> Void) -> NetworkTaskRepresenting {
        let request = requestModifications.reduce(resource.request, { request, modify in
            return modify(request)
        })
        let newResource = Resource(request: request, parse: resource.parse)
        return networkService.request(queue: queue, newResource, onCompletion: onCompletion, onError: onError)
    }
}

public extension URLRequestConvertible {
    
    /// Creates a new `NetworkRequestRepresening` with HTTPHeaderFields added into the new request.
    /// Keep in mind that this overrides header fields which are already contained.
    ///
    /// - Parameter HTTPHeaderFields: the header fileds to add to the request
    /// - Returns: a new `NetworkRequestRepresening`
    func added(HTTPHeaderFields: [String: String]) -> URLRequestConvertible {
        var request = asURLRequest()
        let headerFiels = (request.allHTTPHeaderFields ?? [:]).merged(with: HTTPHeaderFields)
        request.allHTTPHeaderFields = headerFiels
        
        return request
    }
    
    /// Creates a new `NetworkRequestRepresening` with query parameters added into the new request.
    /// Keep in mind that this overrides parameters which are already contained.
    ///
    /// - Parameter parameter: the parameter to add to the request
    /// - Returns: a new `NetworkRequestRepresening`
    func added(parameter: [String: Any]) -> URLRequestConvertible {
        var request = asURLRequest()
        let url = request.url?.appendingURLQueryParameter(parameter)
        request.url = url
        
        return request
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
