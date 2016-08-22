//
//  NetworkService.swift
//  BFACore
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
import Alamofire

extension HTTPMethod {
    var alamofireMethod: Alamofire.Method {
        switch self {
        case .GET:
            return .GET
        case .POST:
            return .POST
        case .PUT:
            return .PUT
        case .DELETE:
            return .DELETE
        }
    }
}


public final class NetworkService: NetworkServiceProviding {
    public typealias RequestMethod = (method: Alamofire.Method, URLString: URLStringConvertible, parameters: [String : AnyObject]? , encoding: Alamofire.ParameterEncoding, headers: [String : String]?) -> NetworkRequestModeling
    let requestFunction: RequestMethod
    /**
     Creates an `NetworkService` instance by injecting a function to fetch data from
     
     - parameter requestFunction: A function of type `RequestMethod` which can fetch data
    */
    public init(requestFunction: RequestMethod) {
        self.requestFunction = requestFunction
    }
    
    public func fetch<T : RessourceModeling>(ressource: T, onComplition: (T.Model) -> (), onError: (NSError) -> ()) -> NetworkRequestModeling {
        let request = requestFunction(method: ressource.request.HTTPMethodType.alamofireMethod, URLString: ressource.request.url, parameters: ressource.request.parameters, encoding: Alamofire.ParameterEncoding.URL, headers: ressource.request.allHTTPHeaderFields)
        request.response(queue: dispatch_get_main_queue()) { _, response, data, error in
            if let error = error {
                onError(error)
            }
            guard let data = data else {
                //TODO: Proper Error handling
                return onError(NSError(domain: "No data recieved", code: 0, userInfo: nil))
            }
            do {
                let parsed = try ressource.parse(data: data)
                onComplition(parsed)
            }catch {
                //TODO: Proper Error handling
                return onError(NSError(domain: "", code: 0, userInfo: nil))
            }
        }
        
        return request
    }
}


/**
 Abstracts Alamofire.Request to make it testable
*/
public protocol NetworkRequestModeling {
    func response(queue queue: dispatch_queue_t?, completionHandler: (NSURLRequest?, NSHTTPURLResponse?, NSData?, NSError?) -> Void) -> Self
    
    func cancel()
}
extension Alamofire.Request: NetworkRequestModeling { }
