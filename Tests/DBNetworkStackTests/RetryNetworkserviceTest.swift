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
    var networkServiceMock: NetworkServiceMock!
    var resource: Resource<Int> {
        let url: URL! = URL(string: "bahn.de")
        let request = URLRequest(path: "/train", baseURL: url)
        return Resource(request: request, parse: { _ in return 1})
    }
    
    override func setUp() {
        super.setUp()
        networkServiceMock = NetworkServiceMock()
    }
    
    override func tearDown() {
        networkServiceMock = nil
        super.tearDown()
    }
    
    func testRetryRequest_shouldRetry() {
        //Given
        let errorCount = 2
        let numberOfRetries = 3
        var executedRetrys = 0
        
        //When
        weak var task: NetworkTaskRepresenting?
        task = RetryNetworkService(networkService: networkServiceMock, numberOfRetries: numberOfRetries,
                                   idleTimeInterval: 0, shouldRetry: { _ in return true}, dispatchRetry: { _, block in
            executedRetrys += 1
            block()
        }).request(resource: resource, onCompletion: { _, _ in
        }, onError: { _ in
            XCTFail()
        })
        networkServiceMock.returnError(with: .unknownError, count: errorCount)
        
        //Then
        XCTAssertEqual(executedRetrys, numberOfRetries)
        XCTAssertNil(task)
    }
    
    func testRetryRequest_moreErrorsThenRetryAttemps() {
        //Given
        var executedRetrys = 0
        
        //When
        weak var task: NetworkTaskRepresenting?
        task = RetryNetworkService(networkService: networkServiceMock, numberOfRetries: 3,
                                   idleTimeInterval: 0, shouldRetry: { _ in return true},
                                   dispatchRetry: { _, block in
            executedRetrys += 1
            block()
        }).request(resource, onCompletion: { _ in
            XCTFail()
        }, onError: { _ in
        })
        networkServiceMock.returnError(with: .unknownError, count: 3)
        
        //Then
        XCTAssertEqual(executedRetrys, 3)
        XCTAssertNil(task)
    }
    
    func testRetryRequest_shouldNotRetry() {
        //Given
        let shoudlRetry = false
        var capturedError: DBNetworkStackError?
        
        //When
        weak var task: NetworkTaskRepresenting?
        task = RetryNetworkService(networkService: networkServiceMock, numberOfRetries: 3,
                                   idleTimeInterval: 0, shouldRetry: { _ in return shoudlRetry },
                                   dispatchRetry: { _, block in
            XCTFail()
            block()
        }).request(resource, onCompletion: { _ in
            XCTFail()
        }, onError: { error in
           capturedError = error
        })
        networkServiceMock.returnError(with: .unknownError, count: 3)
        
        //Then
        XCTAssertNil(task)
        XCTAssertNotNil(capturedError)
    }
}
