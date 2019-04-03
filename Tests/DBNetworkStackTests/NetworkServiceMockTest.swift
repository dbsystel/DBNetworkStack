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
        networkServiceMock.returnSuccess(with: 1)
        
        //Then
        XCTAssertEqual(capturedResult, 1)
        XCTAssertEqual(executionCount, 1)
    }

    func testCorrectOrderOfReturnSuccessWithDataForMultipleRequests() {
        //Given
        var called1First = false
        var called2First = false

        //When
        networkServiceMock.request(resource, onCompletion: { _ in
            if !called2First {
                called1First = true
            }
        }, onError: { _ in })
        networkServiceMock.request(resource, onCompletion: { _ in
            if !called1First {
                called2First = true
            }
        }, onError: { _ in })
        networkServiceMock.returnSuccess(with: 0)
        networkServiceMock.returnSuccess(with: 0)

        //Then
        XCTAssertTrue(called1First)
        XCTAssertFalse(called2First)
    }

    func testRequestSuccessWithDataChaining() {
        //Given
        var executionCount1: Int = 0
        var executionCount2: Int = 0

        //When
        networkServiceMock.request(resource, onCompletion: { _ in
            executionCount1 += 1
            self.networkServiceMock.request(self.resource, onCompletion: { _ in
                executionCount2 += 1
            }, onError: { _ in })
        }, onError: { _ in })
        networkServiceMock.returnSuccess(with: 0)
        networkServiceMock.returnSuccess(with: 0)

        //Then
        XCTAssertEqual(executionCount1, 1)
        XCTAssertEqual(executionCount2, 1)
    }

    func testReturnSuccessWithDataForAllRequests() {
        //Given
        var executionCount1: Int = 0
        var executionCount2: Int = 0

        //When
        networkServiceMock.request(resource, onCompletion: { _ in
            executionCount1 += 1
        }, onError: { _ in })
        networkServiceMock.request(resource, onCompletion: { _ in
            executionCount2 += 1
        }, onError: { _ in })
        networkServiceMock.returnSuccess(with: 0)
        networkServiceMock.returnSuccess(with: 0)

        //Then
        XCTAssertEqual(executionCount1, 1)
        XCTAssertEqual(executionCount2, 1)
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
    
    func testCorrectOrderOfReturnSuccessWithSerializedDataForMultipleRequests() {
        //Given
        var capturedResult1: Int?
        var capturedResult2: Int?

        //When
        networkServiceMock.request(resource, onCompletion: { result in
            capturedResult1 = result
        }, onError: { _ in })
        networkServiceMock.request(resource, onCompletion: { result in
            capturedResult2 = result
        }, onError: { _ in })
        networkServiceMock.returnSuccess(with: 10)
        networkServiceMock.returnSuccess(with: 20)
        
        //Then
        XCTAssertEqual(capturedResult1, 10)
        XCTAssertEqual(capturedResult2, 20)
    }
    
    func testRequestSuccessWithSerializedDataChaining() {
        //Given
        var executionCount1: Int = 0
        var executionCount2: Int = 0
        
        //When
        networkServiceMock.request(resource, onCompletion: { _ in
            executionCount1 += 1
            self.networkServiceMock.request(self.resource, onCompletion: { _ in
                executionCount2 += 1
            }, onError: { _ in })
        }, onError: { _ in })
        networkServiceMock.returnSuccess(with: 10)
        networkServiceMock.returnSuccess(with: 20)
        
        //Then
        XCTAssertEqual(executionCount1, 1)
        XCTAssertEqual(executionCount2, 1)
    }
    
    func testReturnSuccessWithSerializedDataForAllRequests() {
        //Given
        var executionCount1: Int = 0
        var executionCount2: Int = 0
        
        //When
        networkServiceMock.request(resource, onCompletion: { _ in
            executionCount1 += 1
        }, onError: { _ in })
        networkServiceMock.request(resource, onCompletion: { _ in
            executionCount2 += 1
        }, onError: { _ in })
        networkServiceMock.returnSuccess(with: 10)
        networkServiceMock.returnSuccess(with: 10)
        
        //Then
        XCTAssertEqual(executionCount1, 1)
        XCTAssertEqual(executionCount2, 1)
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
    
    func testCorrectOrderOfReturnErrorForMultipleRequests() {
        //Given
        var capturedError1: NetworkError?
        var capturedError2: NetworkError?

        //When
        networkServiceMock.request(resource, onCompletion: { _ in }, onError: { error in
            capturedError1 = error
        })
        networkServiceMock.request(resource, onCompletion: { _ in }, onError: { error in
            capturedError2 = error
        })
        networkServiceMock.returnError(with: .unknownError)
        networkServiceMock.returnError(with: .cancelled)

        //Then
        if case .unknownError? = capturedError1, case .cancelled? = capturedError2 {
            
        } else {
            XCTFail("Wrong order of error responses")
        }
    }
    
    func testRequestErrorChaining() {
        //Given
        var executionCount1: Int = 0
        var executionCount2: Int = 0
        
        //When
        networkServiceMock.request(resource, onCompletion: { _ in }, onError: { _ in
            executionCount1 += 1
            self.networkServiceMock.request(self.resource, onCompletion: { _ in }, onError: { _ in
                executionCount2 += 1
            })
        })

        networkServiceMock.returnError(with: .unknownError)
        networkServiceMock.returnError(with: .unknownError)
        
        //Then
        XCTAssertEqual(executionCount1, 1)
        XCTAssertEqual(executionCount2, 1)
    }

    func testReturnErrorsForAllRequests() {
        //Given
        var executionCount1: Int = 0
        var executionCount2: Int = 0

        //When
        networkServiceMock.request(resource, onCompletion: { _ in }, onError: { _ in
            executionCount1 += 1
        })
        networkServiceMock.request(resource, onCompletion: { _ in }, onError: { _ in
            executionCount2 += 1
        })
        networkServiceMock.returnError(with: .unknownError)
        networkServiceMock.returnError(with: .unknownError)

        //Then
        XCTAssertEqual(executionCount1, 1)
        XCTAssertEqual(executionCount2, 1)
    }

}
