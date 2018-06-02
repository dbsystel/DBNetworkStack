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
        let numberOfRetries = 2
        var executedRetrys = 0
        
        let retryService = RetryNetworkService(networkService: networkServiceMock, numberOfRetries: numberOfRetries,
                                               idleTimeInterval: 0, shouldRetry: { _ in return true }, dispatchRetry: { _, block in
                                                executedRetrys += 1
                                                block()
        })
        
        //When
        weak var task = retryService.request(resource, onCompletion: { _ in
            XCTAssertEqual(executedRetrys, numberOfRetries)
        }, onError: { _ in
            XCTFail("Expects to not call error block")
        })
        (0..<errorCount).forEach { _ in
            networkServiceMock.returnError(with: .unknownError)
        }
        networkServiceMock.returnSuccess(with: 1)
        
        //Then
        XCTAssertNil(task)
    }
    
    func testRetryRequest_moreErrorsThenRetryAttemps() {
        //Given
        var executedRetrys = 0
        
        //When
        weak var task: NetworkTask?
        task = RetryNetworkService(networkService: networkServiceMock, numberOfRetries: 3,
                                   idleTimeInterval: 0, shouldRetry: { _ in return true },
                                   dispatchRetry: { _, block in
            executedRetrys += 1
            block()
        }).request(resource, onCompletion: { _ in
             XCTFail("Expects to not call completion block")
        }, onError: { _ in
            XCTAssertEqual(executedRetrys, 3)
        })
        (0..<4).forEach { _ in
            networkServiceMock.returnError(with: .unknownError)
        }
        
        //Then
        XCTAssertNil(task)
    }
    
    func testRetryRequest_shouldNotRetry() {
        //Given
        let shoudlRetry = false
        var capturedError: NetworkError?
        
        //When
        weak var task: NetworkTask?
        task = RetryNetworkService(networkService: networkServiceMock, numberOfRetries: 3,
                                   idleTimeInterval: 0, shouldRetry: { _ in return shoudlRetry },
                                   dispatchRetry: { _, block in
            XCTFail("Expects to not retry")
            block()
        }).request(resource, onCompletion: { _ in
            XCTFail("Expects to not call completion block")
        }, onError: { error in
           capturedError = error
        })
        networkServiceMock.returnError(with: .unknownError)
        
        //Then
        XCTAssertNil(task)
        XCTAssertNotNil(capturedError)
    }
}
