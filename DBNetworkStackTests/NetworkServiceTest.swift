//
//  NetworkServiceTest.swift
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
//  Created by Lukas Schmidt on 26.07.16.
//

import XCTest
@testable import DBNetworkStack

enum TestEndPoints: BaseURLKey {
    case EndPoint
    
    var name: String {
        return "endPointTestKey"
    }
}

class NetworkServiceTest: XCTestCase {
    var networkService: NetworkServiceProviding!
    
    var networkAccess = NetworkAccessMock()
    let trainName: NSString = "ICE"
    
    let baseURL =  NSURL(string: "//bahn.de")!
    
    override func setUp() {
        networkService = NetworkService(networkAccess: networkAccess, endPoints: ["endPointTestKey": baseURL])
    }
    
    func testValidRequest() {
        //Given
        let request = NetworkRequest(path: "/train", baseURLKey: TestEndPoints.EndPoint)
        let ressource = JSONRessource<Train>(request: request)
        networkAccess.changeMock(data: Train.validJSONData, response: nil, error: nil)
        
        //When
        let expection = expectationWithDescription("loadValidRequest")
        networkService.request(ressource, onCompletion: { train in
            //Then
            XCTAssertEqual(train.name, self.trainName)
            XCTAssertEqual(self.networkAccess.request?.URL?.absoluteString, "//bahn.de/train")
            
            expection.fulfill()
            }, onError: { err in
                XCTFail()
        })
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }

    func testNoData() {
        //Given
        let request = NetworkRequest(path:"/train", baseURLKey: TestEndPoints.EndPoint)
        let ressource = JSONRessource<Train>(request: request)
        networkAccess.changeMock(data: nil, response: nil, error: nil)
        
        //When
        let expection = expectationWithDescription("testNoData")
        networkService.request(ressource, onCompletion: { fetchedTrain in
            XCTFail()
            }, onError: { error in
                switch error {
                case .SerializationError(let description, let data):
                    XCTAssertEqual("No data to serialize revied from the server", description)
                    XCTAssertNil(data)
                    expection.fulfill()
                default:
                    XCTFail()
                }
        })
        
         waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testInvalidData() {
        //Given
        let request = NetworkRequest(path:"/train", baseURLKey: TestEndPoints.EndPoint)
        let ressource = JSONRessource<Train>(request: request)
        networkAccess.changeMock(data: Train.invalidJSONData, response: nil, error: nil)
        
        //When
        let expection = expectationWithDescription("testInvalidData")
        networkService.request(ressource, onCompletion: { fetchedTrain in
            XCTFail()
            }, onError: { error in
                //Then
                switch error {
                case .SerializationError(_, _):
                    expection.fulfill()
                default:
                    XCTFail()
                }
        })
        
         waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testInvalidJSONKeyData() {
        //Given
        let request = NetworkRequest(path:"/train", baseURLKey: TestEndPoints.EndPoint)
        let ressource = JSONRessource<Train>(request: request)
        networkAccess.changeMock(data: Train.JSONDataWithInvalidKey, response: nil, error: nil)
        
        //When
        let expection = expectationWithDescription("testInvalidJSONKeyData")
        networkService.request(ressource, onCompletion: { fetchedTrain in
            XCTFail()
            }, onError: { error in
                switch error {
                case .SerializationError(_, _):
                    expection.fulfill()
                default:
                    XCTFail()
                }
        })
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testOnError() {
        //Given
        let error = NSError(domain: "", code: 0, userInfo: nil)
        let request = NetworkRequest(path:"/train", baseURLKey: TestEndPoints.EndPoint)
        let ressource = JSONRessource<Train>(request: request)
        networkAccess.changeMock(data: nil, response: nil, error: error)
        
        //When
        let expection = expectationWithDescription("testOnError")
        networkService.request(ressource, onCompletion: { fetchedTrain in
            }, onError: { resultError in
                //Then
                switch resultError {
                case .RequestError(let err):
                    XCTAssertEqual(err, error)
                    expection.fulfill()
                default:
                    XCTFail()
                }
        })
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }
    
    func testOnStatusCodeError() {
        //Given
        let request = NetworkRequest(path:"/train", baseURLKey: TestEndPoints.EndPoint)
        let ressource = JSONRessource<Train>(request: request)
        let response = NSHTTPURLResponse(URL: NSURL(), statusCode: 401, HTTPVersion: nil, headerFields: nil)
        networkAccess.changeMock(data: nil, response: response, error: nil)
        
        //When
        let expection = expectationWithDescription("testOnError")
        networkService.request(ressource, onCompletion: { fetchedTrain in
            }, onError: { resultError in
                //Then
                switch resultError {
                case .Unauthorized(let res):
                    XCTAssertEqual(res, response)
                    expection.fulfill()
                default:
                    XCTFail()
                }
        })
        
        waitForExpectationsWithTimeout(1, handler: nil)
    }
}
