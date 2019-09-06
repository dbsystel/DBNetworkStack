//
//  NetworkService+Result.swift
//  DBNetworkStack
//
//  Created by Lukas Schmidt on 03.01.19.
//  Copyright © 2019 DBSystel. All rights reserved.
//

import Foundation

public extension NetworkService {
    
    /**
     Fetches a resource asynchronously from remote location. Execution of the requests starts immediately.
     Execution happens on no specific queue. It dependes on the network access which queue is used.
     Once execution is finished the completion block gets called.
     You decide on which queue completion gets executed. Defaults to `main`.
     
     **Example**:
     ```swift
     let networkService: NetworkService = //
     let resource: Resource<String> = //
     
     networkService.request(resource: resource, onCompletionWithResponse: { result in
     print(result)
     })
     ```
     
     - parameter queue: The `DispatchQueue` to execute the completion block on. Defaults to `main`.
     - parameter resource: The resource you want to fetch.
     - parameter onCompletionWithResponse: Callback which gets called when request completes.
     
     - returns: a running network task
     */
    @discardableResult
    func request<Result>(queue: DispatchQueue = .main,
                         resource: Resource<Result>,
                         onCompletionWithResponse: @escaping (Swift.Result<(Result, HTTPURLResponse), NetworkError>) -> Void) -> NetworkTask {
        return request(queue: queue,
                       resource: resource,
                       onCompletionWithResponse: { result, response in
                        onCompletionWithResponse(.success((result, response)))
        }, onError: { error in
            onCompletionWithResponse(.failure(error))
        })
    }
    
    /**
     Fetches a resource asynchronously from remote location. Execution of the requests starts immediately.
     Execution happens on no specific queue. It dependes on the network access which queue is used.
     Once execution is finished the completion block gets called.
     Completion gets executed on `main` queue.
     
     **Example**:
     ```swift
     let networkService: NetworkService = //
     let resource: Resource<String> = //
     
     networkService.request(resource, onCompletion: { result in
     print(result)
     })
     ```
     
     - parameter resource: The resource you want to fetch.
     - parameter onComplition: Callback which gets called when request completes.
     
     - returns: a running network task
     */
    @discardableResult
    func request<Result>(_ resource: Resource<Result>,
                         onCompletion: @escaping (Swift.Result<Result, NetworkError>) -> Void) -> NetworkTask {
        return request(resource: resource,
                       onCompletionWithResponse: { result in
                        switch result {
                        case .success(let response):
                            onCompletion(.success(response.0))
                        case .failure(let error):
                            onCompletion(.failure(error))
                        }
        })
    }
}
