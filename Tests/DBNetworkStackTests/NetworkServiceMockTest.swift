//
//  NetworkServiceMockTest.swift
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
//  Created by Lukas Schmidt on 07.02.17.
//

import XCTest
import DBNetworkStack

class NetworkServiceMockTest: XCTestCase {
    
    var networkServiceMock: NetworkServiceMock!
    
    let resource = Resource<Int>(request: URLRequest(path: "/trains", baseURL: .defaultMock), parse: { _ in return 1 })
    
    override func setUp() {
        networkServiceMock = NetworkServiceMock()
    }
    
    func testRequestCount() {
        //When
        networkServiceMock.request(resource, onCompletion: { _ in }, onError: { _ in })
        networkServiceMock.request(resource, onCompletion: { _ in }, onError: { _ in })
        
        //Then
        XCTAssertEqual(networkServiceMock.requestCount, 2)
    }
    
    func testReturnSuccessWithData() {
        //Given
        var capturedResult: Int?
        var executionCount: Int = 0
        
        //When
        networkServiceMock.request(resource, onCompletion: { result in
            capturedResult = result
            executionCount += 1
        }, onError: { _ in })
        networkServiceMock.returnSuccess()
        
        //Then
        XCTAssertEqual(capturedResult, 1)
        XCTAssertEqual(executionCount, 1)
    }
    
    func testReturnSuccessWithSerializedData() {
        //Given
        var capturedResult: Int?
        var executionCount: Int = 0
        
        //When
        networkServiceMock.request(resource, onCompletion: { result in
            capturedResult = result
            executionCount += 1
        }, onError: { _ in })
        networkServiceMock.returnSuccess(with: 10)
        
        //Then
        XCTAssertEqual(capturedResult, 10)
        XCTAssertEqual(executionCount, 1)
    }
    
    func testReturnError() {
        //Given
        var capturedError: NetworkError?
        var executionCount: Int = 0
        
        //When
        networkServiceMock.request(resource, onCompletion: { _ in }, onError: { error in
            capturedError = error
            executionCount += 1
        })
        networkServiceMock.returnError(with: .unknownError)
        
        //Then
        if let error = capturedError, case .unknownError = error {
            
        } else {
            XCTFail("Wrong error type")
        }
        XCTAssertEqual(executionCount, 1)
    }
    
}
