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

extension Resource where Model: Decodable {
    
    /// Creates an instace of Resource where the result type is `Decodable` and
    /// can be decoded with the given decoder
    ///
    /// - Parameters:
    ///   - request: The request to get the remote data payload
    ///   - decoder: a decoder which can decode the payload into the model type
    public init(request: URLRequest, decoder: JSONDecoder, parseError: @escaping (_ networkError: NetworkError) -> E) {
        self.init(request: request, parse: { try decoder.decode(Model.self, from: $0) }, parseError: parseError)
    }
}

extension Resource where Model: Decodable, E == NetworkError {

    /// Creates an instace of Resource where the result type is `Decodable` and
    /// can be decoded with the given decoder
    ///
    /// - Parameters:
    ///   - request: The request to get the remote data payload
    ///   - decoder: a decoder which can decode the payload into the model type
    public init(request: URLRequest, decoder: JSONDecoder) {
        self.init(request: request, parse: { try decoder.decode(Model.self, from: $0) })
    }

}
