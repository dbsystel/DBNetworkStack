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

enum CustomError: Error {
    case error

    init(networkError: NetworkError) {
        self = .error
    }
}

class NetworkServiceWithErrorTest: XCTestCase {
    
    var networkService: NetworkService!
    
    var networkAccess = NetworkAccessMock()
    
    let trainName = "ICE"
    
    var resource: ResourceWithError<Train, CustomError> {
        let request = URLRequest(path: "train", baseURL: .defaultMock)
        return ResourceWithError(request: request, decoder: JSONDecoder(), mapError: { CustomError(networkError: $0) })
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

    func testRequest_withError() {
        //Given
        networkAccess.changeMock(data: nil, response: nil, error: nil)
        let expection = expectation(description: "testNoData")
        
        //When
        var capturedError: CustomError?
        networkService.request(resource, onCompletion: { _ in
            XCTFail("Should not call success block")
            }, onError: { error in
                capturedError = error
                expection.fulfill()
        })
        
        //Then
        waitForExpectations(timeout: 1, handler: nil)
        
        XCTAssertEqual(capturedError, .error)
    }

    
    func testGIVEN_aRequest_WHEN_requestWithResultResponse_THEN_ShouldRespond() {
        // GIVEN
        
        networkAccess.changeMock(data: Train.validJSONData, response: .defaultMock, error: nil)
        let expection = expectation(description: "loadValidRequest")
        var expectedResult: Result<Train, CustomError>?
        
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
        var expectedResult: Result<Train, CustomError>?
        let expection = expectation(description: "testNoData")
        
        //When
        
        networkService.request(resource, onCompletion: { result in
            expectedResult = result
            expection.fulfill()
        })
        
        //Then
        waitForExpectations(timeout: 1, handler: nil)

        XCTAssertEqual(expectedResult, .failure(.error))
    }
    
    func testGIVEN_aRequest_WHEN_requestWithResultAndResponse_THEN_ShouldRespond() {
        // GIVEN
        
        networkAccess.changeMock(data: Train.validJSONData, response: .defaultMock, error: nil)
        let expection = expectation(description: "loadValidRequest")
        var expectedResult: Result<(Train, HTTPURLResponse), CustomError>?
        
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

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func testGIVEN_aRequest_WHEN_requestWithAsyncResultAndResponse_THEN_ShouldRespond() async throws {
        // GIVEN
        networkAccess.changeMock(data: Train.validJSONData, response: .defaultMock, error: nil)

        //When
        let (result, response) = try await networkService.request(resource)


        //Then
        XCTAssertEqual(result.name, self.trainName)
        XCTAssertEqual(response, .defaultMock)
        XCTAssertEqual(networkAccess.request?.url?.absoluteString, "https://bahn.de/train")
    }

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func testGIVEN_aRequest_WHEN_requestWithAsyncResultAndResponse_THEN_ShouldThwo() async {
        // GIVEN
        let error = NSError(domain: "", code: 0, userInfo: nil)
        networkAccess.changeMock(data: nil, response: nil, error: error)

        //When
        do {
            try await networkService.request(resource)
            XCTFail("Schould throw")
        } catch let error {
            XCTAssertTrue(error is CustomError)
        }
    }
}
