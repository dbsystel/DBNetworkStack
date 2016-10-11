//
//  BaseURLProviding.swift
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
//  Created by Christian Himmelsbach on 29.09.16.
//
//
//  DBNetworkStack
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
