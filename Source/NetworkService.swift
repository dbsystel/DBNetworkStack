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
 `NetworkService` executes network request with resources. It uses a `NetworkAccessProviding` to send requests to the network.
 
 - seealso: `NetworkServiceProviding`
 */
public final class NetworkService: NetworkServiceProviding {
    private let networkAccess: NetworkAccessProviding
    private let networkResponseProcessor: NetworkResponseProcessor
    
    /**
     Creates an `NetworkService` instance with a given networkAccess.
     
     - parameter networkAccess: provides access to the network.
     */
    public init(networkAccess: NetworkAccessProviding) {
        self.networkAccess = networkAccess
        self.networkResponseProcessor = NetworkResponseProcessor()
    }
    
    /**
     Fetches a resource asynchronously from remote location
     
     ```swift
     
     let networkService: NetworkServiceProviding = //
     let resource: Resource<String> = //
     
     networkService.request(resource, onCompletion: { htmlText in
        print(htmlText)
     }, onError: { error in
        /Handle errors
     })
     ```
     
     - parameter resource: The resource you want to fetch.
     - parameter onCompletion: Callback which gets called when fetching and tranforming into model succeeds.
     - parameter onError: Callback which gets called when fetching or tranforming fails.
     
     - returns: a running network task
     */
    @discardableResult
    public func request<Result>(queue: DispatchQueue, resource: Resource<Result>, onCompletionWithResponse: @escaping (Result, HTTPURLResponse) -> Void,
                        onError: @escaping (NetworkError) -> Void) -> NetworkTaskRepresenting {
        let request = resource.request.asURLRequest()
        let dataTask = networkAccess.load(request: request, callback: { data, response, error in
            self.networkResponseProcessor.processAsyncResponse(queue: queue, response: response, resource: resource, data: data,
                                      error: error, onCompletion: onCompletionWithResponse, onError: onError)
        })
        return dataTask
    }
    
}
