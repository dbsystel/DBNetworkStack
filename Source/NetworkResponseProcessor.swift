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

final class NetworkResponseProcessor {
    /**
     Processes the results of an HTTPRequest and parses the result the matching Model type of the given resource.
     
     Great error handling should be implemented here as well.
     
     - parameter response: response from the server. Could be nil
     - parameter resource: The resource matching the response.
     - parameter data: Returned data. Could be nil.
     - parameter error: the return error. Could be nil.
     
     - returns: the parsed model object.
     */
    func process<Result, E: Error>(response: HTTPURLResponse?, resource: ResourceWithError<Result, E>, data: Data?, error: Error?) throws -> Result {
        if let error = error {
            if case URLError.cancelled = error {
                throw NetworkError.cancelled
            }
            
            throw NetworkError.requestError(error: error)
        }
        if let responseError = NetworkError(response: response, data: data) {
            throw responseError
        }
        guard let data = data else {
            throw NetworkError.serverError(response: response, data: nil)
        }
        do {
            return try resource.parse(data)
        } catch let error {
            throw NetworkError.serializationError(error: error, data: data)
        }
    }
    
    /// This parseses a `HTTPURLResponse` with a given resource into the result type of the resource or errors.
    /// The result will be return via a blocks onCompletion/onError.
    ///
    /// - Parameters:
    ///   - queue: The `DispatchQueue` to execute the completion and error block on.
    ///   - response: the HTTPURLResponse one wants to parse.
    ///   - resource: the resource.
    ///   - data: the payload of the response.
    ///   - error: optional error from net network.
    ///   - onCompletion: completion block which gets called on the given `queue`.
    ///   - onError: error block which gets called on the given `queue`.
    func processAsyncResponse<Result, E: Error>(queue: DispatchQueue, response: HTTPURLResponse?, resource: ResourceWithError<Result, E>, data: Data?,
                              error: Error?, onCompletion: @escaping (Result, HTTPURLResponse) -> Void, onError: @escaping (E) -> Void) {
        do {
            let parsed = try process(
                response: response,
                resource: resource,
                data: data,
                error: error
            )
            queue.async {
                if let response = response {
                    onCompletion(parsed, response)
                } else {
                    onError(resource.parseError(NetworkError.unknownError))
                }
            }
        } catch let genericError {
            let dbNetworkError: NetworkError! = genericError as? NetworkError
            queue.async {
                return onError(resource.parseError(dbNetworkError))
            }
        }
    }
}
