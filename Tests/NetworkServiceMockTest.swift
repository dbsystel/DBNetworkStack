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
    
    
    let resource: Resource<Train> = Resource(request: URLRequest(path: "train", baseURL: .defaultMock), decoder: JSONDecoder())

    func testRequestCount() async throws {
        let networkServiceMock = NetworkServiceMock()
        await networkServiceMock.schedule(success: Train(name: "1"))
        await networkServiceMock.schedule(success: Train(name: "2"))

        //When
        try await networkServiceMock.request(resource)
        try await networkServiceMock.request(resource)

        //Then
        let requestCount = await  networkServiceMock.requestCount
        XCTAssertEqual(requestCount, 2)
    }
    
    func testLastRequests() async throws {
        //Given
        let networkServiceMock = NetworkServiceMock()
        await networkServiceMock.schedule(success: Train(name: "1"))
        await networkServiceMock.schedule(success: Train(name: "2"))

        //When
        try await networkServiceMock.request(resource)
        try await networkServiceMock.request(resource)

        //Then
        let lastRequests = await networkServiceMock.lastRequests
        XCTAssertEqual(lastRequests, [resource.request, resource.request])
    }
    
    func testReturnSuccessWithData() async throws {
        //Given
        let networkServiceMock = NetworkServiceMock()
        await networkServiceMock.schedule(success: Train(name: "1"))

        //When
        let result = try await networkServiceMock.request(resource)

        
        //Then
        XCTAssertEqual(result, Train(name: "1"))
    }

    func testCorrectOrderOfReturnSuccessWithDataForMultipleRequests() async throws {
        //Given
        let networkServiceMock = NetworkServiceMock()
        await networkServiceMock.schedule(success: Train(name: "1"))
        await networkServiceMock.schedule(success: Train(name: "2"))

        //When
        let result1 = try await networkServiceMock.request(resource)
        let result2 = try await networkServiceMock.request(resource)

        //Then
        XCTAssertEqual(result1, Train(name: "1"))
        XCTAssertEqual(result2, Train(name: "2"))
    }
    
    func testReturnError() async throws {
        //Given
        let networkServiceMock = NetworkServiceMock()
        await networkServiceMock.schedule(failure: .unknownError)

        //When
        let result = await networkServiceMock.requestResult(for: resource)

        //Then
        if case .failure(.unknownError) = result {

        } else {
            XCTFail()
        }
    }
    
    func testCorrectOrderOfReturnErrorForMultipleRequests() async throws {
        //Given
        let networkServiceMock = NetworkServiceMock()
        await networkServiceMock.schedule(failure: .unknownError)
        await networkServiceMock.schedule(failure: .cancelled)

        //When
        let result1 = await networkServiceMock.requestResult(for: resource)
        let result2 = await networkServiceMock.requestResult(for: resource)

        //Then
        if case .failure(.unknownError) = result1, case .failure(.cancelled) = result2 {

        } else {
            XCTFail("Wrong order of error responses")
        }
    }

    func testReturnSuccessMismatchType() async {
        //When
        let networkServiceMock = NetworkServiceMock()

        //When
        let result1 = await networkServiceMock.requestResult(for: resource)

        //Then
        if case .failure(.serverError) = result1 {

        } else {
            XCTFail("Wrong order of error responses")
        }
    }

}
