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

class NetworkServiceTest: XCTestCase {

    let trainName = "ICE"
    
    var resource: Resource<Train> {
        let request = URLRequest(path: "train", baseURL: .defaultMock)
        return Resource(request: request, decoder: JSONDecoder())
    }

    
    func testRequest_withValidResponse() async throws {
        //Given
        let networkAccess = NetworkAccessMock(result: .success((Train.validJSONData, HTTPURLResponse.defaultMock)))
        let networkService = BasicNetworkService(networkAccess: networkAccess)

        //When
        let (train, response) = try await networkService.requestResultWithResponse(for: resource).get()

        //Then
        XCTAssertEqual(train.name, self.trainName)
        XCTAssertEqual(response, .defaultMock)
        let request = await networkAccess.request
        XCTAssertEqual(request?.url?.absoluteString, "https://bahn.de/train")
    }
    
    func testRequest_withFailingSerialization() async {
        //Given
        let networkAccess = NetworkAccessMock(result: .success((Train.JSONDataWithInvalidKey, HTTPURLResponse.defaultMock)))
        let networkService = BasicNetworkService(networkAccess: networkAccess)
        
        //When
        let result = await networkService.requestResult(for: resource)

        //Then
        if case .failure(.serializationError(_, let data)) = result {
            XCTAssertEqual(data, Train.JSONDataWithInvalidKey)
        } else {
            XCTFail("Expects serializationError")
        }
    }
    
    func testRequest_withErrorResponse() async {
        //Given
        let error = NSError(domain: "", code: 0, userInfo: nil)
        let networkAccess = NetworkAccessMock(result: .failure(error))
        let networkService = BasicNetworkService(networkAccess: networkAccess)

        //When
        let result = await networkService.requestResult(for: resource)

        //Then
        switch result {
        case .failure(.requestError):
            return
        default:
            XCTFail("Expects requestError")
        }
    }

    func testRequest_withErrorThrow() async {
        //Given
        let error = NSError(domain: "", code: 0, userInfo: nil)
        let networkAccess = NetworkAccessMock(result: .failure(error))
        let networkService = BasicNetworkService(networkAccess: networkAccess)

        //When
        do {
            try await networkService.request(resource)
            XCTFail("Expects throws")
        } catch {
            return
        }
    }

    func testRequest_withStatusCode401Response() async throws {
        //Given
        let testData: Data! = "test_string".data(using: .utf8)
        let expectedResponse = try XCTUnwrap(HTTPURLResponse(url: .defaultMock, statusCode: 401, httpVersion: nil, headerFields: nil))
        let networkAccess = NetworkAccessMock(result: .success((testData, expectedResponse)))
        let networkService = BasicNetworkService(networkAccess: networkAccess)

        //When
        let result = await networkService.requestResult(for: resource)

        //Then
        if case .failure(.unauthorized(response: expectedResponse, data: testData)) = result {
            return
        } else {
            XCTFail()
        }
    }

}
