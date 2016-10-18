//
//  NetworkServiceProviding.swift
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
 `NetworkServiceProviding` provides access to remote ressources.
 */
public protocol NetworkServiceProviding: NetworkResponseProcessing {
    /**
     Fetches a ressource asynchrony from remote location
     
     - parameter ressource: The ressource you want to fetch.
     - parameter onComplition: Callback which gets called when fetching and tranforming into model succeeds.
     - parameter onError: Callback which gets called when fetching or tranforming fails.
     
     - returns: the request
     */
    func request<T: RessourceModeling>(_ ressource: T, onCompletion: @escaping (T.Model) -> (), onError: @escaping (DBNetworkStackError) -> ()) -> NetworkTask
}

public protocol NetworkResponseProcessing {
    /**
     Processes the results of an HTTPRequest and parses the result the matching Model type of the given ressource.
     
     Great error handling should be implemented here as well.
     
     - parameter response: response from the server. Could be nil
     - parameter ressource: The ressource matching the response.
     - parameter data: Returned data. Could be nil.
     - parameter error: the return error. Could be nil.
     
     - returns: the parsed model object.
     */
    func process<T: RessourceModeling>(response: HTTPURLResponse?, ressource: T, data: Data?, error: Error?) throws -> T.Model
}

extension NetworkResponseProcessing {
    public func process<T: RessourceModeling>(response: HTTPURLResponse?, ressource: T, data: Data?, error: Error?) throws -> T.Model {
        if let error = error {
            throw DBNetworkStackError.requestError(error: error)
        }
        if let responseError = DBNetworkStackError(response: response) {
            throw responseError
        }
        guard let data = data else {
            throw DBNetworkStackError.serializationError(description: "No data to serialize revied from the server", data: nil)
        }
        do {
            return try ressource.parse(data)
        } catch let error as CustomStringConvertible {
            throw DBNetworkStackError.serializationError(description: error.description, data: data)
        } catch {
            throw DBNetworkStackError.serializationError(description: "Unknown serialization error", data: data)
        }
    }
}

extension NetworkResponseProcessing {
    func processAsyncResponse<T: RessourceModeling>(response: HTTPURLResponse?, ressource: T, data: Data?,
                              error: Error?, onCompletion: @escaping (T.Model) -> (), onError: @escaping (DBNetworkStackError) -> ()) {
        do {
            let parsed = try self.process(
                response: response,
                ressource: ressource,
                data: data,
                error: error
            )
            DispatchQueue.main.async {
                onCompletion(parsed)
            }
        } catch let parsingError as DBNetworkStackError {
            DispatchQueue.main.async {
                return onError(parsingError)
            }
        } catch {
            DispatchQueue.main.async {
                return onError(.unknownError)
            }
        }
    }
    
}
