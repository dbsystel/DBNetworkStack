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
 `NetworkServiceProviding` provides access to remote resources. It should be used as an abstraction for all outgoing network resource.
 
 **Abstract different layers**
 
Builing layerd network abstraction can be very easy, when all layers conform to `NetworkServiceProviding`.
 By doing so composing different features into a layerd system becomes very easy.
 
 **Example**
 ```swift
 //Baselayer, which executes network calls
 let networkService: NetworkServiceProviding = NetworkService(networkAccess: URLSession(configuration: .default))
 
 //Imaginary CachedNetworkService, which is able to look up cached resources
 let cachedNetworkService: NetworkServiceProviding = CachedNetworkService(networkService: networkService)
 
 //Add Auth tokens to each request
 let autheticationNetworkService = ModifyRequestNetworkService(networkService: cachedNetworkService, requestModifications: [{ $0.addAuthetication() }])
 ```
 
 - note: `NetworkServiceProviding` is good extension point for adding support for other async concpets like Result types, feature/promise, etc.
 */
public protocol NetworkServiceProviding {
    /**
     Fetches a resource asynchronously from remote location.
     One can specify a queue where completeion or error block is called.
     
     **Example**
     ```swift
     
     let networkService: NetworkServiceProviding = //
     let resource: Resource<String> = //
     
     networkService.request(resource, onCompletionWithResponse: { htmlText, response in
        print(htmlText)
     }, onError: { error in
        //Handle errors
     })
     ```
     
     - note: Use convience methods if you are not intrested in the `HTTPURLResponse`.
     
     - note: Use convience methods if completion/error block should be allways called on the main queue.
     
     - parameter queue: The DispatchQueue to execute the completion and error block on.
     - parameter resource: The resource you want to fetch.
     - parameter onCompletionWithResponse: Callback which gets called when fetching and tranforming into model succeeds.
     - parameter onError: Callback which gets called when fetching or tranforming fails.
     
     - returns: a running network task
     */
    @discardableResult
    func request<Result>(queue: DispatchQueue, resource: Resource<Result>, onCompletionWithResponse: @escaping (Result, HTTPURLResponse) -> Void,
                 onError: @escaping (NetworkError) -> Void) -> NetworkTaskRepresenting
}

public extension NetworkServiceProviding {
    /**
     Fetches a resource asynchronously from remote location. Completion and Error block will be called on the main queue.
     
     **Example**
     ```swift
     
     let networkService: NetworkServiceProviding = //
     let resource: Resource<String> = //
     
     networkService.request(resource, onCompletion: { htmlText in
        print(htmlText)
     }, onError: { error in
        //Handle errors
     })
     ```
     
     - parameter resource: The element you want to fetch. It matches the type of your resource.
     - parameter onComplition: Callback which gets called when fetching and tranforming into model succeeds.
     - parameter onError: Callback which gets called when fetching or tranforming fails.
     
     - returns: a running network task
     */
    @discardableResult
    func request<Result>(_ resource: Resource<Result>, onCompletion: @escaping (Result) -> Void,
                 onError: @escaping (NetworkError) -> Void) -> NetworkTaskRepresenting {
        return request(queue: .main, resource: resource, onCompletionWithResponse: { model, _ in onCompletion(model) }, onError: onError)
    }
    
    /**
     Fetches a resource asynchronously from remote location. Completion and Error block will be called on the main thread.
     
     **Example**
     ```swift
     
     let networkService: NetworkServiceProviding = //
     let resource: Resource<String> = //
     
     networkService.request(resource, onCompletionWithResponse: { htmlText, response in
        print(htmlText)
     }, onError: { error in
        //Handle errors
     })
     ```
     
     - parameter resource: The element you want to fetch. It matches the type of your resource.
     - parameter onCompletionWithResponse: Callback which gets called when fetching and tranforming into model succeeds.
     - parameter onError: Callback which gets called when fetching or tranforming fails.
     
     - returns: a running network task
     */
    @discardableResult
    func request<Result>(_ resource: Resource<Result>, onCompletionWithResponse: @escaping (Result, HTTPURLResponse) -> Void,
                 onError: @escaping (NetworkError) -> Void) -> NetworkTaskRepresenting {
        return request(queue: .main, resource: resource, onCompletionWithResponse: onCompletionWithResponse, onError: onError)
    }
}
