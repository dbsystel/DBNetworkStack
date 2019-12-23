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
import DBNetworkStack

class NetworkServiceTest: XCTestCase {
    
    var networkService: NetworkService!
    
    var networkAccess = NetworkAccessMock()
    
    let trainName = "ICE"
    
    var resource: Resource<Train> {
        let request = URLRequest(path: "train", baseURL: .defaultMock)
        return Resource(request: request, decoder: JSONDecoder())
    }
    
    override func setUp() {
        networkService = BasicNetworkService(networkAccess: networkAccess)
    }
    
    func testRequest_withValidResponse() {
        //Given
        networkAccess.changeMock(data: Train.validJSONData, response: .defaultMock, error: nil)
        let expection = expectation(description: "loadValidRequest")
        
        //When
        networkService.request(resource, onCompletionWithResponse: { train, response in
            XCTAssertEqual(train.name, self.trainName)
            XCTAssertEqual(response, .defaultMock)
            expection.fulfill()
            }, onError: { _ in
                XCTFail("Should not call error block")
        })
        
        waitForExpectations(timeout: 1, handler: nil)
        
        //Then
        XCTAssertEqual(networkAccess.request?.url?.absoluteString, "https://bahn.de/train")
    }

    func testRequest_withNoDataResponse() {
        //Given
        networkAccess.changeMock(data: nil, response: nil, error: nil)
        let expection = expectation(description: "testNoData")
        
        //When
        var capturedError: NetworkError?
        networkService.request(resource, onCompletion: { _ in
            XCTFail("Should not call success block")
            }, onError: { error in
                capturedError = error
                expection.fulfill()
        })
        
        //Then
        waitForExpectations(timeout: 1, handler: nil)
        
        switch capturedError {
        case .serverError(let response, let data)?:
            XCTAssertNil(response)
            XCTAssertNil(data)
        default:
            XCTFail("Expect serverError")
        }
    }
    
    func testRequest_withFailingSerialization() {
        //Given
        networkAccess.changeMock(data: Train.JSONDataWithInvalidKey, response: nil, error: nil)
        let expection = expectation(description: "testRequest_withFailingSerialization")
        
        //When
        networkService.request(resource, onCompletion: { _ in
            XCTFail("Should not call success block")
        }, onError: { (error: NetworkError) in
                if case .serializationError(_, _) = error {
                    expection.fulfill()
                } else {
                    XCTFail("Expects serializationError")
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
        networkService.request(resource, onCompletion: { _ in
            }, onError: { resultError in
                //Then
                switch resultError {
                case .requestError:
                    expection.fulfill()
                default:
                    XCTFail("Expects requestError")
                }
        })
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    private lazy var testData: Data! = {
        return "test_string".data(using: .utf8)
    }()
    
    func testRequest_withStatusCode401Response() {
        //Given
        let expectedResponse = HTTPURLResponse(url: .defaultMock, statusCode: 401, httpVersion: nil, headerFields: nil)
        networkAccess.changeMock(data: testData, response: expectedResponse, error: nil)
        let expection = expectation(description: "testOnError")
        
        //When
        networkService.request(resource, onCompletion: { _ in
            }, onError: { resultError in
                //Then
                switch resultError {
                case .unauthorized(let response, let data):
                    XCTAssertEqual(response, expectedResponse)
                    XCTAssertEqual(data, self.testData)
                    expection.fulfill()
                default:
                    XCTFail("Expects unauthorized")
                }
        })
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testGIVEN_aRequest_WHEN_requestWithResultResponse_THEN_ShouldRespond() {
        // GIVEN
        
        networkAccess.changeMock(data: Train.validJSONData, response: .defaultMock, error: nil)
        let expection = expectation(description: "loadValidRequest")
        var expectedResult: Result<Train, NetworkError>?
        
        //When
        networkService.request(resource, onCompletion: { result in
            expectedResult = result
            expection.fulfill()
        })
        
        waitForExpectations(timeout: 1, handler: nil)
        
        //Then
        switch expectedResult {
        case .success(let train)?:
            XCTAssertEqual(train.name, self.trainName)
        case .failure?:
            XCTFail("Should be an error")
        case nil:
            XCTFail("Result should not be nil")
        }
        XCTAssertEqual(networkAccess.request?.url?.absoluteString, "https://bahn.de/train")
    }
    
    func testGIVEN_aRequest_WHEN_requestWithResultErrorResponse_THEN_ShouldError() {
        //Given
        networkAccess.changeMock(data: nil, response: nil, error: nil)
        var expectedResult: Result<Train, NetworkError>?
        let expection = expectation(description: "testNoData")
        
        //When
        
        networkService.request(resource, onCompletion: { result in
            expectedResult = result
            expection.fulfill()
        })
        
        //Then
        waitForExpectations(timeout: 1, handler: nil)
        
        switch expectedResult {
        case .failure(let error)?:
            if case .serverError(let response, let data) = error {
                XCTAssertNil(response)
                XCTAssertNil(data)
            } else {
                XCTFail("Expect serverError")
            }
        default:
            XCTFail("Expect serverError")
        }
    }
    
    func testGIVEN_aRequest_WHEN_requestWithResultAndResponse_THEN_ShouldRespond() {
        // GIVEN
        
        networkAccess.changeMock(data: Train.validJSONData, response: .defaultMock, error: nil)
        let expection = expectation(description: "loadValidRequest")
        var expectedResult: Result<(Train, HTTPURLResponse), NetworkError>?
        
        //When
        networkService.request(resource: resource) { (result) in
            expectedResult = result
            expection.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
        
        //Then
        switch expectedResult {
        case .success(let result)?:
            XCTAssertEqual(result.0.name, self.trainName)
            XCTAssertEqual(result.1, .defaultMock)
        case .failure?:
            XCTFail("Should be an error")
        case nil:
            XCTFail("Result should not be nil")
        }
        XCTAssertEqual(networkAccess.request?.url?.absoluteString, "https://bahn.de/train")
    }
    
    @available(iOS 13.0, *)
    func testGIVEN_aRequest_WHEN_requestrFuture_THEN_ShouldRespond() {
        // GIVEN
        networkAccess.changeMock(data: Train.validJSONData, response: .defaultMock, error: nil)
        let expection = expectation(description: "loadValidRequest")
        var expectedResult: Result<(Train, HTTPURLResponse), NetworkError>?
        
        //When
        let future = networkService.request(resource)
        let sinkObserver = future.sink(receiveCompletion: { completion in
            if case .finished = completion {
                return
            }
             XCTFail("Should not succeed")
        }, receiveValue: { (response) in
            expectedResult = .success(response)
            expection.fulfill()
        })
        
        waitForExpectations(timeout: 1, handler: nil)
        
        //Then
        switch expectedResult {
        case .success(let result)?:
            XCTAssertEqual(result.0.name, self.trainName)
            XCTAssertEqual(result.1, .defaultMock)
        case .failure?:
            XCTFail("Should be an error")
        case nil:
            XCTFail("Result should not be nil")
        }
        XCTAssertEqual(networkAccess.request?.url?.absoluteString, "https://bahn.de/train")
    }
    
    @available(iOS 13.0, *)
    func testGIVEN_aRequest_WHEN_requestrFuture_THEN_ShouldError() {
        // GIVEN
        networkAccess.changeMock(data: nil, response: nil, error: nil)
        let expection = expectation(description: "loadValidRequest")
        var expectedResult: Result<(Train, HTTPURLResponse), NetworkError>?
        
        //When
        let future = networkService.request(resource)
        let sinkObserver = future.sink(receiveCompletion: { (completion) in
            switch completion {
            case .finished:
                return
            case .failure(let networkError):
                expectedResult = .failure(networkError)
                expection.fulfill()
            }
        }, receiveValue: { _ in
            XCTFail("should not error")
        })
        
        waitForExpectations(timeout: 1, handler: nil)
        
        //Then
        switch expectedResult {
        case .failure(let error)?:
           if case .serverError(let response, let data) = error {
               XCTAssertNil(response)
               XCTAssertNil(data)
           } else {
               XCTFail("Expect serverError")
           }
        default:
           XCTFail("Expect serverError")
        }
    }
}
