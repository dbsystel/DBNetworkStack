//
//  DBNetworkStackErrorTest.swift
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
//  Created by Lukas Schmidt on 20.09.16.
//

import XCTest
@testable import DBNetworkStack

class DBNetworkStackErrorTest: XCTestCase {
    
    func testInitFrom400() {
        //Given
        let statusCode = 400
        let response = NSHTTPURLResponse(URL: NSURL(), statusCode: statusCode, HTTPVersion: nil, headerFields: nil)
        
        //When
        guard let error = DBNetworkStackError(response: response) else {
            return XCTFail()
        }
        
        //Then
        switch error {
        case .ClientError(let response):
            XCTAssertEqual(response, response)
        default:
            XCTFail()
        }
    }
    
    func testInitFrom401() {
        //Given
        let statusCode = 401
        let response = NSHTTPURLResponse(URL: NSURL(), statusCode: statusCode, HTTPVersion: nil, headerFields: nil)
        
        //When
        guard let error = DBNetworkStackError(response: response) else {
            return XCTFail()
        }
        
        //Then
        switch error {
        case .Unauthorized(let response):
            XCTAssertEqual(response, response)
        default:
            XCTFail()
        }
    }
    
    func testInitFrom2xx() {
        //Given
        let statusCode = 200
        let response = NSHTTPURLResponse(URL: NSURL(), statusCode: statusCode, HTTPVersion: nil, headerFields: nil)
        
        //When
        let error = DBNetworkStackError(response: response)
        
        //Then
        XCTAssertNil(error)
    }
    
    func testInitFrom5xx() {
        //Given
        let statusCode = 511
        let response = NSHTTPURLResponse(URL: NSURL(), statusCode: statusCode, HTTPVersion: nil, headerFields: nil)
        
        //When
        guard let error = DBNetworkStackError(response: response) else {
            return XCTFail()
        }
        
        //Then
        switch error {
        case .ServerError(let response):
            XCTAssertEqual(response, response)
        default:
            XCTFail()
        }
    }
    
    func testInitFromInvalid() {
        //Given
        let statusCode = 900
        let response = NSHTTPURLResponse(URL: NSURL(), statusCode: statusCode, HTTPVersion: nil, headerFields: nil)
        
        //When
        let error = DBNetworkStackError(response: response)
        
        //Then
        XCTAssertNil(error)
    }
}
