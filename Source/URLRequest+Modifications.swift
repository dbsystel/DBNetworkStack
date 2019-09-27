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

public extension URLRequest {
    
    /// Creates a new `URLRequest` with HTTPHeaderFields added into the new request.
    /// Keep in mind that this overrides header fields which are already contained.
    ///
    /// - Parameter HTTPHeaderFields: the header fileds to add to the request
    /// - Returns: a new `URLRequest`
    func added(HTTPHeaderFields: [String: String]) -> URLRequest {
        var request = self
        let headerFiels = (request.allHTTPHeaderFields ?? [:]).merging(HTTPHeaderFields, uniquingKeysWith: { $1 })
        request.allHTTPHeaderFields = headerFiels
        
        return request
    }
    
    /// Creates a new `URLRequest` with query items appended to the new request.
    ///
    /// - Parameter queryItems: the query items to append to the request
    /// - Parameter overrideExisting: if `true existing items with the same name will be overridden
    /// - Returns: a new `URLRequest`
    func appending(queryItems: [URLQueryItem], overrideExisting: Bool = true) -> URLRequest {
        var request = self
        guard let url = request.url else {
            return self
        }
        request.url = url.appending(queryItems: queryItems)
        return request
    }
    
    /// Creates a new `URLRequest` with query parameters appended to the new request.
    ///
    /// - Parameter queryParameters: the parameters to append to the request
    /// - Parameter overrideExisting: if `true existing items with the same name will be overridden
    /// - Returns: a new `URLRequest`
    func appending(queryParameters: [String: String], overrideExisting: Bool = true) -> URLRequest {
        return appending(queryItems: queryParameters.asURLQueryItems() )
    }
    
    /// Creates a new `URLRequest` with all existing query items replaced with new ones.
    ///
    /// - Parameter queryItems: the query items to add to the request
    /// - Returns: a new `URLRequest`
    func replacingAllQueryItems(with queryItems: [URLQueryItem]) -> URLRequest {
       var request = self
        guard let url = request.url else {
            return self
        }
        request.url = url.replacingAllQueryItems(with: queryItems)
        return request
    }
    
    /// Creates a new `URLRequest` with all existing query items replaced with new ones.
    ///
    /// - Parameter parameters: the parameters to add to the request
    /// - Returns: a new `URLRequest`
    func replacingAllQueryItems(with parameters: [String: String]) -> URLRequest {
        return replacingAllQueryItems(with: parameters.asURLQueryItems() )
    }
}
