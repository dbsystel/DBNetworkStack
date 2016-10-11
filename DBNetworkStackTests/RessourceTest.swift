//
//  RessourceTest.swift
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

import XCTest
@testable import DBNetworkStack

class RessourceTest: XCTestCase {
    
    func testRessource() {
        //Given
        let validData = "ICE".dataUsingEncoding(NSUTF8StringEncoding)!
        let request = NetworkRequest(path: "/train", baseURLKey: "")
        let ressource = Ressource<String?>(request: request, parse: { String(data: $0, encoding: NSUTF8StringEncoding) })
        
        //When
        let name = try? ressource.parse(data: validData)
        
        //Then
        XCTAssertNotNil(name)
        XCTAssertEqual(name!!, "ICE")
    }
    
    func testRessourceWithInvalidData() {
        //Given
        let validData = NSData()
        let request = NetworkRequest(path: "/train", baseURLKey: "")
        let ressource = JSONRessource<Train>(request: request)
        
        //When
        do {
            let _ = try ressource.parse(data: validData)
            XCTFail()
        } catch { }
    }
}
