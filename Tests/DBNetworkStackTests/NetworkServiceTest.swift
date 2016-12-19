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
            ("testValidRequest", testValidRequest),
            ("testNoData", testNoData),
            ("testInvalidData", testInvalidData),
            ("testInvalidJSONKeyData", testInvalidJSONKeyData),
            ("testOnError", testOnError),
            ("testOnStatusCodeError", testOnStatusCodeError),
        ]
    }()
    
    var networkService: NetworkServiceProviding!
    
    var networkAccess = NetworkAccessMock()
    let trainName: String = "ICE"
    
    let baseURL: URL! = URL(string: "//bahn.de")
    
    override func setUp() {
        networkService = NetworkService(networkAccess: networkAccess, endPoints: ["endPointTestKey": baseURL])
    }
    
    func testValidRequest() {
        //Given
        let request = NetworkRequest(path: "/train", baseURLKey: TestEndPoints.endPoint)
        let resource = JSONResource<Train>(request: request)
        networkAccess.changeMock(data: Train.validJSONData, response: nil, error: nil)
        
        //When
        let expection = expectation(description: "loadValidRequest")
        _ = networkService.request(resource, onCompletion: { train in
            //Then
            XCTAssertEqual(train.name, self.trainName)
            XCTAssertEqual(self.networkAccess.request?.url?.absoluteString, "//bahn.de/train")
            
            expection.fulfill()
            }, onError: { err in
                XCTFail()
        })
        
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testNoData() {
        //Given
        let request = NetworkRequest(path:"/train", baseURLKey: TestEndPoints.endPoint)
        let resource = JSONResource<Train>(request: request)
        networkAccess.changeMock(data: nil, response: nil, error: nil)
        
        //When
        let expection = expectation(description: "testNoData")
        _ = networkService.request(resource, onCompletion: { _ in
            XCTFail()
        }, onError: { (error: DBNetworkStackError) in
                switch error {
                case .serializationError(let description, let data):
                    XCTAssertEqual("No data to serialize revied from the server", description)
                    XCTAssertNil(data)
                    expection.fulfill()
                default:
                    XCTFail()
                }
        })
        
         waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testInvalidData() {
        //Given
        let request = NetworkRequest(path:"/train", baseURLKey: TestEndPoints.endPoint)
        let resource = JSONResource<Train>(request: request)
        networkAccess.changeMock(data: Train.invalidJSONData, response: nil, error: nil)
        
        //When
        let expection = expectation(description: "testInvalidData")
        _ = networkService.request(resource, onCompletion: { _ in
            XCTFail()
            }, onError: { (error: DBNetworkStackError) in
                //Then
                switch error {
                case .serializationError(_, _):
                    expection.fulfill()
                default:
                    XCTFail()
                }
        })
        
         waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testInvalidJSONKeyData() {
        //Given
        let request = NetworkRequest(path:"/train", baseURLKey: TestEndPoints.endPoint)
        let resource = JSONResource<Train>(request: request)
        networkAccess.changeMock(data: Train.JSONDataWithInvalidKey, response: nil, error: nil)
        
        //When
        let expection = expectation(description: "testInvalidJSONKeyData")
        _ = networkService.request(resource, onCompletion: { _ in
            XCTFail()
            }, onError: { (error: DBNetworkStackError) in
                switch error {
                case .serializationError(_, _):
                    expection.fulfill()
                default:
                    XCTFail()
                }
        })
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testOnError() {
        //Given
        let error = NSError(domain: "", code: 0, userInfo: nil)
        let request = NetworkRequest(path:"/train", baseURLKey: TestEndPoints.endPoint)
        let resource = JSONResource<Train>(request: request)
        networkAccess.changeMock(data: nil, response: nil, error: error)
        
        //When
        let expection = expectation(description: "testOnError")
        networkService.request(resource, onCompletion: { (result: Train) in
            XCTFail()
            }, onError: { (resultError: DBNetworkStackError) in
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
    
    func testOnStatusCodeError() {
        //Given
        let request = NetworkRequest(path:"/train", baseURLKey: TestEndPoints.endPoint)
        let resource = JSONResource<Train>(request: request)
        let url: URL! = URL(string: "https://bahn.de")
        let response = HTTPURLResponse(url: url, statusCode: 401, httpVersion: nil, headerFields: nil)
        networkAccess.changeMock(data: nil, response: response, error: nil)
        
        //When
        let expection = expectation(description: "testOnError")
        _ = networkService.request(resource, onCompletion: { _ in
            XCTFail()
            }, onError: { (error: DBNetworkStackError) in
                //Then
                switch error {
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
