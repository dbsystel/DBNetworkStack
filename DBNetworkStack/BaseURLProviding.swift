//
//  BaseURLProviding.swift
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
//  Created by Christian Himmelsbach on 29.09.16.
//

import Foundation

internal protocol BaseURLProviding {
    
    var endPoints: [String: URL] {get}
    /**
     Provides an baseURL for a given ressource.
     
     To be more flexible, a request does only contain a path and not a full URL.
     Mapping has to be done in the service to get an registerd baseURL for the request.
     
     - parameter ressource: The ressource you want to get a baseURL for.
     
     - return matching baseURL to the given ressource
     */
    func baseURL<T: RessourceModeling>(with ressource: T) -> URL
}

extension BaseURLProviding {

    func baseURL<T: RessourceModeling>(with ressource: T) -> URL {
        
        guard let baseURL = endPoints[ressource.request.baseURLKey.name] else {
            fatalError("Missing baseurl for key: \(ressource.request.baseURLKey.name)")
        }
        
        return baseURL
    }
    
}
