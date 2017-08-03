//
//  DBNetworkStackError.swift
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
//  Created by Lukas Schmidt on 23.08.16.
//

import Foundation

/**
 `DBNetworkStackError` provides a collection of error types which can occur during execution.
 */
public enum NetworkError: Error {
    case unknownError
    case cancelled
    case unauthorized(response: HTTPURLResponse, data: Data?)
    case clientError(response: HTTPURLResponse?, data: Data?)
    case serializationError(description: String, data: Data?)
    case requestError(error: Error)
    case serverError(response: HTTPURLResponse?, data: Data?)
    
    init?(response: HTTPURLResponse?, data: Data?) {
        guard let response = response else {
            return nil
        }
        
        switch response.statusCode {
        case 200..<300: return nil
        case 401:
            self = .unauthorized(response: response, data: data)
        case 400...451:
            self = .clientError(response: response, data: data)
        case 500...511:
            self = .serverError(response: response, data: data)
        default:
            return nil
        }
    }
    
}

extension String {
    fileprivate func appendingContentsOf(data: Data?) -> String {
        if let data = data, let string = String(data: data, encoding: .utf8) {
            return self.appending(string)
        }
        return self
    }
}

extension NetworkError: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        switch self {
        case .unknownError:
            return "Unknown error"
        case .cancelled:
            return "Request cancelled"
        case .unauthorized(let response, let data):
            return "Authorization error: \(response), response: ".appendingContentsOf(data: data)
        case .clientError(let response, let data):
            if let response = response {
                return "Client error: \((response)), response: ".appendingContentsOf(data: data)
            }
            return "Client error, response: ".appendingContentsOf(data: data)
        case .serializationError(let description, let data):
            return "Serialization error: \(description), response: ".appendingContentsOf(data: data)
        case .requestError(let error):
            return "Request error: \(error)"
        case .serverError(let response, let data):
            if let response = response {
                return "Server error: \(String(describing: response)), response: ".appendingContentsOf(data: data)
            } else {
                return "Server error: nil, response: ".appendingContentsOf(data: data)
            }

        }
    }
}
