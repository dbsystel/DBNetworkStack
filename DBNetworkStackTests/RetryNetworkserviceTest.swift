//
//  RetryNetworkserviceTest.swift
//  BFACore
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
//  Created by Lukas Schmidt on 30.11.16.
//

import XCTest
@testable import DBNetworkStack


class RetryNetworkserviceTest: XCTestCase {
    let networkServiceMock = NetworkServiceMock()
    let mockError: DBNetworkStackError = {
        let url: URL! = URL(string: "bahn.de")
        let response = HTTPURLResponse(url: url, statusCode: 503, httpVersion: nil, headerFields: nil)
        return .serverError(response: response)
    }()
    
    func testRetryRequest() {
        //Given
        let request = NetworkRequest(path: "", baseURLKey: "")
        let ressource = Resource(request: request, parse: {d in return 1})
        
        var retryCount = 0
        
        //When
        weak var task: NetworkTaskRepresenting?
        task = RetryNetworkService(networkService: networkServiceMock, numberOfRetries: 3,
                                   idleTimeInterval: 0, shouldRetry: { err in return true}, dispatchRetry: {time, block in
            retryCount += 1
            block()
        }).request(ressource, onCompletion: { int in
        }, onError: { err in
            XCTFail()
        })
        networkServiceMock.returnError(error: mockError, count: 2)
        
        //Then
        XCTAssertEqual(retryCount, 3)
        XCTAssertNil(task)
    }
    
    func testRetryRequest_tooManyErrors() {
        //Given
        let request = NetworkRequest(path: "", baseURLKey: "")
        let ressource = Resource(request: request, parse: {d in return 1})
        var retryCount = 0
        
        //When
        weak var task: NetworkTaskRepresenting?
        task = RetryNetworkService(networkService: networkServiceMock, numberOfRetries: 3, idleTimeInterval: 0, shouldRetry: { err in return true}, dispatchRetry: {time, block in
            retryCount += 1
            block()
        }).request(ressource, onCompletion: { int in
            XCTFail()
        }, onError: { err in
        })
        networkServiceMock.returnError(error: mockError, count: 3)
        
        //Then
        XCTAssertEqual(retryCount, 3)
        XCTAssertNil(task)
    }
    
    func testRetryRequest_shouldNotRetry() {
        //Given
        let request = NetworkRequest(path: "", baseURLKey: "")
        let ressource = Resource(request: request, parse: {d in return 1})
        let shoudlRetry = false
        var error: DBNetworkStackError?
        
        //When
        weak var task: NetworkTaskRepresenting?
        task = RetryNetworkService(networkService: networkServiceMock, numberOfRetries: 3, idleTimeInterval: 0, shouldRetry: { err in return shoudlRetry }, dispatchRetry: { time, block in
            XCTFail()
            block()
        }).request(ressource, onCompletion: { int in
            XCTFail()
        }, onError: { err in
           error = err
        })
        networkServiceMock.returnError(error: mockError, count: 3)
        
        //Then
        XCTAssertNil(task)
        XCTAssertNotNil(error)
    }
}
