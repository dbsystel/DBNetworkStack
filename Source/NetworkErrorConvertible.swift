//
//  File.swift
//  
//
//  Created by Lukas Schmidt on 13.10.23.
//

import Foundation

public protocol NetworkErrorConvertible: Error {

    init(networkError: NetworkError)

}
