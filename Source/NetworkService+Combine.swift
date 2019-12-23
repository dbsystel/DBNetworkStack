//
//  NetworkService+Combine.swift
//  DBNetworkStack
//
//  Created by Lukas Schmidt on 23.12.19.
//  Copyright © 2019 DBSystel. All rights reserved.
//

import Foundation
import Combine

@available(iOS 13.0, *)
public extension NetworkService {
    
    /**
     Fetches a resource asynchronously from remote location. Execution of the requests starts immediately.
     Execution happens on no specific queue. It dependes on the network access which queue is used.
     
     **Example**:
     ```swift
     let networkService: NetworkService = //
     let resource: Resource<String> = //
     
     let future = networkService.request(resource: resource)
     
     // Handle combine future
     ```
     
     - parameter resource: The resource you want to fetch.
     
     - returns: a future of the network request result
     */
    func request<T>(_ resource: Resource<T>) -> Future<(T, HTTPURLResponse), NetworkError> {
        return Future<(T, HTTPURLResponse), NetworkError> { (promise) in
            self.request(resource: resource, onCompletionWithResponse: promise)
        }
    }
    
}
