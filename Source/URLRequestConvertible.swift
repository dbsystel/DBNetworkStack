//
//  Copyright (C) 2017 Lukas Schmidt.
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
//
//  URLRequestConvertible.swift
//  DBNetworkStack
//
//  Created by Lukas Schmidt on 21.02.17.
//

import Foundation

public protocol URLRequestConvertible {
    /// Returns a URL request
    ///
    /// - returns: A URL request.
    func asURLRequest() -> URLRequest
}

extension URLRequest: URLRequestConvertible {
    public func asURLRequest() -> URLRequest {
        return self
    }
}

extension URLRequest {
    public init(path: String, baseURL: URL,
                HTTPMethod: HTTPMethod = .GET, parameters: Dictionary<String, Any>? = nil,
                body: Data? = nil, allHTTPHeaderFields: Dictionary<String, String>? = nil) {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            fatalError("Error createing absolute URL from path: \(path), with baseURL: \(baseURL)")
        }
        let urlWithParameter = url.appendingURLQueryParameter(parameters)
        self.init(url: urlWithParameter)
        self.httpBody = body
        self.httpMethod = HTTPMethod.rawValue
        self.allHTTPHeaderFields = allHTTPHeaderFields
    }
}

extension URL {
    func appendingURLQueryParameter(_ parameters: Dictionary<String, Any>?) -> URL {
        let urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)
        if let parameters = parameters, var urlComponents = urlComponents, !parameters.isEmpty {
            let percentEncodedQuery = parameters.map({ value in
                return "\(value.0)=\(value.1)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            }).flatMap { $0 }
            urlComponents.percentEncodedQuery = percentEncodedQuery.joined(separator: "&")
            
            guard let absoluteURL = urlComponents.url else {
                fatalError("Error createing absolute URL from path: \(String(describing: path)), with baseURL: \(String(describing: baseURL))")
            }
            return absoluteURL
        }
        
        return absoluteURL
    }

}
