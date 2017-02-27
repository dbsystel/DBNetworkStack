//
//  URLSessionNetworkAccess.swift
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
//  Created by Lukas Schmidt on 05.09.16.
//

import Foundation

/**
 Adds conformens to `NetworkAccessProviding`. `URLSession` can now be used as a networkprovider.
 */
extension URLSession: URLSessionProtocol {}

extension URLSessionDataTask: NetworkTaskRepresenting {
    public var progress: Progress {
        let totalBytesExpected = response?.expectedContentLength ?? NSURLSessionTransferSizeUnknown
        let progress = Progress(totalUnitCount: totalBytesExpected)
        progress.totalUnitCount = totalBytesExpected
        progress.completedUnitCount = countOfBytesReceived
        
        return progress
    }
}

public protocol URLSessionProtocol: NetworkAccessProviding {
    
     func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
    
}

public extension URLSessionProtocol {
    func load(request: URLRequest, callback: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) -> NetworkTaskRepresenting {
        let task = dataTask(with: request, completionHandler: { data, response, error in
            callback(data, response as? HTTPURLResponse, error)
        })
        
        task.resume()
        
        return task
    }
}
