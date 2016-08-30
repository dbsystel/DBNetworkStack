//
//  NetworkRequest.swift
//  DBNetworkStack
//
//	Legal Notice! DB Systel GmbH proprietary License!
//
//	Copyright (C) 2015 DB Systel GmbH
//	DB Systel GmbH; Jürgen-Ponto-Platz 1; D-60329 Frankfurt am Main; Germany; http://www.dbsystel.de/

//	This code is protected by copyright law and is the exclusive property of
//	DB Systel GmbH; Jürgen-Ponto-Platz 1; D-60329 Frankfurt am Main; Germany; http://www.dbsystel.de/

//	Consent to use ("licence") shall be granted solely on the basis of a
//	written licence agreement signed by the customer and DB Systel GmbH. Any
//	other use, in particular copying, redistribution, publication or
//	modification of this code without written permission of DB Systel GmbH is
//	expressly prohibited.

//	In the event of any permitted copying, redistribution or publication of
//	this code, no changes in or deletion of author attribution, trademark
//	legend or copyright notice shall be made.
//
//  Created by Lukas Schmidt on 21.07.16.
//

import Foundation

/**
 See `NetworkRequestRepresening` for details.
 */
public struct NetworkRequest: NetworkRequestRepresening {
    public var path: String
    public let baseURLKey: BaseURLKey
    public let HTTPMethodType: HTTPMethod
    public let parameters: Dictionary<String, AnyObject>?
    public let allHTTPHeaderFields: Dictionary<String, String>?
}

public extension NetworkRequest {
    public init(path: String, baseURLKey: BaseURLKey, HTTPMethodType: HTTPMethod = .GET, parameter: Dictionary<String, AnyObject>? = nil, allHTTPHeaderFields: Dictionary<String, String>? = nil) {
        self.path = path
        self.baseURLKey = baseURLKey
        self.HTTPMethodType = HTTPMethodType
        self.allHTTPHeaderFields = allHTTPHeaderFields
        self.parameters = parameter
    }
    
    public init(defaultRequest: NetworkRequestRepresening, parameter: Dictionary<String, AnyObject>? = nil, allHTTPHeaderFields: Dictionary<String, String>? = nil) {
        self.path = defaultRequest.path
        self.HTTPMethodType = defaultRequest.HTTPMethodType
        self.baseURLKey = defaultRequest.baseURLKey
        self.parameters = defaultRequest.parameters?.merged(parameter)
        self.allHTTPHeaderFields = defaultRequest.allHTTPHeaderFields?.merged(allHTTPHeaderFields)
    }
}

extension Dictionary {
    func merged(right: [Key: Value]?) -> Dictionary<Key, Value>? {
        var dictionary = self
        for (key, value) in right ?? [:] {
            dictionary.updateValue(value, forKey: key)
        }
        
        return dictionary
    }
}

