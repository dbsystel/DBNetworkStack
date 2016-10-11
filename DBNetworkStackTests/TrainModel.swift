//
//  TrainModel.swift
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
import DBNetworkStack

struct Train {
    let name: String
}

extension Train: JSONMappable {
    init(object: Dictionary<String, AnyObject>) throws {
        if let name = object["name"] as? String {
            self.name = name
        } else {
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
    }
}

extension Train {
    static var validJSONData: NSData {
        return "{ \"name\": \"ICE\"}".dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    static var invalidJSONData: NSData {
        return "{ name: \"ICE\"}".dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    static var JSONDataWithInvalidKey: NSData {
        return "{ \"namee\": \"ICE\"}".dataUsingEncoding(NSUTF8StringEncoding)!
    }
    
    static var validJSONArrayData: NSData {
        return "[{ \"name\": \"ICE\"}, { \"name\": \"IC\"}, { \"name\": \"TGV\"}]".dataUsingEncoding(NSUTF8StringEncoding)!
    }
}
