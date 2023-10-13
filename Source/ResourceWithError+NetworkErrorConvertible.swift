//
//  File.swift
//  
//
//  Created by Lukas Schmidt on 13.10.23.
//

import Foundation

public extension ResourceWithError where E: NetworkErrorConvertible {

    init(request: URLRequest, parse: @escaping (Data) throws -> Model) {
        self.request = request
        self.parse = parse
        self.mapError = { E(networkError: $0) }
    }

}
