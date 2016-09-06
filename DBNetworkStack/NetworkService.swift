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
 `NetworkService` handles network request for ressources by using `Alamofire` as the network layer.
 */
public final class NetworkService: NetworkServiceProviding {
    let networkAccess: NetworkAccessProviding
    let endPoints: Dictionary<String, NSURL>
    
    /**
     Creates an `NetworkService` instance by injecting a function to fetch data from
     
     - parameter requestFunction: A function of type `RequestMethod` which can fetch data
     */
    public init(networkAccess: NetworkAccessProviding, endPoints: Dictionary<String, NSURL>) {
        self.networkAccess = networkAccess
        self.endPoints = endPoints
    }
    
    public func fetch<T : RessourceModeling>(ressource: T, onCompletion: (T.Model) -> (), onError: (NSError) -> ()) -> NetworkTask {
        guard let baseURL = baseURL(fromRessource: ressource) else {
            fatalError("Missing baseurl for key: \(ressource.request.baseURLKey.name)")
        }
        return networkAccess.load(request: ressource.request, relativeToBaseURL: baseURL, callback: { data, response, error in
            do {
                let parsed = try self.process(response: response, ressource: ressource, data: data, error: error)
                dispatch_async(dispatch_get_main_queue()) {
                    onCompletion(parsed)
                }
            } catch let error as NSError {
                dispatch_async(dispatch_get_main_queue()) {
                    return onError(error)
                }
            }
        })
    }
    
    public func baseURL<T: RessourceModeling>(fromRessource ressource: T) -> NSURL? {
        return endPoints[ressource.request.baseURLKey.name]
    }
    
    //MARK: Private
    
    public func process<T : RessourceModeling>(response response: NSHTTPURLResponse?, ressource: T, data: NSData?, error: NSError?) throws -> T.Model {
        if let error = error {
            throw NSError.errorWithUnderlyingError(error, code: .HTTPError)
        }
        if let statusCode = response?.statusCode, responseError = NSError.backendError(statusCode, data: data) {
            throw responseError
        }
        guard let data = data else {
            throw NSError(code: .BackendError)
        }
        do {
            return try ressource.parse(data: data)
        } catch let error as CustomStringConvertible {
            throw NSError(code: .SerializationError, userInfo: ["key": String(error)])
        }
    }
    
    
}
