//
//  File.swift
//  
//
//  Created by Lukas Schmidt on 12.04.21.
//

import Foundation

public extension Resource where Model == Void {

    /// Creates an instace of Resource where the result type is `Void`
    ///
    /// - Parameters:
    ///   - request: The request to get the remote data payload
    init(request: URLRequest) {
        self.init(request: request, parse: { _,_  in })
    }
}

extension ResourceWithError where Model == Void {

    /// Creates an instace of Resource where the result type is `Void`
    ///
    /// - Parameters:
    ///   - request: The request to get the remote data payload
    ///   - mapError: a closure which maps to Error
    public init(request: URLRequest, mapError: @escaping (_ networkError: NetworkError) -> E) {
        self.init(request: request, parse: { _,_   in }, mapError: mapError)
    }
}
