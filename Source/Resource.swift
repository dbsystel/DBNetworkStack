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

/**
 `Resource` describes a remote resource of generic type.
 The type can be fetched via HTTP(S) and parsed into the coresponding model object.
 
 **Example**:
 ```swift
 let request: URLRequest = //
 let resource: Resource<String?> = Resource(request: request, parse: { data in
    String(data: data, encoding: .utf8)
 })
 ```
 */
public struct ResourceWithError<Model, E: Error> {
    /// The request to fetch the resource remote payload
    public let request: URLRequest
    
    /// Parses data into given model.
    public let parse: (_ data: Data) throws -> Model
    public let parseError: (_ networkError: NetworkError) -> E
    
    /// Creates a type safe resource, which can be used to fetch it with `NetworkService`
    ///
    /// - Parameters:
    ///   - request: The request to get the remote data payload
    ///   - parse: Parses data fetched with the request into given Model
    public init(request: URLRequest, parse: @escaping (Data) throws -> Model, parseError: @escaping (_ networkError: NetworkError) -> E) {
        self.request = request
        self.parse = parse
        self.parseError = parseError
    }
}

public typealias Resource<Model> = ResourceWithError<Model, NetworkError>

public extension Resource where E == NetworkError {

    /// Creates a type safe resource, which can be used to fetch it with `NetworkService`
    ///
    /// - Parameters:
    ///   - request: The request to get the remote data payload
    ///   - parse: Parses data fetched with the request into given Model
    init(request: URLRequest, parse: @escaping (Data) throws -> Model) {
        self.request = request
        self.parse = parse
        self.parseError = { return $0 }
    }

}
