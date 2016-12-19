//
//  NetworkServiceTest.swift
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
//  Created by Lukas Schmidt on 26.07.16.
//

import Foundation
import XCTest
@testable import DBNetworkStack

enum TestEndPoints: BaseURLKey {
    case endPoint
    
    var name: String {
        return "endPointTestKey"
    }
}

class NetworkServiceTest: XCTestCase {
    
    public static var allTests = {
        return [
            ("testRequest_withValidResponse", testRequest_withValidResponse)
            //            ,
            //            ("testNoData", testNoData),
            //            ("testInvalidData", testInvalidData),
            //            ("testInvalidJSONKeyData", testInvalidJSONKeyData),
            //            ("testOnError", testOnError),
            //            ("testOnStatusCodeError", testOnStatusCodeError)
        ]
    }()
    
    var networkService: NetworkServiceProviding!
    
    var networkAccess = NetworkAccessMock()
    
    let trainName = "ICE"
    let baseURL: URL! = URL(string: "//bahn.de")
    
    var resource: JSONResource<Train> {
        let request = NetworkRequest(path:"train", baseURLKey: TestEndPoints.endPoint)
        return JSONResource<Train>(request: request)
    }
    
    override func setUp() {
        networkService = NetworkService(networkAccess: networkAccess, endPoints: ["endPointTestKey": baseURL])
    }
    
    func testRequest_withValidResponse() {
        //Given
        networkAccess.changeMock(data: Train.validJSONData, response: nil, error: nil)
        let expection = expectation(description: "loadValidRequest")
        
        //When
        networkService.request(resource, onCompletion: { train in
            XCTAssertEqual(train.name, self.trainName)
            expection.fulfill()
            }, onError: { err in
                XCTFail()
        })
        
        waitForExpectations(timeout: 1, handler: nil)
        
        //Then
        XCTAssertEqual(networkAccess.request?.url?.absoluteString, "//bahn.de/train")
    }

    func testRequest_withNoDataResponse() {
        //Given
        networkAccess.changeMock(data: nil, response: nil, error: nil)
        let expection = expectation(description: "testNoData")
        
        //When
        networkService.request(resource, onCompletion: { _ in
            XCTFail()
            }, onError: { error in
                switch error {
                case .serializationError(let description, let data):
                    XCTAssertEqual("No data to serialize revied from the server", description)
                    XCTAssertNil(data)
                    expection.fulfill()
                default:
                    XCTFail()
                }
        })
        
        //Then
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testInvalidData() {
        //Given
        networkAccess.changeMock(data: Train.invalidJSONData, response: nil, error: nil)
        
        //When
        let expection = expectation(description: "testInvalidData")
        networkService.request(resource, onCompletion: { fetchedTrain in
            XCTFail()
            }, onError: { error in
                if case .serializationError(_, _) = error {
                    expection.fulfill()
                } else {
                    XCTFail()
                }
        })
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testRequest_withFailingSerialization() {
        //Given
        networkAccess.changeMock(data: Train.JSONDataWithInvalidKey, response: nil, error: nil)
        let expection = expectation(description: "testRequest_withFailingSerialization")
        
        //When
        networkService.request(resource, onCompletion: { fetchedTrain in
            XCTFail()
            }, onError: { error in
                if case .serializationError(_, _) = error {
                    expection.fulfill()
                } else {
                    XCTFail()
                }
        })
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testRequest_withErrorResponse() {
        //Given
        let error = NSError(domain: "", code: 0, userInfo: nil)
        networkAccess.changeMock(data: nil, response: nil, error: error)
        let expection = expectation(description: "testOnError")
        
        //When
        networkService.request(resource, onCompletion: { fetchedTrain in
            }, onError: { resultError in
                //Then
                switch resultError {
                case .requestError(let err):
                    //XCTAssertEqual(err as NSError, error)
                    expection.fulfill()
                default:
                    XCTFail()
                }
        })
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testRequest_withStatusCode401Response() {
        //Given
        let url: URL! = URL(string: "https://bahn.de")
        let response = HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)
        networkAccess.changeMock(data: nil, response: response, error: nil)
        let expection = expectation(description: "testOnError")
        
        //When
        networkService.request(resource, onCompletion: { fetchedTrain in
            }, onError: { resultError in
                //Then
                switch resultError {
                case .unauthorized(let res):
                    XCTAssertEqual(res, response)
                    expection.fulfill()
                default:
                    XCTFail()
                }
        })
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
