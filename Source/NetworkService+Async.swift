//
//  File.swift
//  
//
//  Created by Lukas Schmidt on 19.12.21.
//

import Foundation

@available(watchOS 6.0, *)
@available(macOS 10.15.0, *)
@available(iOS 13.0.0, *)
public extension NetworkService {

    @discardableResult
    func request<Result>(_ resource: Resource<Result>) async throws -> (Result, HTTPURLResponse) {
        return try await withCheckedThrowingContinuation({ coninuation in
            request(resource: resource, onCompletionWithResponse: {
                coninuation.resume(with: $0)
            })
        })
    }

}
