//
//  NetworkRequest.swift
//
//  Copyright (C) 2016 DB Systel GmbH.
//	DB Systel GmbH; Jürgen-Ponto-Platz 1; D-60329 Frankfurt am Main; Germany; http://www.dbsystel.de/
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
//  Created by Lukas Schmidt on 21.07.16.
//

import Foundation

/**
 `NetworkRequest` represents a network reuqest with all components needed to retrieve correct resources.
 */
public struct NetworkRequest: NetworkRequestRepresening {
    public let path: String
    public let baseURLKey: BaseURLKey
    public let HTTPMethod: DBNetworkStack.HTTPMethod
    public let parameter: Dictionary<String, Any>?
    public let body: Data?
    public let allHTTPHeaderFields: Dictionary<String, String>?
}

public extension NetworkRequest {
    
    // swiftlint:disable line_length

    /// Creates a instance of `NetworkRequest` with given parameters
    ///
    /// - Parameters:
    ///   - path: the relative path to the source without the base url.
    ///   - baseURLKey: a key to a baseurl which was registerd at `Networkservice`
    ///   - HTTPMethod: http method to fetch the request with
    ///   - parameter: url parameter for the request.
    ///   - body: the body of the request encoded as data
    ///   - allHTTPHeaderField: the http headerfileds for the request
    public init(path: String, baseURLKey: BaseURLKey,
                HTTPMethod: DBNetworkStack.HTTPMethod = .GET, parameter: Dictionary<String, Any>? = nil,
                body: Data? = nil, allHTTPHeaderField: Dictionary<String, String>? = nil) {
        self.path = path
        self.baseURLKey = baseURLKey
        self.HTTPMethod = HTTPMethod
        self.allHTTPHeaderFields = allHTTPHeaderField
        self.parameter = parameter
        self.body = body
    }
}
