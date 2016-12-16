//
//  NetworkResourceRepresening.swift
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
//  Created by Lukas Schmidt on 21.07.16.
//

import Foundation

/**
 `NetworkRequestRepresening` represents a networkreuqest with all components needed to retrieve correct resources.
 */
public protocol NetworkRequestRepresening {
    /**
     Path to the remote resource.
     */
    var path: String { get }
    
    /**
     The key which represents the matching baseURL to this request.
     */
    var baseURLKey: BaseURLKey { get }
    
    /**
     The HTTP Method.
     */
    var HTTPMethod: DBNetworkStack.HTTPMethod { get }
    
    /**
     Headers for the request.
     */
    var allHTTPHeaderFields: [String: String]? { get }
    
    /**
     Parameters which will be send with the request.
     */
    var parameter: [String : Any]? { get }
    
    /**
     Data payload of the request
     */
    var body: Data? { get }
}

extension NetworkRequestRepresening {
    /**
     Transforms self into a equivalent `URLRequest` with a given baseURL.
     
     - parameter baseURL: baseURL for the resulting request.
     - returns: the equivalent request
     */
    public func urlRequest(with baseURL: URL) -> URLRequest {
        let absoluteURL = absoluteURLWith(baseURL)
        let request = NSMutableURLRequest(url: absoluteURL)
        request.allHTTPHeaderFields = allHTTPHeaderFields
        request.httpMethod = HTTPMethod.rawValue
        request.httpBody = body
        
        return request as URLRequest
    }
    
    /**
     Creates an absulte URL of for the request by concating baseURL and path and apending request parameter
     
     - parameter baseURL: baseURL for the resulting url.
     - returns: absolute url for the request.
     */
    fileprivate func absoluteURLWith(_ baseURL: URL) -> URL {
        guard let absoluteURL = URL(string: path, relativeTo: baseURL) else {
            fatalError("Error createing absolute URL from path: \(path), with baseURL: \(baseURL)")
        }
        let urlComponents = URLComponents(url: absoluteURL, resolvingAgainstBaseURL: true)
        if let parameter = parameter, var urlComponents = urlComponents, !parameter.isEmpty {
            let percentEncodedQuery = parameter.map({ value in
                return "\(value.0)=\(value.1)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            }).flatMap { $0 }
            urlComponents.percentEncodedQuery = percentEncodedQuery.joined(separator: "&")
            
            guard let absoluteURL = urlComponents.url else {
                 fatalError("Error createing absolute URL from path: \(path), with baseURL: \(baseURL)")
            }
            return absoluteURL
        }
        
        return absoluteURL
    }
}
