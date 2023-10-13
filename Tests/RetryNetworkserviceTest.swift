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
    var resource: Resource<Int, NetworkError> {
        let request = URLRequest(path: "/train", baseURL: .defaultMock)
        return Resource(request: request, parse: { _ in return 1})
    }
    
    func testRetryRequest_shouldRetry() async throws {
        //Given
        let errorCount = 2
        let numberOfRetries = 2
        let networkServiceMock = NetworkServiceMock(
            Result<Int, NetworkError>.failure(.unknownError),
            Result<Int, NetworkError>.failure(.unknownError),
            Result<Int, NetworkError>.success(1)
        )

        let retryService = RetryNetworkService(
            networkService: networkServiceMock,
            numberOfRetries: numberOfRetries,
            idleTimeInterval: 0,
            shouldRetry: { _ in
                return true
            }
        )
        
        //When
        let result = try await retryService.request(resource)

        
        //Then
        XCTAssertEqual(result, 1)
    }
    
//    func testRetryRequestWhenCanceld_shouldNotRetry() throws {
//        //Given
//        let networkServiceMock = NetworkServiceMock()
//        let retryService = RetryNetworkService(
//            networkService: networkServiceMock,
//            numberOfRetries: 2,
//            idleTimeInterval: 0,
//            shouldRetry: { _ in return true }
//        )
//        let task = Task {
//            await retryService.requestResult(for: resource)
//        }
//        task.cancel()
//
//        //When
//       
//        task?.cancel()
//        try networkServiceMock.returnError(with: .unknownError)
//        
//        //Then
//        XCTAssertNil(task)
//    }
    
    func testRetryRequest_moreErrorsThenRetryAttemps() async throws {
        //Given
        let networkServiceMock = NetworkServiceMock(
            Result<Int, NetworkError>.failure(.unknownError),
            Result<Int, NetworkError>.failure(.unknownError),
            Result<Int, NetworkError>.failure(.unknownError),
            Result<Int, NetworkError>.failure(.unknownError)
        )
        let retryService = RetryNetworkService(
            networkService: networkServiceMock,
            numberOfRetries: 3,
            idleTimeInterval: 0,
            shouldRetry: { _ in return true }
        )

        //When
        let result = await retryService.requestResult(for: resource)

        
        //Then
        if case .failure(.unknownError) = result {

        } else {
            XCTFail()
        }
    }
    
    func testRetryRequest_shouldNotRetry() async throws {
        //Given
        let networkServiceMock = NetworkServiceMock(
            Result<Int, NetworkError>.failure(.unknownError)
        )
        let retryService = RetryNetworkService(
            networkService: networkServiceMock,
            numberOfRetries: 3,
            idleTimeInterval: 0,
            shouldRetry: { _ in return true }
        )

        //When
        await retryService.requestResult(for: resource)
    }
}
