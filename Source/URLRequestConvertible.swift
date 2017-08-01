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
    
    @available(*, deprecated, message: "Use the new initializer using [String:String]? as the parameters value")
    init(path: String, baseURL: URL,
                HTTPMethod: HTTPMethod = .GET, parameters: [String: Any]? = nil,
                body: Data? = nil, allHTTPHeaderFields: Dictionary<String, String>? = nil) {
        let mappedParameters: [String:String]?
        if let parameters = parameters {
            var convertedParams = [String: String]()
            for (key, value) in parameters {
                convertedParams[key] = "\(value)"
            }
            mappedParameters = convertedParams
        } else {
            mappedParameters = nil
        }
        
        self.init(path: path, baseURL: baseURL, HTTPMethod: HTTPMethod, parameters: mappedParameters, body: body, allHTTPHeaderFields: allHTTPHeaderFields)
    }
    
    public init(path: String, baseURL: URL,
                HTTPMethod: HTTPMethod = .GET, parameters: [String: String]? = nil,
                body: Data? = nil, allHTTPHeaderFields: Dictionary<String, String>? = nil) {
        guard let url = URL(string: path, relativeTo: baseURL) else {
            fatalError("Error createing absolute URL from path: \(path), with baseURL: \(baseURL)")
        }
        
        let urlWithParameters: URL
        if let parameters = parameters {
            urlWithParameters = url.appending(queryParameters: parameters)
        } else {
            urlWithParameters = url
        }
        
        self.init(url: urlWithParameters)
        self.httpBody = body
        self.httpMethod = HTTPMethod.rawValue
        self.allHTTPHeaderFields = allHTTPHeaderFields
    }
}

extension Array where Element == URLQueryItem {
    
    func appending(queryItems: [URLQueryItem], overrideExisting: Bool = true) -> [URLQueryItem] {
        var items = overrideExisting ? [URLQueryItem]() : self
        
        var itemsToAppend = queryItems
        
        if overrideExisting {
            for item in self {
                var itemFound = false
                for (index, value) in itemsToAppend.enumerated() {
                    if value.name == item.name {
                        itemFound = true
                        items.append(value)
                        itemsToAppend.remove(at: index)
                        break
                    }
                }
                if itemFound == false {
                    items.append(item)
                }
            }
        }
        
        items.append(contentsOf: itemsToAppend)
        
        return items
    }
    
    func appending(queryParameters: [String: String], overrideExisting: Bool = true) -> [URLQueryItem] {
        return appending(queryItems: queryParameters.asURLQueryItems(), overrideExisting: overrideExisting)
    }
}

extension Dictionary where Key == String, Value == String {
    func asURLQueryItems() -> [URLQueryItem] {
        return map { URLQueryItem(name: $0.0, value: $0.1) }
    }
}

extension URL {
    
    func modifyingComponents(using block:(inout URLComponents) -> Void) -> URL {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            fatalError("Could not create url components from \(self.absoluteString)")
        }
        
        block(&urlComponents)
        
        guard let absoluteURL = urlComponents.url else {
            fatalError("Error creating absolute URL from path: \(path), with baseURL: \(baseURL?.absoluteString)")
        }
        return absoluteURL
    }
    
    func appending(queryItems: [URLQueryItem], overrideExisting: Bool = true) -> URL {
        return modifyingComponents { urlComponents in
            let items = urlComponents.queryItems ?? [URLQueryItem]()
            urlComponents.queryItems = items.appending(queryItems: queryItems, overrideExisting: overrideExisting)
        }
    }
    
    func appending(queryParameters: [String: String], overrideExisting: Bool = true) -> URL {
        return appending(queryItems: queryParameters.asURLQueryItems(), overrideExisting: overrideExisting)
    }
    
    func replacingAllQueryItems(with queryItems: [URLQueryItem]) -> URL {
        return modifyingComponents { urlComonents in
            urlComonents.queryItems = queryItems
        }
    }
    
    func replacingAllQueryParameters(with queryParameters: [String: String]) -> URL {
        return replacingAllQueryItems(with: queryParameters.asURLQueryItems())
    }
}
