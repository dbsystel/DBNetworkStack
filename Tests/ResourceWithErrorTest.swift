//
//  Copyright (C) 2021 DB Systel GmbH.
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

class ResourceWithErrorTest: XCTestCase {
    
    func testResource() throws {
        //Given
        let validData: Data! = "ICE".data(using: .utf8)

        let resource = Resource<String?, NetworkError>(
            request: URLRequest.defaultMock,
            parse: { String(data: $0, encoding: .utf8) },
            mapError: { $0 }
        )
        
        //When
        let name = try resource.parse(validData)
        
        //Then
        XCTAssertEqual(name, "ICE")
    }

    func testResourceMap() throws {
        //Given
        let validData: Data! = "ICE".data(using: .utf8)

        let resource = Resource<String?, NetworkError>(
            request: URLRequest.defaultMock,
            parse: { String(data: $0, encoding: .utf8) },
            mapError: { $0 }
        )

        //When
        let numberOfCharacters = try resource.map(transform: { $0?.count }).parse(validData)

        //Then
        XCTAssertEqual(numberOfCharacters, 3)
    }

    func testResourceMapError() {
        //Given
        enum CustomError: Error{
            case error
        }
        let resource = Resource<Void, CustomError>(
            request: URLRequest.defaultMock,
            mapError: { _ in return .error }
        )

        //When
        let mappedError = resource.mapError(.unknownError)

        //Then
        XCTAssertEqual(mappedError, .error)
    }

    func testResourceWithVoidResult() throws {
        //Given
        let resource = Resource<Void, CustomError>(
            request: URLRequest.defaultMock,
            mapError: { _ in return .error }
        )

        //When
        try resource.parse(Data())
    }

}
