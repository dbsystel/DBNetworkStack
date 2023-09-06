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
    
    let trainName = "ICE"
    
    var resource: ResourceWithError<Train, CustomError> {
        let request = URLRequest(path: "train", baseURL: .defaultMock)
        return ResourceWithError(request: request, decoder: JSONDecoder(), mapError: { CustomError(networkError: $0) })
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
        XCTAssertEqual(networkAccess.request?.url?.absoluteString, "https://bahn.de/train")
    }

    func testRequest_withError() async {
        let error = NSError(domain: "", code: 0, userInfo: nil)
        let networkAccess = NetworkAccessMock(result: .failure(error))
        let networkService = BasicNetworkService(networkAccess: networkAccess)

        //When
        let result = await networkService.requestResult(for: resource)

        //Then
        XCTAssertEqual(result, .failure(.error))
    }

}
