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
    
    func request<T>(_ resource: Resource<T>) -> Future<(T, HTTPURLResponse), NetworkError> {
        return Future<(T, HTTPURLResponse), NetworkError> { (promise) in
            self.request(resource: resource, onCompletionWithResponse: promise)
        }
    }
    
}
