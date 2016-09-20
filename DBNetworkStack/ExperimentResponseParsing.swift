//
//  ExperimentResponseParsing.swift
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
//  Created by Lukas Schmidt on 01.09.16.
//

import Foundation

protocol RootKeyProviding {
    static func rootKey() -> String
}

enum Result<Value: protocol<JSONMappable, RootKeyProviding>, ErrorType: protocol<JSONMappable, RootKeyProviding>>: JSONMappable {
    case sucess(Value)
    case error(ErrorType)
    
    init(object: Dictionary<String, AnyObject>) throws {
        if let expected = try Result.expected(from: object) {
            self = .sucess(expected)
        } else {
            if let errorValue = try Result.errors(from: object) {
                self = .error(errorValue)
                return
            }
            fatalError()
            
        }
    }
    
    private static func expected(from object: Dictionary<String, AnyObject>) throws -> Value? {
        guard let expectedValue = object[Value.rootKey()] as? Dictionary<String, AnyObject> else {
            return nil
        }
        
        return try Value(object: expectedValue)
    }
    
    private static func errors(from object: Dictionary<String, AnyObject>) throws -> ErrorType? {
        guard let expectedValue = object[ErrorType.rootKey()] as? Dictionary<String, AnyObject> else {
            return nil
        }
        
        return try ErrorType(object: expectedValue)
    }
}
