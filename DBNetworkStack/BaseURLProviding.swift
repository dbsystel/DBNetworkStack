//
//  BaseURLProviding.swift
//  DBNetworkStack
//
//  Created by Christian Himmelsbach on 29.09.16.
//  Copyright © 2016 DBSystel. All rights reserved.
//

import Foundation

internal protocol BaseURLProviding {
    
    var endPoints: [String:NSURL] {get}
    /**
     Provides an baseURL for a given ressource.
     
     To be more flexible, a request does only contain a path and not a full URL.
     Mapping has to be done in the service to get an registerd baseURL for the request.
     
     - parameter ressource: The ressource you want to get a baseURL for.
     
     - return matching baseURL to the given ressource
     */
    func baseURL<T: RessourceModeling>(with ressource: T) -> NSURL
}

extension BaseURLProviding {

    func baseURL<T: RessourceModeling>(with ressource: T) -> NSURL {
        
        guard let baseURL = endPoints[ressource.request.baseURLKey.name] else {
            fatalError("Missing baseurl for key: \(ressource.request.baseURLKey.name)")
        }
        
        return baseURL
    }
}