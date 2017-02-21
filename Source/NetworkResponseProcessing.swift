//
//  Copyright (C) 2017 Lukas Schmidt.
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
//  NetworkResponseProcessing.swift
//  DBNetworkStack
//
//  Created by Lukas Schmidt on 13.02.17.
//

import Foundation
import Dispatch

public protocol NetworkResponseProcessing {
    /**
     Processes the results of an HTTPRequest and parses the result the matching Model type of the given resource.
     
     Great error handling should be implemented here as well.
     
     - parameter response: response from the server. Could be nil
     - parameter resource: The resource matching the response.
     - parameter data: Returned data. Could be nil.
     - parameter error: the return error. Could be nil.
     
     - returns: the parsed model object.
     */
    func process<T: ResourceModeling>(response: HTTPURLResponse?, resource: T, data: Data?, error: Error?) throws -> T.Model
}

extension NetworkResponseProcessing {
    public func process<T: ResourceModeling>(response: HTTPURLResponse?, resource: T, data: Data?, error: Error?) throws -> T.Model {
        if let error = error {
            
            if case URLError.cancelled = error {
                throw DBNetworkStackError.cancelled
            }
            
            throw DBNetworkStackError.requestError(error: error)
        }
        if let responseError = DBNetworkStackError(response: response, data: data) {
            throw responseError
        }
        guard let data = data else {
            throw DBNetworkStackError.serializationError(description: "No data to serialize revied from the server", data: nil)
        }
        do {
            return try resource.parse(data)
        } catch let error as CustomStringConvertible {
            throw DBNetworkStackError.serializationError(description: error.description, data: data)
        } catch {
            throw DBNetworkStackError.serializationError(description: "Unknown serialization error", data: data)
        }
    }
}

extension NetworkResponseProcessing {
    
    /// This parseses a `HTTPURLResponse` with a given resource into the result type of the resource or errors.
    /// The result will be return via a blocks onCompletion/onError.
    ///
    /// - Parameters:
    ///   - queue: The DispatchQueue to execute the completion and error block on.
    ///   - response: the HTTPURLResponse one wants to parse.
    ///   - resource: the resource.
    ///   - data: the payload of the response.
    ///   - error: optional error from net network.
    ///   - onCompletion: completion block which gets called on the given `queue`.
    ///   - onError: error block which gets called on the given `queue`.
    func processAsyncResponse<T: ResourceModeling>(queue: DispatchQueue, response: HTTPURLResponse?, resource: T, data: Data?,
                              error: Error?, onCompletion: @escaping (T.Model) -> Void, onError: @escaping (DBNetworkStackError) -> Void) {
        do {
            let parsed = try process(
                response: response,
                resource: resource,
                data: data,
                error: error
            )
            queue.async {
                onCompletion(parsed)
            }
        } catch let parsingError as DBNetworkStackError {
            queue.async {
                return onError(parsingError)
            }
        } catch {
            queue.async {
                return onError(.unknownError)
            }
        }
    }
}
