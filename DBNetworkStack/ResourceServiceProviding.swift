//
//  ResourceServiceProviding.swift
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
 `NetworkServiceProviding` provides access to remote ressources.
 */
public protocol NetworkServiceProviding {
    /**
     Fetches a ressource asynchrony from remote location
     
     - parameter ressource: The ressource you want to fetch.
     - parameter onComplition: Callback which gets called when fetching and tranforming into model succeeds.
     - parameter onError: Callback which gets called when fetching or tranforming fails.
     
     - return the request
     */
    func fetch<T: RessourceModeling>(ressource: T, onCompletion: (T.Model) -> (), onError: (NSError) -> ()) -> NetworkTask
    
    /**
    Provides an baseURL for a given ressource.
     
     To be more flexible, a request does only contain a path and not a full URL.
     Mapping has to be done in the method to get an registerd baseURL for the request.
     
     - parameter ressource: The ressource you want to get a baseURL for.

     - return matching baseURL to the given ressource
     */
    func baseURL<T: RessourceModeling>(with ressource: T) -> NSURL?
    
    /**
     Processes the results of an HTTPRequest and parses the result the matching Model type of the given ressource.
     
    Great error handling should be implemented here as well.
     
     - parameter response: response from the server. Could be nil
     - parameter ressource: The ressource matching the response.
     - parameter data: Returned data. Could be nil.
     - parameter error: the return error. Could be nil.
     
     - return the parsed model object.
     */
    func process<T : RessourceModeling>(response response: NSHTTPURLResponse?, ressource: T, data: NSData?, error: NSError?) throws -> T.Model
    
}