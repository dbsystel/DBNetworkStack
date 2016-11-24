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
public enum DBNetworkStackError: Error {
    case unknownError
    case unauthorized(response: HTTPURLResponse)
    case clientError(response: HTTPURLResponse?)
    case serializationError(description: String, data: Data?)
    case requestError(error: Error)
    case serverError(response: HTTPURLResponse?)
    case missingBaseURL
    
    init?(response: HTTPURLResponse?) {
        guard let response = response else {
            return nil
        }
        switch response.statusCode {
        case 200..<300: return nil
        case 401:
            self = .unauthorized(response: response)
        case 400...451:
            self = .clientError(response: response)
        case 500...511:
            self = .serverError(response: response)
        default:
            return nil
        }
    }
    
}

extension DBNetworkStackError : CustomDebugStringConvertible {
    
    public var debugDescription: String {
        var result = ""
        
        switch self {
        case .unknownError:
            result = "Unknown error"
        case .unauthorized(let response):
            result = "Authorization error: \(response)"
        case .clientError(let response):
            result = "Client error: \(response)"
        case .serializationError(let description, let data):
            result = "Serialization error: \(description)"
            if let data = data, let string = String(data: data, encoding: String.Encoding.utf8) {
                result.append("\n\tdata: \(string)")
            }
        case .requestError(let error):
            result = "Request error: \(error)"
        case .serverError(let response):
            result = "Server error: \(response)"
        case .missingBaseURL:
            result = "Missing base url error"
        }
        
        return result
    }
}
