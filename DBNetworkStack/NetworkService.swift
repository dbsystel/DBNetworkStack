//
//  NetworkService.swift
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
//  Created by Lukas Schmidt on 31.08.16.
//

import Foundation

/**
 `NetworkService` handles network request for ressources by using a given NetworkAccessProviding
 */
public final class NetworkService: NetworkServiceProviding, BaseURLProviding {
    let networkAccess: NetworkAccessProviding
    let endPoints: Dictionary<String, NSURL>
    
    /**
     Creates an `NetworkService` instance with a given networkAccess and a map of endPoints
     
     - parameter networkAccess: provides basic access to the network.
     - parameter endPoints: map of baseURLKey -> baseURLs
     */
    public init(networkAccess: NetworkAccessProviding, endPoints: Dictionary<String, NSURL>) {
        self.networkAccess = networkAccess
        self.endPoints = endPoints
    }
    
    public func request<T: RessourceModeling>(ressource: T, onCompletion: (T.Model) -> (), onError: (DBNetworkStackError) -> ()) -> NetworkTask {
        let baseURL = self.baseURL(with: ressource)
        let reuqest = ressource.request.urlRequest(with: baseURL)
        let dataTask = networkAccess.load(request: reuqest, callback: { data, response, error in
            self.processAsyncResponse(response: response, ressource: ressource, data: data, error: error, onCompletion: onCompletion, onError: onError)
        })
        return dataTask
    }
    
}
