//
//  Copyright (C) 2016 DB Systel GmbH.
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

/**
`ModifyRequestNetworkService` can be composed with a networkService to modify all outgoing requests.
One could add auth tokens or API keys for specifics URLs.
 
 - note: Requests can only be modified syncronously.
 - seealso: `NetworkServiceProviding`
 */
public final class ModifyRequestNetworkService: NetworkServiceProviding {
    
    private let requestModifications: Array<(URLRequestConvertible) -> URLRequestConvertible>
    private let networkService: NetworkServiceProviding
    
    /// Creates an insatcne of `ModifyRequestNetworkService`.
    ///
    /// - Parameters:
    ///   - networkService: a networkservice.
    ///   - requestModifications: array of modifications to modify a requests.
    public init(networkService: NetworkServiceProviding, requestModifications: Array<(URLRequestConvertible) -> URLRequestConvertible>) {
        self.networkService = networkService
        self.requestModifications = requestModifications
    }
    
    @discardableResult
    public func request<Result>(queue: DispatchQueue, resource: Resource<Result>, onCompletionWithResponse: @escaping (Result, HTTPURLResponse) -> Void,
                        onError: @escaping (NetworkError) -> Void) -> NetworkTaskRepresenting {
        let request = requestModifications.reduce(resource.request, { request, modify in
            return modify(request)
        })
        let newResource = Resource(request: request, parse: resource.parse)
        return networkService.request(queue: queue, resource: newResource, onCompletionWithResponse: onCompletionWithResponse, onError: onError)
    }
}
