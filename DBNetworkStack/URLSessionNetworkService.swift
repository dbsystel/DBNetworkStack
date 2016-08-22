//
//  URLSessionNetworkService.swift
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
//  Created by Lukas Schmidt on 22.08.16.
//

import Foundation

extension NetworkRequestRepresening {
    var request: NSURLRequest {
        let request = NSMutableURLRequest(URL: absoluteURL)
        request.HTTPMethod = HTTPMethodType.rawValue
        
        return request
    }
}

public final class URLSessionNetworkService: NetworkServiceProviding {
    let urlSession: NSURLSession
    
    init(urlSession: NSURLSession) {
        self.urlSession = urlSession
    }
    
    public func fetch<T : RessourceModeling>(ressource: T, onComplition: (T.Model) -> (), onError: (NSError) -> ()) -> CancelableRequest {
        let task = urlSession.dataTaskWithRequest(ressource.request.request, completionHandler: { data, response, error in
            
        })
        task.resume()
        
        return task
    }
}

extension NSURLSessionDataTask: CancelableRequest {}