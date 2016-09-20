//
//  DBNetworkStackErrorTest.swift
//  DBNetworkStack
//
//  Created by Lukas Schmidt on 20.09.16.
//  Copyright © 2016 DBSystel. All rights reserved.
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
