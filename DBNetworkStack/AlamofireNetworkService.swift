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

enum BaseURLs: String, BaseURLKey, URLStoring {
    case BFA
    case IRIS
    case RIS
    
    var name: String {
        return rawValue
    }
    
    var productionURL: NSURL {
        switch self {
        case BFA:
            return NSURL()
        case IRIS:
            return NSURL()
        case RIS:
            return NSURL()
        }
    }
    
    var testURL: NSURL {
        switch self {
        case BFA:
            return NSURL()
        case IRIS:
            return NSURL()
        case RIS:
            return NSURL()
        }
    }
    
    var developmentURL: NSURL {
        switch self {
        case BFA:
            return NSURL()
        case IRIS:
            return NSURL()
        case RIS:
            return NSURL()
        }
    }
}

/**
 `AlamofireNetworkService` handles network request for ressources by using `Alamofire` as the network layer.
 */
public final class AlamofireNetworkService: NetworkServiceProviding {
    public typealias RequestMethod = (method: Alamofire.Method, URLString: URLStringConvertible, parameters: [String : AnyObject]? , encoding: Alamofire.ParameterEncoding, headers: [String : String]?) -> NetworkRequestModeling
    let requestFunction: RequestMethod
    let endPoints: Dictionary<String, NSURL>
    
    /**
     Creates an `NetworkService` instance by injecting a function to fetch data from
     
     - parameter requestFunction: A function of type `RequestMethod` which can fetch data
    */
    public init(requestFunction: RequestMethod, endPoints: Dictionary<String, NSURL>) {
        self.requestFunction = requestFunction
        self.endPoints = endPoints
    }
    
    public func fetch<T : RessourceModeling>(ressource: T, onCompletion: (T.Model) -> (), onError: (NSError) -> ()) -> CancelableRequest {
        guard let absoluteURL = absoluteURL(fromRessource: ressource) else {
            fatalError("Missing baseurl for key: \(ressource.request.baseURLKey.name)")
        }
        
        let request = requestFunction(method: ressource.request.HTTPMethodType.alamofireMethod,
                                      URLString: absoluteURL,
                                      parameters: ressource.request.parameters,
                                      encoding: Alamofire.ParameterEncoding.URL,
                                      headers: ressource.request.allHTTPHeaderFields)
        request.response(queue: dispatch_get_main_queue()) { _, response, data, error in
            do {
                let parsed = try self.process(response: response, ressource: ressource, data: data, error: error)
                onCompletion(parsed)
            } catch let error as NSError {
                return onError(error)
            }
        }
        
        return request
    }
    
    private func process<T : RessourceModeling>(response response: NSHTTPURLResponse?, ressource: T, data: NSData?, error: NSError?) throws -> T.Model {
        if let error = error {
            throw NSError.errorWithUnderlyingError(error, code: .HTTPError)
        }
        guard let data = data else {
            throw NSError(code: .BackendError)
        }
        do {
            return try ressource.parse(data: data)
        } catch {
            throw NSError(code: .SerializationError)
        }
    }
    
    public func absoluteURL<T : RessourceModeling>(fromRessource ressource: T) -> NSURL? {
        guard let baseURL = endPoints[ressource.request.baseURLKey.name] else {
            return nil
        }
        
        return NSURL(string: ressource.request.path, relativeToURL: baseURL)
    }
}


/**
 Abstracts Alamofire.Request to make it testable
*/
public protocol NetworkRequestModeling: CancelableRequest {
    func response(queue queue: dispatch_queue_t?, completionHandler: (NSURLRequest?, NSHTTPURLResponse?, NSData?, NSError?) -> Void) -> Self
}
extension Alamofire.Request: NetworkRequestModeling { }
