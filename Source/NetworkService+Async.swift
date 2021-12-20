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

    /**
     Fetches a resource asynchronously from remote location. Execution of the requests starts immediately.

     **Example**:
     ```swift
     let networkService: NetworkService = //
     let resource: Resource<String> = //

     let (result, response) = try await networkService.request(resource)
     ```

     - parameter resource: The resource you want to fetch.

     - returns: a touple  containing the parsed result and the HTTP response
     - Throws: A `NetworkError`
     */
    @discardableResult
    func request<Result>(_ resource: Resource<Result>) async throws -> (Result, HTTPURLResponse) {
        return try await withCheckedThrowingContinuation({ coninuation in
            request(resource: resource, onCompletionWithResponse: {
                coninuation.resume(with: $0)
            })
        })
    }

}
