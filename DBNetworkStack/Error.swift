//
//  Error.swift
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


public let NetworkErrorDomain = "Network.Error"

public enum NetworkErrorCode: Int {
    case UnknownError = 999
    case Unauthorized
    case SerializationError
    case HTTPError
    case BackendError
    case InvalidResponse
    case BadRequest
    case MissingBaseURL
}

extension NSError {
    
    public convenience init(code: NetworkErrorCode, userInfo dict: [NSObject : AnyObject]? = nil) {
        self.init(domain: NetworkErrorDomain, code: code.rawValue, userInfo: dict)
    }
    
    public static func errorWithUnderlyingError(error: NSError?, code: NetworkErrorCode) -> NSError {
        return NSError(code: code, userInfo: error != nil ? [NSUnderlyingErrorKey: error!] : nil)
    }
    
    static func backendError(statusCode: Int, data: NSData?) -> NSError? {
        switch statusCode {
        case 200..<300: return nil
        case 401:
            return NSError(code: .Unauthorized, userInfo: backendErrorUserInfo(statusCode, data: data))
        default:
            return NSError(code: .BackendError, userInfo: backendErrorUserInfo(statusCode, data: data))
        }
    }
    
    static func backendErrorUserInfo(statusCode: Int, data: NSData?) -> [NSObject: AnyObject]? {
        var userInfo: [NSObject: AnyObject] = ["statusCode": statusCode]
        if let data = data {
            do {
                userInfo["response"] = try NSJSONSerialization.JSONObjectWithData(data, options: [.AllowFragments])
            }
            catch {
                userInfo["response"] = NSString(data: data, encoding: NSUTF8StringEncoding)
            }
        }
        return userInfo
    }
}