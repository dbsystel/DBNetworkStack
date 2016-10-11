//
//  NetworkService.swift
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
