//
//  Copyright (C) 2017 DB Systel GmbH.
//  DB Systel GmbH; Jürgen-Ponto-Platz 1; D-60329 Frankfurt am Main; Germany; http://www.dbsystel.de/
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

import Foundation
import XCTest
@testable import DBNetworkStack

class NetworkErrorTest: XCTestCase {

    
    private let testData: Data! = "test_string".data(using: .utf8)
    
    func testInit_WithHTTPStatusCode400() throws {
        //Given
        let expectedResponse = try XCTUnwrap(HTTPURLResponse(url: .defaultMock, statusCode: 400, httpVersion: nil, headerFields: nil))

        //When
         let error = NetworkError(response: expectedResponse, data: testData)
        
        //Then
        switch error {
        case .clientError(let response, let data)?:
            XCTAssertEqual(response, expectedResponse)
            XCTAssertEqual(data, testData)
        default:
            XCTFail("Expects clientError")
        }
    }
    
    func testInit_WithHTTPStatusCode401() throws {
        //Given
        let expectedResponse = try XCTUnwrap(HTTPURLResponse(url: .defaultMock, statusCode: 401, httpVersion: nil, headerFields: nil))

        //When
        let error = NetworkError(response: expectedResponse, data: testData)
        
        //Then
        switch error {
        case .unauthorized(let response, let data)?:
            XCTAssertEqual(response, expectedResponse)
            XCTAssertEqual(data, testData)
        default:
            XCTFail("Expects unauthorized")
        }
    }
    
    func testInit_WithHTTPStatusCode200() throws {
        //Given
        let response = try XCTUnwrap(HTTPURLResponse(url: .defaultMock, statusCode: 200, httpVersion: nil, headerFields: nil))

        //When
        let error = NetworkError(response: response, data: testData)

        //Then
        XCTAssertNil(error)
    }
    
    func testInit_WithHTTPStatusCode511() throws {
        //Given
        let expectedResponse = try XCTUnwrap(HTTPURLResponse(url: .defaultMock, statusCode: 511, httpVersion: nil, headerFields: nil))

        //When
        let error = NetworkError(response: expectedResponse, data: testData)
        
        //Then
        switch error {
        case .serverError(let response, let data)?:
            XCTAssertEqual(response, expectedResponse)
            XCTAssertEqual(data, testData)
        default:
            XCTFail("Expects serverError")
        }
    }
    
    func testInit_WithInvalidHTTPStatusCode900() throws {
        //Given
        let response = try XCTUnwrap(HTTPURLResponse(url: .defaultMock, statusCode: 900, httpVersion: nil, headerFields: nil))

        //When
        let error = NetworkError(response: response, data: testData)
        
        //Then
        XCTAssertNil(error)
    }
    
    func testUnknownError_debug_description() {
        //Given
        let error: NetworkError = .unknownError
        
        //When
        let debugDescription = error.debugDescription
        
        //Then
        XCTAssertEqual(debugDescription, "Unknown error")
    }
    
    func testUnknownError_cancelled_description() {
        //Given
        let error: NetworkError = .cancelled
        
        //When
        let debugDescription = error.debugDescription
        
        //Then
        XCTAssertEqual(debugDescription, "Request cancelled")
    }

    func testUnknownError_unauthorized_description() {
        //Given
        let response: HTTPURLResponse! = HTTPURLResponse(url: .defaultMock, statusCode: 0, httpVersion: "1.1", headerFields: nil)
        let data = "dataString".data(using: .utf8)
        let error: NetworkError = .unauthorized(response: response, data: data)
        
        //When
        let debugDescription = error.debugDescription
        
        //Then
        XCTAssert(debugDescription.hasPrefix("Authorization error: <NSHTTPURLResponse: "))
        XCTAssert(debugDescription.hasSuffix("response: dataString"))
    }
    
    func testUnknownError_clientError_description() {
        //Given
        let response: HTTPURLResponse! = HTTPURLResponse(url: .defaultMock, statusCode: 0, httpVersion: "1.1", headerFields: nil)
        let data = "dataString".data(using: .utf8)
        let error: NetworkError = .clientError(response: response, data: data)
        
        //When
        let debugDescription = error.debugDescription
        
        //Then
        XCTAssert(debugDescription.hasPrefix("Client error: <NSHTTPURLResponse: "))
        XCTAssert(debugDescription.hasSuffix("response: dataString"))
    }
    
    func testUnknownError_serializationError_description() {
        //Given
        let nserror = NSError(domain: "TestError", code: 0, userInfo: nil)
        let data = "dataString".data(using: .utf8)
        let error: NetworkError = .serializationError(error: nserror, data: data)
        
        //When
        let debugDescription = error.debugDescription
        
        //Then
        XCTAssertEqual(debugDescription, "Serialization error: Error Domain=TestError Code=0 \"(null)\", response: dataString")
    }
    
    func testUnknownError_requestError_description() {
        //Given
        let underlayingError = NSError(domain: "domain", code: 0, userInfo: ["test": "test"])
        let error: NetworkError = .requestError(error: underlayingError)
        
        //When
        let debugDescription = error.debugDescription
        
        //Then
        XCTAssertEqual(debugDescription, "Request error: Error Domain=domain Code=0 \"(null)\" UserInfo={test=test}")
    }

}
