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
import Dispatch

/**
 `NetworkServiceProviding` provides access to remote resources.
 */
public protocol NetworkServiceProviding {
    /**
     Fetches a resource asynchrony from remote location
     
     - parameter queue: The DispatchQueue to execute the completion and error block on.
     - parameter resource: The resource you want to fetch.
     - parameter onComplition: Callback which gets called when fetching and tranforming into model succeeds.
     - parameter onError: Callback which gets called when fetching or tranforming fails.
     
     - returns: the request
     */
    @discardableResult
    func request<T: ResourceModeling>(queue: DispatchQueue, resource: T, onCompletion: @escaping (T.Model, HTTPURLResponse) -> Void,
                 onError: @escaping (DBNetworkStackError) -> Void) -> NetworkTaskRepresenting
}

extension NetworkServiceProviding {
    /**
     Fetches a resource asynchrony from remote location
     
     - parameter queue: The DispatchQueue to execute the completion and error block on. MainQueue by default.
     - parameter resource: The resource you want to fetch.
     - parameter onComplition: Callback which gets called when fetching and tranforming into model succeeds.
     - parameter onError: Callback which gets called when fetching or tranforming fails.
     
     - returns: the request
     */
    @discardableResult
    public func request<T: ResourceModeling>(queue: DispatchQueue = .main, _ resource: T, onCompletion: @escaping (T.Model) -> Void,
                 onError: @escaping (DBNetworkStackError) -> Void) -> NetworkTaskRepresenting {
        return request(queue: queue, resource: resource, onCompletion: { model, _ in onCompletion(model) }, onError: onError)
    }
    
    /**
     Fetches a resource asynchrony from remote location
     
     - parameter queue: The DispatchQueue to execute the completion and error block on.
     - parameter resource: The resource you want to fetch.
     - parameter onComplition: Callback which gets called when fetching and tranforming into model succeeds.
     - parameter onError: Callback which gets called when fetching or tranforming fails.
     
     - returns: the request
     */
    @discardableResult
    func request<T: ResourceModeling>(queue: DispatchQueue  = .main, resource: T, onCompletion: @escaping (T.Model, HTTPURLResponse) -> Void,
                 onError: @escaping (DBNetworkStackError) -> Void) -> NetworkTaskRepresenting {
        return request(queue: queue, resource: resource, onCompletion: onCompletion, onError: onError)
    }
}
