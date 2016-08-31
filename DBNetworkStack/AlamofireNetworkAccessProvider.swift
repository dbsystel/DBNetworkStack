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

public struct AlamofireNetworkAccessProvider: NetworkAccessProviding {
    public typealias RequestMethod = (method: Alamofire.Method, URLString: URLStringConvertible, parameters: [String : AnyObject]?, encoding: Alamofire.ParameterEncoding, headers: [String : String]?) -> NetworkRequestModeling
    private let requestFunction: RequestMethod
    
    /**
     Creates an `AlamofireNetworkService` instance with an underlying Alamofire implementation
     
     - parameter requestFunction: A function of type `RequestMethod` similar to `Alamofire.Request` which can fetch data.
     */
    public init(requestFunction: RequestMethod = Alamofire.request, endPoints: Dictionary<String, NSURL>) {
        self.requestFunction = requestFunction
    }
    
    public func load(request request: NetworkRequestRepresening, relativeToBaseURL baseURL: NSURL, callback: (NSData?, NSHTTPURLResponse?, NSError?) -> ()) -> CancelableRequest {
        guard let absoluteURL = NSURL(string: request.path, relativeToURL: baseURL) else {
            fatalError("Error createing absolute URL from path: \(request.path), with baseURL: \(baseURL)")
        }
        
        let request = requestFunction(method: request.HTTPMethod.alamofireMethod,
                                      URLString: absoluteURL,
                                      parameters: request.parameter,
                                      encoding: Alamofire.ParameterEncoding.URL,
                                      headers: request.allHTTPHeaderFields)
        request.response(queue: nil) { _, response, data, error in
            callback(data, response, error)
        }
        
        return request
    }
}

extension DBNetworkStack.HTTPMethod {
    var alamofireMethod: Alamofire.Method {
        return Alamofire.Method(rawValue: self.rawValue)!
    }
}


/**
 Abstracts Alamofire.Request to make it testable
*/
public protocol NetworkRequestModeling: CancelableRequest {
    func response(queue queue: dispatch_queue_t?, completionHandler: (NSURLRequest?, NSHTTPURLResponse?, NSData?, NSError?) -> Void) -> Self
}
extension Alamofire.Request: NetworkRequestModeling { }
