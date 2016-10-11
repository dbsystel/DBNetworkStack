//
//  DBNetworkStackTypes.swift
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
//  Created by Lukas Schmidt on 23.08.16.
//

import Foundation

public typealias DBNetworkTaskCreationCompletionBlock = (NetworkTask) -> ()
// TODO: Use typealiases for functions with generic types in Swift 3.x
//typealias NetworkRequestCompletionBlock<T: RessourceModelling> = (T.Model) -> ()
public typealias DBNetworkRequestErrorBlock = (DBNetworkStackError) -> ()

/**
 `DBNetworkStackError` provides a collection of error types which can occur during execution.
 */
public enum DBNetworkStackError: ErrorType {
    case UnknownError
    case Unauthorized(response: NSHTTPURLResponse)
    case ClientError(response: NSHTTPURLResponse?)
    case SerializationError(description: String, data: NSData?)
    case RequestError(error: NSError)
    case ServerError(response: NSHTTPURLResponse?)
    case MissingBaseURL
    
    init?(response: NSHTTPURLResponse?) {
        guard let response = response else {
            return nil
        }
        switch response.statusCode {
        case 200..<300: return nil
        case 401:
            self = .Unauthorized(response: response)
        case 400...451:
            self = .ClientError(response: response)
        case 500...511:
            self = .ServerError(response: response)
        default:
            return nil
        }
    }
    
}
