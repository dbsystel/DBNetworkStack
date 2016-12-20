//
//  DBNetworkStackErrorTest.swift
//
//  Copyright (C) 2016 DB Systel GmbH.
//	DB Systel GmbH; Jürgen-Ponto-Platz 1; D-60329 Frankfurt am Main; Germany; http://www.dbsystel.de/
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
//  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//
//  Created by Lukas Schmidt on 20.09.16.
//

import XCTest
@testable import DBNetworkStack

class DBNetworkStackErrorTest: XCTestCase {
    let url: URL! = URL(string: "https://bahn.de")
    
    func urlResponseWith(statusCode: Int) -> HTTPURLResponse? {
        return HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)
    }
    
    func testInit_WithHTTPStatusCode400() {
        //Given
        let response = urlResponseWith(statusCode: 400)
        
        //When
        guard let error = DBNetworkStackError(response: response) else {
            return XCTFail()
        }
        
        //Then
        switch error {
        case .clientError(let response):
            XCTAssertEqual(response, response)
        default:
            XCTFail()
        }
    }
    
    func testInit_WithHTTPStatusCode401() {
        //Given
        let response = urlResponseWith(statusCode: 401)
        
        //When
        guard let error = DBNetworkStackError(response: response) else {
            return XCTFail()
        }
        
        //Then
        switch error {
        case .unauthorized(let response):
            XCTAssertEqual(response, response)
        default:
            XCTFail()
        }
    }
    
    func testInit_WithHTTPStatusCode200() {
        //Given
        let response = urlResponseWith(statusCode: 200)
        
        //When
        let error = DBNetworkStackError(response: response)
        
        //Then
        XCTAssertNil(error)
    }
    
    func testInit_WithHTTPStatusCode511() {
        //Given
        let response = urlResponseWith(statusCode: 511)
        //When
        guard let error = DBNetworkStackError(response: response) else {
            return XCTFail()
        }
        
        //Then
        switch error {
        case .serverError(let response):
            XCTAssertEqual(response, response)
        default:
            XCTFail()
        }
    }
    
    func testInit_WithInvalidHTTPStatusCode900() {
        //Given
        let response = urlResponseWith(statusCode: 900)
        
        //When
        let error = DBNetworkStackError(response: response)
        
        //Then
        XCTAssertNil(error)
    }
}
